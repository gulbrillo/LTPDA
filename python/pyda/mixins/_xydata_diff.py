#  Copyright 2022 Martin Hewitson
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.


import numpy


class XYDataDiff:
    def diff(self, method="3point", order="First"):
        """
        Differentiate the y-axis data of the input object.


        'diff' - uses numpy.diff.

        '2point' - 2 point derivative

        Computed as:
                        [y(i+1)-y(i)]./[x(i+1)-x(i)]

        '3point' - 3 point derivative.

        Compute derivative dx at i as
                        [y(i+1)-y(i-1)] / [x(i+1)-x(i-1)]

        For i==1, the output is computed as
            [y(2)-y(1)]/[x(2)-x(1)]

        The last sample is computed as [y(N)-y(N-1)]/[x(N)-x(N-1)].

        '5point' - 5 point derivative.

        Compute derivative dx at i as
        [-y(i+2)+8*y(i+1)-8*y(i-1)+y(i-2)] / [3*(x(i+2)-x(i-2))]

        For i==1, the output is computed as [y(2)-y(1)]/[x(2)-x(1)]

        The last sample is computed as [y(N)-y(N-1)]/[x(N)-x(N-1)].

        'order2' - Compute derivative using a 2nd order method

        'order2Smooth' - Compute derivative using a 2nd order method with a parabolic fit to 5 consecutive samples.

        Note: parameter 'order' only applies to the cases where 'METHOD' is set to: 'FPS', 'diff', '2point',
        '3point', or '5point'.

        :param method: choose from 'diff', '2point', '3point', '5point', 'order2', 'order2Smooth'
        :param order: choose from 'Zero', 'First', or 'Second'
        """

        lmethod = method.lower()

        # deep copy of input to modify for output
        ts = self.deepcopy()

        xunits = ts.xaxis.units
        z = ts.ydata()
        newX = ts.xdata()

        if lmethod == "diff":

            if order == "Zero":
                pass
            elif order == "First":
                z = numpy.diff(ts.yaxis.data)
                newX = ts.xaxis.data[0:-1]
            elif order == "Second":
                z = numpy.diff(numpy.diff(ts.yaxis.data))
                newX = ts.xaxis.data[0:-2]
                xunits = ts.xaxis.units**2
            else:
                raise Exception("Unknown derivative order " + order)

            pass
        elif lmethod == "2point":
            if order == "Zero":
                pass
            elif order == "First":
                newX, z = XYDataDiff._diff2p_core(ts.xdata(), ts.ydata())
            elif order == "Second":
                newX, z = XYDataDiff._diff2p_core(ts.xdata(), ts.ydata())
                newX, z = XYDataDiff._diff2p_core(newX, z)
                xunits = ts.xaxis.units**2
            else:
                raise Exception("Unknown derivative order " + order)

        elif lmethod == "3point":
            if order == "Zero":
                pass
            elif order == "First":
                dx = numpy.diff(ts.xdata())
                z = XYDataDiff._diff3p_core(ts.ydata(), dx)
            elif order == "Second":
                dx = numpy.diff(ts.xdata())
                z = XYDataDiff._diff3p_core(ts.ydata(), dx)
                z = XYDataDiff._diff3p_core(z, dx)
            else:
                raise Exception("Unknown derivative order " + order)

        elif lmethod == "5point":
            if order == "Zero":
                pass
            elif order == "First":
                dx = numpy.diff(ts.xdata())
                z = XYDataDiff._diff5p_core(ts.xdata(), ts.ydata(), dx)
            elif order == "Second":
                dx = numpy.diff(ts.xdata())
                z = XYDataDiff._diff5p_core(ts.xdata(), ts.ydata(), dx)
                z = XYDataDiff._diff5p_core(ts.xdata(), z, dx)
            else:
                raise Exception("Unknown derivative order " + order)

        elif lmethod == "order2":
            z = XYDataDiff._diffOrder2(ts.xdata(), ts.ydata())

        elif lmethod == "order2smooth":
            z = XYDataDiff._diffOrderSmooth(ts.xdata(), ts.ydata())
        else:
            raise Exception("Derivative method not supported: " + lmethod)

        # set output data
        ts.yaxis.data = z
        ts.xaxis.data = newX

        # set yunits
        ts.yaxis.units /= xunits

        # set name
        ts.name = method + "(" + ts.name + ")"

        return ts

    @classmethod
    def _diffOrderSmooth(cls, x, y):

        dx = numpy.diff(x)
        m = len(y)
        if m < 5:
            raise Exception(
                "### Length of y must be at least 5 for method ''ORDER2SMOOTH''."
            )

        h = numpy.mean(dx)
        z = numpy.zeros(y.size)
        # y'(x1)
        z[0] = numpy.sum(y[0:5] * [-54.0, 13.0, 40.0, 27.0, -26.0]) / 70.0 / h
        # y'(x2)
        z[1] = numpy.sum(y[0:5] * [-34.0, 3.0, 20.0, 17.0, -6.0]) / 70.0 / h
        # y'(x{m-1})
        z[m - 2] = numpy.sum(y[-5:None] * [6.0, -17.0, -20.0, -3.0, 34.0]) / 70.0 / h
        # y'(xm)
        z[m - 1] = numpy.sum(y[-5:None] * [26.0, -27.0, -40.0, -13.0, 54.0]) / 70.0 / h
        # y'(xi) (i>2 & i<(N-1))
        Dc = [2.0, 1.0, 0.0, -1.0, -2.0]
        tmp = numpy.convolve(Dc, y) / 10.0 / h
        z[2 : m - 2] = tmp[4:-4]

        return z

    @classmethod
    def _diffOrder2(cls, x, y):
        dx = numpy.diff(x)
        z = numpy.zeros(y.size)
        m = len(y)
        # y'(x1)
        z[0] = (1 / dx[0] + 1 / dx[1]) * (y[1] - y[0]) + dx[0] / (
            dx[0] * dx[1] + dx[1] ** 2
        ) * (y[0] - y[2])
        # y'(xm)
        z[m - 1] = (1 / dx[m - 3] + 1 / dx[m - 2]) * (y[m - 1] - y[m - 2]) + dx[
            m - 2
        ] / (dx[m - 2] * dx[m - 3] + dx[m - 3] ** 2) * (y[m - 3] - y[m - 1])
        # y'(xi) (i>1 & i<m)
        dx1 = dx[0 : m - 2]
        dx2 = dx[1 : m - 1]
        y1 = y[0 : m - 2]
        y2 = y[1 : m - 1]
        y3 = y[2:m]
        z[1 : m - 1] = (
            1.0
            / (dx1 * dx2 * (dx1 + dx2))
            * (-(dx2**2) * y1 + (dx2**2 - dx1**2) * y2 + dx1**2 * y3)
        )

        return z

    @classmethod
    def _diff5p_core(cls, x, y, dx):
        z = numpy.zeros(y.size)
        z[0] = (y[1] - y[0]) / dx[0]
        z[1] = (y[2] - y[0]) / (dx[1] + dx[0])
        z[2:-2] = (-y[4:None] + 8.0 * y[3:-1] - 8.0 * y[1:-3] + y[0:-4]) / (
            3.0 * (x[4:None] - x[0:-4])
        )
        z[-2] = 2 * z[-3] - z[-4]
        z[-1] = 2 * z[-2] - z[-3]

        return z

    @classmethod
    def _diff3p_core(cls, y, dx):

        z = numpy.zeros(y.size)
        z[1:-1] = (y[2:None] - y[0:-2]) / (dx[1:None] + dx[0:-1])
        z[0] = (y[1] - y[0]) / (dx[0])
        z[-1] = 2 * z[-2] - z[-3]

        return z

    @classmethod
    def _diff2p_core(cls, x, y):

        dx = numpy.diff(x)
        dy = numpy.diff(y)
        z = dy / dx

        newX = (x[0:-1] + x[1:None]) / 2
        return newX, z
