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
import numbers
import pyda
from pyda.ydata import YData
from pyda.utils._pyda_obj import _pyda_obj


class XYDataOperators:

    # ----------------------------------------------------
    # Operators
    # ----------------------------------------------------

    # Helper method for comparison operators
    def _compare(self, other, op_name, op_func):
        """
        Helper method for comparison operators.

        :param other: The other XYData or YData object to compare with
        :param op_name: The name of the operator (e.g., ">", "<")
        :param op_func: The function to apply to the yaxis objects
        :return: A new XYData object with the comparison result
        """
        if isinstance(other, YData):
            # check they have the same yunits
            u1 = self.yunits()
            u2 = other.yunits()
            if u1 != u2:
                raise Exception(
                    "Units of object 1 " + u1.char() + " not equal to object 2 " + u2.char()
                )

            # Check if we're comparing a scalar with an array
            self_is_scalar = self.yaxis.data.size == 1
            other_is_scalar = other.yaxis.data.size == 1

            # Handle scalar vs array comparisons
            out = None
            if self_is_scalar and not other_is_scalar and isinstance(other, YData):
                # Self is scalar, other is array
                # Apply comparison to get a boolean mask
                mask = op_func(self.yaxis.data[0], other.yaxis.data)

                if numpy.any(mask):
                    # create a copy of other
                    out = other.deepcopy()
                    out.name = "(" + self.name + " " + op_name + " " + other.name + ")"

                    # Set filtered data
                    out.xaxis.data = other.xaxis.data[mask]
                    out.yaxis.data = other.yaxis.data[mask]

                    # Set ddata if it has the same size as data
                    if other.xaxis.ddata.size == other.xaxis.data.size:
                        out.xaxis.ddata = other.xaxis.ddata[mask]
                    elif other.xaxis.ddata.size == 1:
                        out.xaxis.ddata = other.xaxis.ddata

                    if other.yaxis.ddata.size == other.yaxis.data.size:
                        out.yaxis.ddata = other.yaxis.ddata[mask]
                    elif other.yaxis.ddata.size == 1:
                        out.yaxis.ddata = other.yaxis.ddata


            elif not self_is_scalar and other_is_scalar:
                # Self is array, other is scalar
                # Apply comparison to get a boolean mask
                mask = op_func(self.yaxis.data, other.yaxis.data[0])

                if numpy.any(mask):
                    # create copy of self
                    out = self.deepcopy()
                    out.name = "(" + self.name + " " + op_name + " " + other.name + ")"

                    # set filtered data
                    out.xaxis.data = self.xaxis.data[mask]
                    out.yaxis.data = self.yaxis.data[mask]

                    # Set ddata if it has the same size as data
                    if self.xaxis.ddata.size == self.xaxis.data.size:
                        out.xaxis.ddata = self.xaxis.ddata[mask]
                    elif self.xaxis.ddata.size == 1:
                        out.xaxis.ddata = self.xaxis.ddata

                    if self.yaxis.ddata.size == self.yaxis.data.size:
                        out.yaxis.ddata = self.yaxis.ddata[mask]
                    elif self.yaxis.ddata.size == 1:
                        out.yaxis.ddata = self.yaxis.ddata

            elif not self_is_scalar and not other_is_scalar and isinstance(other, YData):
                # Both are arrays
                # Apply comparison to get a boolean mask
                mask = op_func(self.yaxis.data, other.yaxis.data)

                if numpy.any(mask):
                    # Create copy of self
                    out = self.deepcopy()
                    out.name = "(" + self.name + " " + op_name + " " + other.name + ")"

                    # Create a new XYData object with the filtered data
                    out.xaxis.data = self.xaxis.data[mask]
                    out.yaxis.data = self.yaxis.data[mask]

                    # Set ddata if it has the same size as data
                    if self.xaxis.ddata.size == self.xaxis.data.size:
                        out.xaxis.ddata = self.xaxis.ddata[mask]
                    elif self.xaxis.ddata.size == 1:
                        out.xaxis.ddata = self.xaxis.ddata

                    if self.yaxis.ddata.size == self.yaxis.data.size:
                        out.yaxis.ddata = self.yaxis.ddata[mask]
                    elif self.yaxis.ddata.size == 1:
                        out.yaxis.ddata = self.yaxis.ddata

            else:
                # Both are scalars or other cases
                # Apply the comparison function to get the result
                mask = op_func(self.yaxis.data, other.yaxis.data)

                if numpy.any(mask):
                    # copy of self
                    out = self.deepcopy()
                    out.name = "(" + self.name + " " + op_name + " " + other.name + ")"

                    # set filtered data
                    out.xaxis.data = self.xaxis.data[mask]
                    out.yaxis.data = self.yaxis.data[mask]

                    # Set ddata if it has the same size as data
                    if self.xaxis.ddata.size == self.xaxis.data.size:
                        out.xaxis.ddata = self.xaxis.ddata[mask]
                    elif self.xaxis.ddata.size == 1:
                        out.xaxis.ddata = self.xaxis.ddata

                    if self.yaxis.ddata.size == self.yaxis.data.size:
                        out.yaxis.ddata = self.yaxis.ddata[mask]
                    elif self.yaxis.ddata.size == 1:
                        out.yaxis.ddata = self.yaxis.ddata

            if out is None:
                out = self.deepcopy()
                out.name = "(" + self.name + " " + op_name + " " + other.name + ")"
                # No matches, return empty XYData
                out.xaxis.data = numpy.array([])
                out.yaxis.data = numpy.array([])
                out.xaxis.ddata = numpy.array([])
                out.yaxis.ddata = numpy.array([])

            return out
        else:
            raise Exception("Cannot compare XYData with " + str(type(other)))

    # override >
    def __gt__(self, other):
        """
        Override the greater than operator to compare two XYData objects.
        Return a new XYData object with the values that pass the > test.

        :param other: The other XYData or YData object to compare with
        :return: A new XYData object with the filtered data
        """
        return self._compare(other, ">", lambda x, y: x > y)

    # override <
    def __lt__(self, other):
        """
        Override the less than operator to compare two XYData objects.
        Return a new XYData object with the values that pass the < test.

        :param other: The other XYData or YData object to compare with
        :return: A new XYData object with the filtered data
        """
        return self._compare(other, "<", lambda x, y: x < y)

    # override >=
    def __ge__(self, other):
        """
        Override the greater than or equal operator to compare two XYData objects.
        Return a new XYData object with the values that pass the >= test.

        :param other: The other XYData or YData object to compare with
        :return: A new XYData object with the filtered data
        """
        return self._compare(other, ">=", lambda x, y: x >= y)

    # override <=
    def __le__(self, other):
        """
        Override the less than or equal operator to compare two XYData objects.
        Return a new XYData object with the values that pass the <= test.

        :param other: The other XYData or YData object to compare with
        :return: A new XYData object with the filtered data
        """
        return self._compare(other, "<=", lambda x, y: x <= y)

    # override ==
    def __eq__(self, other):
        """
        Override the equal operator to compare two XYData objects.
        Return a new XYData object with the values that pass the == test.

        :param other: The other XYData or YData object to compare with
        :return: A new XYData object with the filtered data
        """
        return self._compare(other, "==", lambda x, y: x == y)

    # override !=
    def __ne__(self, other):
        """
        Override the not equal operator to compare two XYData objects.
        Return a new XYData object with the values that pass the != test.

        :param other: The other XYData or YData object to compare with
        :return: A new XYData object with the filtered data
        """
        return self._compare(other, "!=", lambda x, y: x != y)

    def __truediv__(self, other):

        t1 = self.deepcopy()
        t2 = other

        # handle special case of "other" being a number
        if isinstance(t2, numbers.Number):
            t1.yaxis.data = t1.yaxis.data / t2
            t1._name = t1._name + "/" + str(t2)
            return t1

        # check length
        if t2.yaxis.data.size > 1 and t1.yaxis.data.size != t2.yaxis.data.size:
            raise Exception(
                "Can only divide objects of same length: "
                + str(t1.size)
                + " != "
                + str(t2.size())
            )

        # error propagation
        y1 = t1.yaxis.data.squeeze()
        y2 = t2.yaxis.data.squeeze()
        dy1 = t1.yaxis.ddata.squeeze()
        dy2 = t2.yaxis.ddata.squeeze()
        dy = numpy.sqrt(
            (dy1 / y2) ** 2
            + ((-y1 / y2 ** 2) * dy2) ** 2
            + ((y1 / y2 ** 3) * (dy2 ** 2)) ** 2
            + (((-1.0 / y2) ** 2) * dy1 * dy2) ** 2
        )
        t1.yaxis.ddata = dy

        # divide data
        t1.yaxis.data = y1 / y2
        t1.yaxis.units /= t2.yaxis.units

        # name
        t1.name = t1.name + "/" + t2.name

        return t1

    def __pow__(self, power, modulo=None):
        t1 = self.deepcopy()

        if isinstance(power, pyda.ydata.YData):
            if power.yaxis.data.size != 1:
                raise Exception("Need single valued YData to raise to power")
            power = power.ydata()[0]

        # error propagation
        y1 = t1.yaxis.data
        dy = t1.yaxis.ddata
        dy = dy * numpy.abs(power * y1 ** (power - 1))

        # raise to power
        t1.yaxis.data **= power
        t1.yaxis.units **= power
        t1.yaxis.ddata = dy

        t1.name = t1.name + "**" + str(power)

        return t1

    def _rpow__(self, power, modulo=None):
        t1 = self.deepcopy()

        if isinstance(power, pyda.ydata.YData):
            if power.yaxis.data.size != 1:
                raise Exception("Need single valued YData to raise to power")
            power = power.ydata()[0]

        # error propagation
        y1 = t1.yaxis.data
        dy = t1.yaxis.ddata
        dy = dy * numpy.abs(power * y1 ** (power - 1))

        # raise to power
        t1.yaxis.data **= power
        t1.yaxis.units **= power
        t1.yaxis.ddata = dy

        t1.name = t1.name + "**" + str(power)

        return t1

    def __rsub__(self, other):
        """
        Subtract two data series or a number

        t3 = t2 - t1
        t3 = t2 - 2

        :param other:
        :return:
        """
        t1 = self.deepcopy()
        t2 = other

        # handle special case of "other" being a number
        if isinstance(t2, numbers.Number):
            t1.yaxis.data = t2 - t1.yaxis.data
            t1._name = str(t2) + "-" + t1._name
            return t1

        if not isinstance(t2, pyda.xydata.XYData) and not isinstance(
            t2, pyda.ydata.YData
        ):
            raise Exception("Second object should be a number or a TSData object")

        # check units
        u1 = t1.yunits()
        u2 = t2.yunits()
        if u1 != u2:
            raise Exception(
                "Units of object 1 " + u1.char() + " not equal to object 2 " + u2.char()
            )

        # check length
        if t2.yaxis.data.size > 1 and t1.yaxis.data.size != t2.yaxis.data.size:
            raise Exception(
                "Can only subtract objects of same length: "
                + str(t1.size)
                + " != "
                + str(t2.size())
            )

        # error propagation
        y1 = t1.yaxis.data.squeeze()
        y2 = t2.yaxis.data.squeeze()
        dy1 = t1.yaxis.ddata.squeeze()
        dy2 = t2.yaxis.ddata.squeeze()
        dy = numpy.sqrt(dy1 ** 2 + dy2 ** 2)
        t1.yaxis.ddata = dy

        # subtract data
        t1.yaxis.data = y1 - y2

        # handle name
        t1.name = "(" + t1.name + " - " + t2.name + ")"

        return t1

    def __sub__(self, other):
        """
        Subtract two data series or a number

        t3 = t2 - t1
        t3 = t2 - 2

        :param other:
        :return:
        """
        t1 = self.deepcopy()
        t2 = other

        # handle special case of "other" being a number
        if isinstance(t2, numbers.Number):
            t1.yaxis.data = t1.yaxis.data - t2
            t1._name = t1._name + "-" + str(t2)
            return t1

        if not isinstance(t2, pyda.xydata.XYData) and not isinstance(
            t2, pyda.ydata.YData
        ):
            raise Exception("Second object should be a number or a TSData object")

        # check units
        u1 = t1.yunits()
        u2 = t2.yunits()
        if u1 != u2:
            raise Exception(
                "Units of object 1 " + u1.char() + " not equal to object 2 " + u2.char()
            )

        # check length
        if t2.yaxis.data.size > 1 and t1.yaxis.data.size != t2.yaxis.data.size:
            raise Exception(
                "Can only subtract objects of same length: "
                + str(t1.size)
                + " != "
                + str(t2.size())
            )

        # error propagation
        y1 = t1.yaxis.data.squeeze()
        y2 = t2.yaxis.data.squeeze()
        dy1 = t1.yaxis.ddata.squeeze()
        dy2 = t2.yaxis.ddata.squeeze()
        dy = numpy.sqrt(dy1 ** 2 + dy2 ** 2)
        t1.yaxis.ddata = dy

        # subtract data
        t1.yaxis.data = y1 - y2

        # handle name
        t1.name = "(" + t1.name + " - " + t2.name + ")"

        return t1

    def __radd__(self, other):
        out = self.__add__(other)
        return out

    def __add__(self, other):
        """

        :param other:
        :return:
        """
        t1 = self.deepcopy()
        t2 = other

        # handle special case of "other" being a number
        if isinstance(t2, numbers.Number):
            t1.yaxis.data = t1.yaxis.data + t2
            t1._name = t1._name + "+" + str(t2)
            return t1

        if not isinstance(t2, pyda.xydata.XYData) and not isinstance(
            t2, pyda.ydata.YData
        ):
            raise Exception("Second object should be a number or a TSData object")

        # check units
        u1 = t1.yunits()
        u2 = t2.yunits()
        if u1 != u2 and not u1.isEmpty() and not u2.isEmpty():
            raise Exception(
                "Units of object 1 " + u1.char() + " not equal to object 2 " + u2.char()
            )

        # check length
        if t2.yaxis.data.size > 1 and t1.yaxis.data.size != t2.yaxis.data.size:
            raise Exception(
                "Can only add objects of same length: "
                + str(t1.size())
                + " != "
                + str(t2.size())
            )

        # error propagation
        y1 = t1.yaxis.data.squeeze()
        y2 = t2.yaxis.data.squeeze()
        dy1 = t1.yaxis.ddata.squeeze()
        dy2 = t2.yaxis.ddata.squeeze()
        dy = numpy.sqrt(dy1 ** 2 + dy2 ** 2)
        t1.yaxis.ddata = dy

        # add data
        t1.yaxis.data = y1 + y2

        # handle name
        t1.name = "(" + t1.name + " + " + t2.name + ")"

        return t1

    def __rmul__(self, other):
        new_name = self.name
        out = self.__mul__(other)
        # handle name
        if isinstance(other, _pyda_obj):
            oname = other.name
        else:
            oname = str(other)
        out.name = "(" + str(oname) + "*" + new_name + ")"
        return out

    def __mul__(self, other):

        t1 = self.deepcopy()
        t2 = other

        # handle special case of "other" being a number
        if isinstance(t2, numbers.Number):
            t1.yaxis.data = t1.yaxis.data * t2
            t1._name = t1._name + "*" + str(t2)
            return t1

        # handle special case of "other" being a numpy array
        if isinstance(t2, numpy.ndarray):
            t1.yaxis.data = t1.yaxis.data * t2
            t1._name = "(" + t1._name + "*ndarray" + ")"
            return t1

        # check length
        if (
            t2.yaxis.data.size > 1
            and t1.yaxis.data.size > 1
            and t1.yaxis.data.size != t2.yaxis.data.size
        ):
            raise Exception(
                "Can only multiply objects of same length: "
                + str(t1.size)
                + " != "
                + str(t2.size())
            )

        # error propagation
        y1 = t1.yaxis.data.squeeze()
        y2 = t2.yaxis.data.squeeze()
        dy1 = t1.yaxis.ddata.squeeze()
        dy2 = t2.yaxis.ddata.squeeze()
        dy = numpy.sqrt((y2 * dy1) ** 2 + (y1 * dy2) ** 2 + (dy1 * dy2) ** 2)

        # multiply data
        t1.yaxis.data = y1 * y2
        t1.yaxis.units *= t2.yaxis.units

        # set error data
        t1.yaxis.ddata = dy

        # handle name
        t1.name = "(" + t1.name + "*" + t2.name + ")"

        return t1
