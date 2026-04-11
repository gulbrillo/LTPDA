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


import numbers

import pyda
from pyda.utils.unit import Unit

from pyda.exceptions.typeexceptions import WrongDataTypeException
from pyda.exceptions.sizeexceptions import DataSizeException

import numpy
import copy


class Axis:
    """
    This class encapsulates the concept of an 'axis'. An axis has the following properties:

         data - a vector or matrix of data values (instance of numpy.ndarray)
        ddata - a vector or matrix of errors associated with the data values (instance of numpy.ndarray)
        units - the units for this data (an instance of pyda.Unit)
         name - a name/label for this axis

    """

    def __init__(
        self,
        data=numpy.empty(shape=(0, 0)),
        ddata=numpy.array([0]),
        units="",
        name="Value",
    ):
        """
        Construct a new Axis object. The following constructors are recognized:

        Usage:
                a = Axis()
                a = Axis(data)
                a = Axis(data, ddata)
                a = Axis(data, ddata, units)
                a = Axis(data, ddata, units, name)

        """

        self.data = data
        self.ddata = ddata
        self.units = units
        self.name = name

    # ----------------------------------------------------
    # Properties
    # ----------------------------------------------------
    # name
    @property
    def name(self):
        return self._name

    @name.setter
    def name(self, val=None):
        if not isinstance(val, str):
            raise WrongDataTypeException("The name must be a string")
        self._name = val

    @name.deleter
    def name(self):
        del self._name

    # units
    @property
    def units(self):
        return self._units

    @units.setter
    def units(self, val=None):

        # ensure we have Unit objects
        if isinstance(val, str):
            val = pyda.utils.unit.Unit(val)

        if not isinstance(val, pyda.utils.unit.Unit):
            raise WrongDataTypeException(
                "The units must be a Unit object, not a " + str(type(val))
            )

        self._units = val

    @units.deleter
    def units(self):
        del self._units

    # data
    @property
    def data(self):
        return self._data

    @data.setter
    def data(self, data):
        if isinstance(data, numpy.ndarray):
            self._data = data
        elif isinstance(data, pyda.utils._pyda_obj._pyda_obj):
            self._data = data.ydata()
        elif isinstance(data, list):
            self._data = numpy.array(data)
        elif isinstance(data, numbers.Number):
            self._data = numpy.array([data])
        else:
            raise WrongDataTypeException(
                "The data must be a numpy ndarray, a list or values, or a number, "
                "not a " + repr(data)
            )

    # ddata
    @property
    def ddata(self):
        return self._ddata

    @ddata.setter
    def ddata(self, ddata):

        # check input data type
        if isinstance(ddata, numpy.ndarray):
            new_ddata = ddata
        elif isinstance(ddata, list):
            new_ddata = numpy.array([ddata])
        elif isinstance(ddata, pyda.utils._pyda_obj._pyda_obj):
            new_ddata = ddata.ydata()
        elif isinstance(ddata, numbers.Number):
            new_ddata = numpy.array([ddata])
        else:
            raise DataSizeException(
                "The error data (ddata) must be a numpy ndarray, a list or values, or a number, "
                "not a " + repr(ddata)
            )
        # check error vector size against data size
        if (
            new_ddata.size > 0
            and numpy.shape(new_ddata)[0] > 2
            and new_ddata.size != self.data.size
        ):
            raise DataSizeException(
                "The error data (ddata) must be length 1 or the same length as the data"
            )

        self._ddata = new_ddata

    # ----------------------------------------------------
    # Methods
    # ----------------------------------------------------

    def simplifyUnits(self):
        nu = self.units.simplify()
        self.units = nu

    def toSI(self, exceptions=[]):
        """
        Convert the units of this axis to SI units. This is done by calling the
        toSI() method of the Unit object.
        :param exceptions: A list of exceptions to the conversion.
        :return:
        """
        nu = self.units.toSI(exceptions=exceptions)
        self.units = nu

    def isempty(self):
        if self.data.size == 0:
            return True
        else:
            return False

    def deepcopy(self):
        """Returns a deep copy of the axis object"""
        return copy.deepcopy(self)

    def display(self):
        """Prints a string representation of this object to the terminal."""
        print(str(self))

    # ----------------------------------------------------
    # Operators
    # ----------------------------------------------------

    def _compare(self, other, op):
        """
        Helper method to handle comparison operations.

        :param other: The other Axis object to compare with
        :param op: The comparison operator function (e.g., numpy.greater, numpy.less)
        :return: A new Axis object with the filtered data
        """
        a = self.deepcopy()

        # if self has length 1, then return a subset of the other
        if a.data.size == 1 and other.data.size > 1:
            mask = op(a.data, other.data)
            a.data = other.data[mask]
            # if ddata is same length as data
            if a.ddata.size == other.ddata.size and a.ddata.size > 1:
                a.ddata = other.ddata[mask]
            a.units = other.units
            return a

        # if other has length 1, then return a subset of self
        if other.data.size == 1 and a.data.size > 1:
            mask = op(a.data, other.data)
            a.data = a.data[mask]
            if a.ddata.size == other.ddata.size and a.ddata.size > 1:
                a.ddata = a.ddata[mask]
            return a

        # if both have length 1, then return a subset of self
        if a.data.size == 1 and other.data.size == 1:
            mask = op(a.data, other.data)
            a.data = a.data[mask]
            if a.ddata.size == other.ddata.size and a.ddata.size > 1:
                a.ddata = a.ddata[mask]
            return a

        # if both have length > 1, then return a subset of self
        if a.data.size > 1 and other.data.size > 1 and a.data.size != other.data.size:
            raise Exception(
                "Can only compare objects of same length: "
                + str(a.data.size)
                + " != "
                + str(other.data.size)
            )
        if a.data.size > 1 and other.data.size > 1:
            mask = op(a.data, other.data)
            a.data = a.data[mask]
            if a.ddata.size == other.ddata.size and a.ddata.size > 1:
                a.ddata = a.ddata[mask]
            a.units = other.units
            return a

        return None

    def __gt__(self, other):
        """
        Greater than comparison operator.

        :param other: The other Axis object to compare with
        :return: A new Axis object with the filtered data
        """
        return self._compare(other, numpy.greater)

    def __lt__(self, other):
        """
        Less than comparison operator.

        :param other: The other Axis object to compare with
        :return: A new Axis object with the filtered data
        """
        return self._compare(other, numpy.less)

    def __ge__(self, other):
        """
        Greater than or equal comparison operator.

        :param other: The other Axis object to compare with
        :return: A new Axis object with the filtered data
        """
        return self._compare(other, numpy.greater_equal)

    def __le__(self, other):
        """
        Less than or equal comparison operator.

        :param other: The other Axis object to compare with
        :return: A new Axis object with the filtered data
        """
        return self._compare(other, numpy.less_equal)

    def __eq__(self, other):
        """
        Equal comparison operator.

        :param other: The other Axis object to compare with
        :return: A new Axis object with the filtered data
        """
        return self._compare(other, numpy.equal)

    def __ne__(self, other):
        """
        Not equal comparison operator.

        :param other: The other Axis object to compare with
        :return: A new Axis object with the filtered data
        """
        return self._compare(other, numpy.not_equal)

    def real(self):
        a = self.deepcopy()

        # error
        v = a.data
        d = numpy.real(a.ddata)

        # data
        v = numpy.real(v)

        # output
        a.data = v
        a.ddata = d

        return a

    def imag(self):
        a = self.deepcopy()

        # error
        v = a.data
        d = numpy.imag(a.ddata)

        # data
        v = numpy.imag(v)

        # output
        a.data = v
        a.ddata = d

        return a

    def conj(self):
        a = self.deepcopy()

        # error
        v = a.data
        d = numpy.conjugate(a.ddata)

        # data
        v = numpy.conjugate(v)

        # output
        a.data = v
        a.ddata = d

        return a

    def mean(self):
        a = self.deepcopy()

        # error
        v = a.data
        d = numpy.std(v) / numpy.sqrt(v.size)

        # data
        v = numpy.mean(v)

        # output
        a.data = v
        a.ddata = d

        return a

    def int(self):
        a = self.deepcopy()
        a.data = numpy.int32(a.data)
        return a

    def float(self):
        a = self.deepcopy()
        a.data = numpy.float64(a.data)
        return a

    def log10(self):
        a = self.deepcopy()

        # error
        dy = a.ddata
        if dy.size > 0:
            a.ddata = numpy.abs(1 / (a.data * numpy.log10(10))) * dy

        # data
        a.data = numpy.log10(a.data)

        # units
        a.units = Unit()

        return a

    def exp(self):
        a = self.deepcopy()

        # error
        dy = a.ddata
        if dy.size > 0:
            a.ddata = numpy.abs(numpy.exp(a.data)) * dy

        # data
        a.data = numpy.exp(a.data)

        # units
        a.units = Unit()

        return a

    def sqrt(self):
        a = self.deepcopy()

        # error
        dy = a.ddata
        if dy.size > 0:
            a.ddata = numpy.abs(1.0 / (2.0 * numpy.sqrt(abs(a.data)))) * dy

        # data
        a.data = numpy.sqrt(a.data)

        # units
        a.units = a.units.sqrt()

        return a

    def cos(self):
        a = self.deepcopy()

        # error
        dy = a.ddata
        if dy.size > 0:
            a.ddata = numpy.abs(numpy.sin(a.data)) * dy

        # data
        a.data = numpy.cos(a.data)

        # units
        a.units = ""

        return a

    def sin(self):
        a = self.deepcopy()

        # error
        dy = a.ddata
        if dy.size > 0:
            a.ddata = numpy.abs(numpy.cos(a.data)) * dy

        # data
        a.data = numpy.sin(a.data)

        # units
        a.units = ""

        return a

    def abs(self):
        a = self.deepcopy()
        a.data = numpy.abs(a.data)
        return a

    # ----------------------------------------------------
    # Overrides
    # ----------------------------------------------------

    # def __deepcopy__(self, memo):
    #
    #     deepcopy_method = self.__deepcopy__
    #     self.__deepcopy__ = None
    #     cp = deepcopy(self, memo)
    #     self.__deepcopy__ = deepcopy_method
    #     cp.__deepcopy__ = deepcopy_method
    #
    #
    #     p = Axis(self.data.__deepcopy__(), self.ddata.__deepcopy__(), self.units.deepcopy(), self.name)
    #     return p

    def __str__(self):
        s = "-------- Axis ---------\n"
        s += " name: " + self.name + "\n"
        s += " data: " + str(self.data.shape) + "\n"

        # display first 10 samples
        kk = 0
        d = self.data.flat
        if self.data.size > 0:
            s += "       "
            while kk < 10 and kk < self.data.size:
                s += str(d[kk]) + ", "
                kk += 1
            s = s[0:-2]
            if self.data.size > 10:
                s += " ..."
            s += "\n"

        s += "ddata: " + str(self.ddata.shape) + "\n"
        s += "units: " + self.units.char() + "\n"
        s += "\n-----------------------------"
        return s

    def _add_to_hd5f_structure(self, hd5f_file=None, group_name=""):
        # print("creating group " + group_name)
        g = hd5f_file.create_group(group_name)
        g.attrs["name"] = self.name
        g.attrs["units"] = self.units.char()
        g.create_dataset("data", data=self.data)
        g.create_dataset("ddata", data=self.ddata)
        return g

    def __rmul__(self, other):
        out = self.__mul__(other)
        return out

    def __mul__(self, other):

        a1 = self.deepcopy()
        a2 = other

        # check length
        if a1.data.size > 1 and a2.data.size > 1 and a1.data.size != a2.data.size:
            raise Exception(
                "Can only multiply objects of same length: "
                + str(a1.data.size)
                + " != "
                + str(a2.data.size)
            )

        # error propagation
        y1 = a1.data
        y2 = a2.data
        dy1 = a1.ddata
        dy2 = a2.ddata
        dy = numpy.sqrt((y2 * dy1) ** 2 + (y1 * dy2) ** 2 + (dy1 * dy2) ** 2)

        # multiply data
        a1.data = y1 * y2
        a1.ddata = dy
        a1.units *= a2.units

        return a1

    @classmethod
    def _from_hd5f_structure(cls, hd5f_file=None, group_name=""):
        ax = Axis()
        ax.name = hd5f_file[group_name].attrs["name"]
        ax.units = Unit(hd5f_file[group_name].attrs["units"])
        ax.data = numpy.array(hd5f_file[group_name + "/data"])
        ax.ddata = numpy.array(hd5f_file[group_name + "/ddata"])
        return ax
