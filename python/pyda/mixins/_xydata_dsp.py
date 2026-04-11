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
import scipy
from scipy import interpolate
from scipy.interpolate import interpolate, interp1d


class XYDataDSP:
    def integrate(self):
        """
        Integrate the input data using composite trapezoidal rule (scipy.integrate.cumtrapz).

        :return: new XYData object with the integrated data
        """
        yu = self.yaxis.units
        xu = self.xaxis.units
        x = self.xdata()
        y = self.ydata()
        iy = scipy.integrate.cumulative_trapezoid(x=x, y=y, initial=0)
        odata = self.deepcopy()
        odata.yaxis = iy
        odata.name = "integrate(" + odata.name + ")"
        odata.yaxis.units = yu * xu

        return odata

    def split_by_samples(self, indices=[0, None]):
        """
        Split the XYData into multiple objects by specifying pairs of start and stop samples. The
        method returns objects that contain the start samples and run up to (but don't include) the
        stop samples.

        If a single start/stop pair are specified, a single XYData will be returned. Otherwise
        a list of XYData objects will be returned.

        Example:
            out = xy.split_by_samples(indices=[0, 10, 10, 20]

        will return two objects, each with 10 samples.

        :return:
        """

        # identify start and stop indices
        starts = indices[0:None:2]
        stops = indices[1:None:2]

        print(starts)
        print(stops)

        x = self.xdata()
        y = self.ydata()
        dx = self.xaxis.ddata
        dy = self.yaxis.ddata
        output = []
        kk = 0
        for start, stop in zip(starts, stops):
            print(str(start) + " to " + str(stop))
            ts = self.deepcopy()
            ts.xaxis.data = x[start:stop]
            ts.yaxis.data = y[start:stop]
            ts.xaxis.ddata = dx[start:stop]
            ts.yaxis.ddata = dy[start:stop]
            ts.name = ts.name + "[" + str(kk) + "]"
            output.append(ts)
            kk += 1

        if len(output) == 1:
            return output[0]

        return output

    def detrend(self=None, order=0):
        """
        Detrend the yaxis of the input data

        :param order:
        """
        x = self.xdata()
        y = self.ydata()

        yo = XYDataDSP._polydetrend(x, y, order)

        v = self.deepcopy()
        v.yaxis.data = yo
        v._name = "detrend(" + self._name + ")"

        return v

    def interp(self=None, xnew=None, kind="cubic"):
        """
        Interpolate the XY object on the new x values.

        :param xnew: vector of new x values
        :param kind: nearest, previous, next, cubic
        :return: XYData
        """
        f = interp1d(self.xdata(), self.ydata(), kind=kind)
        ynew = f(xnew)

        out = self.deepcopy()

        out.xaxis.data = xnew
        out.yaxis.data = ynew

        out._name = "interp(" + self._name + ")"

        return out

    def polyfit(self=None, order=0):
        """
        Fit a polynominal of the requested order to the given data series. The method returns the polynominal
        coefficients and a data object containing the polynomial coefficients evaluated at the same x-values as the
        original data.

        :param order:
        :return:
        """

        x = self.xdata()
        y = self.ydata()
        p = numpy.polyfit(x, y, order)
        py = numpy.polyval(p, x)
        xy = self.deepcopy()
        xy.yaxis.data = py
        xy.yaxis.ddata = 0
        xy.name = "polyfit(" + self.name + ")"
        return p, xy

    @classmethod
    def _polydetrend(cls, x, y, order):
        p = numpy.polyfit(x, y, order)
        py = numpy.polyval(p, x)
        return y - py
