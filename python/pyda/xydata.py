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

from pathlib import Path
import uuid
from pyda.mixins import _xydata_diff, _xydata_plotter, _xydata_operators, _xydata_dsp
import pyda
from pyda.utils.axis import Axis
from pyda.utils.unit import Unit
import copy
import numpy
import h5py
import numbers


class XYData(
    _xydata_plotter.XYDataPlotter,
    _xydata_diff.XYDataDiff,
    _xydata_operators.XYDataOperators,
    _xydata_dsp.XYDataDSP,
    pyda.ydata.YData,
):
    """
    A class to encapsulate a set of time-series data.

    """

    def __init__(
        self,
        name: str = "XYData",
        description: str = "",
        xaxis: object = None,
        yaxis: object = None,
        xunits: str = "",
        yunits: str = "",
        xname: str = "X-Values",
        yname: str = "Y-Values",
    ) -> None:
        """

        Create a TSData object

        :param name:
        :param description:
        :param xaxis:
        :param yaxis:
        :param xunits:
        :param yunits:
        :param xname:
        :param yname:
        """

        if xaxis is None:
            xaxis = Axis()

        if yaxis is None:
            yaxis = Axis()

        # defaults
        self.xaxis = xaxis
        self.yaxis = yaxis
        self.id = uuid.uuid4()  # ensure we have a new UUID
        self.name = name
        self.description = description
        self.marker = None
        self.linestyle = None
        self.color = None
        self.linewidth = None

        # Some consistency checks
        if (
            not self._xaxis is None
            and self._xaxis.data.size == 0
            and self._yaxis.data.size != 0
        ):
            raise Exception("Please specify an x-axis the same length as the y-axis")

        # Check size of axes
        if (
            not self._yaxis is None
            and not self._xaxis is None
            and self._yaxis.isempty()
            and not self._xaxis.isempty()
        ):
            self._yaxis = Axis(data=numpy.zeros(shape=self._xaxis.data.shape))

        # set units on axes
        self._xaxis.units = xunits
        self._yaxis.units = yunits

        # axis names
        self._xaxis.name = xname
        self._yaxis.name = yname

    # ----------------------------------------------------
    # Constructors
    # ----------------------------------------------------

    @classmethod
    def from_txt_file(cls, filename=""):
        """
        Very simple method to read a two-column text file.

        :param filename:
        :return:
        """
        if not filename:
            raise Exception("Please specify a file to load from")

        print("Loading from " + filename + "...")

        x = numpy.loadtxt(filename, usecols=0)
        y = numpy.loadtxt(filename, usecols=1)

        obj = XYData(xaxis=x, yaxis=y, name=filename)
        return obj

    @classmethod
    def from_complex_txt_file(cls, filename=""):
        """
        Very simple method to read a three-column text file, frequency, real, imag.

        :param filename:
        :return:
        """
        if not filename:
            raise Exception("Please specify a file to load from")

        print("Loading from " + filename + "...")

        x = numpy.loadtxt(filename, usecols=0)
        re = numpy.loadtxt(filename, usecols=1)
        im = numpy.loadtxt(filename, usecols=2)
        y = re + 1j * im

        obj = XYData(xaxis=x, yaxis=y, name=filename)
        return obj

    # ----------------------------------------------------
    # Class Methods
    # ----------------------------------------------------

    def max(self):
        """
        Returns a new object with the max of the input yaxis data.

        :return:
        """

        xy = self.deepcopy()

        xy.yaxis = numpy.amax(xy.yaxis.data)

        idx = numpy.argmax(self.yaxis.data)
        xy.xaxis.data = xy.xaxis.data[idx]

        if len(xy.xaxis.ddata) > 1:
            xy.xaxis.ddata = xy.xaxis.ddata[idx]

        if len(xy.yaxis.ddata) > 1:
            xy.yaxis.ddata = xy.yaxis.ddata[idx]

        xy.name = "max(" + xy.name + ")"
        return xy

    def min(self):
        """
        Returns a new object with the min of the input yaxis data.

        :return:
        """

        xy = self.deepcopy()

        xy.yaxis = numpy.amin(xy.yaxis.data)

        idx = numpy.argmin(self.yaxis.data)
        xy.xaxis.data = xy.xaxis.data[idx]

        if len(xy.xaxis.ddata) > 1:
            xy.xaxis.ddata = xy.xaxis.ddata[idx]

        if len(xy.yaxis.ddata) > 1:
            xy.yaxis.ddata = xy.yaxis.ddata[idx]

        xy.name = "min(" + xy.name + ")"
        return xy

    def mean(self):
        """
        Returns a new object with the mean of the input x and yaxis data.

        :return:
        """

        xy = self.deepcopy()
        xy.xaxis = self.xaxis.mean()
        xy.yaxis = self.yaxis.mean()
        xy.name = "mean(" + self.name + ")"
        return xy

    def real(self):
        """
        Returns a new object with the real part of the input x and yaxis data.

        :return:
        """

        xy = self.deepcopy()
        xy.yaxis = self.yaxis.real()
        xy.name = "real(" + self.name + ")"
        return xy

    def imag(self):
        """
        Returns a new object with the imaginary part of the input x and yaxis data.

        :return:
        """

        xy = self.deepcopy()
        xy.yaxis = self.yaxis.imag()
        xy.name = "imag(" + self.name + ")"
        return xy

    def conj(self):
        """
        Returns a new object with the conjugate of the input x and yaxis data.

        :return:
        """

        xy = self.deepcopy()
        xy.yaxis = self.yaxis.conj()
        xy.name = "imag(" + self.name + ")"
        return xy

    # ----------------------------------------------------
    # Methods
    # ----------------------------------------------------

    def save(self, filename=None):

        # # check if the filename is a Posix path
        # if filename is None:
        #     raise Exception('Please specify a filename to save to')
        # else:
        #     if isinstance(filename, str):
        #         filename = filename.strip()
        #     elif isinstance(filename, Path):
        #         filename = str(filename)
        #     else:
        #         raise Exception("Filename must be a string or a Path object")

        if not filename.endswith(".pyda"):
            filename += ".pyda"

        with h5py.File(filename, "w") as f:
            self._add_to_hd5f_structure(f)

    @classmethod
    def load(cls, filename=""):
        """
        Load pyda object from disk.

        :param filename:
        :return:
        """
        if not filename.endswith(".pyda"):
            filename += ".pyda"

        # print("Loading " + filename + "...")

        with h5py.File(filename, "r") as f:
            if not f:
                raise Exception("Failed to load file at " + filename)

            return cls._from_hd5f_structure(hd5f_file=f)

    @classmethod
    def _from_hd5f_structure(cls, hd5f_file=None):
        xy = XYData()
        group_name = "XYData"

        # we can check the saved file version and do any actions
        FILE_PYDA_FILE_VERSION = hd5f_file[group_name].attrs["PYDA_FILE_VERSION"]
        if FILE_PYDA_FILE_VERSION < pyda.PYDA_FILE_VERSION:
            pass

        xy.name = hd5f_file[group_name].attrs["name"]
        xy.id = hd5f_file[group_name].attrs["id"]
        xy.xaxis = Axis._from_hd5f_structure(
            hd5f_file=hd5f_file, group_name=group_name + "/xaxis"
        )
        xy.yaxis = Axis._from_hd5f_structure(
            hd5f_file=hd5f_file, group_name=group_name + "/yaxis"
        )
        # xy.dxaxis = Axis._from_hd5f_structure(hd5f_file=hd5f_file, group_name=group_name+'/dxaxis')
        # xy.dyaxis = Axis._from_hd5f_structure(hd5f_file=hd5f_file, group_name=group_name+'/dyaxis')
        return xy

    def _add_to_hd5f_structure(self, hd5f_file=None):
        group_name = "XYData"
        g = hd5f_file.create_group(group_name)
        g.attrs["name"] = self.name
        g.attrs["description"] = self.description
        g.attrs["PYDA_FILE_VERSION"] = pyda.PYDA_FILE_VERSION
        # g.create_dataset('fs', data=self.fs())
        g.attrs["id"] = str(self.id)
        self.xaxis._add_to_hd5f_structure(
            hd5f_file=hd5f_file, group_name=group_name + "/xaxis"
        )
        self.yaxis._add_to_hd5f_structure(
            hd5f_file=hd5f_file, group_name=group_name + "/yaxis"
        )
        # self.dxaxis._add_to_hd5f_structure(hd5f_file=hd5f_file, group_name=group_name+'/dxaxis')
        # self.dyaxis._add_to_hd5f_structure(hd5f_file=hd5f_file, group_name=group_name+'/dyaxis')

    # ----------------------------------------------------
    # Methods
    # ----------------------------------------------------

    def size(self):
        """
        Returns the size of the yaxis data.

        :return:
        """
        return self.yaxis.data.size

    def xunitsLabel(self):
        s = self.xaxis.units.toLabel()
        return s

    def yunitsLabel(self):
        s = self.yaxis.units.toLabel()
        return s

    def xunits(self) -> Unit:
        """
        Returns the x-axis units of this time-series object as a string
        :return:
        """
        return self.xaxis.units

    def yunits(self) -> Unit:
        """
        Returns the y-axis units of this time-series object as a string
        :return:
        """
        return self.yaxis.units

    def xdata(self) -> numpy.ndarray:
        """
        Returns the x-axis data of this time-series object.

        :return:
        """
        return self.xaxis.data

    def ydata(self) -> numpy.ndarray:
        """
        Returns the y-axis data of this time-series object.

        :return:
        """
        return self.yaxis.data

    def export(self, filename=""):

        if not filename:
            raise Exception("Please specify a file to export to")

        N = self.yaxis.data.size
        print("Exporting data of length " + str(N) + " to " + filename + "...")
        x = numpy.reshape(self.xaxis.data.data, (N,))
        y = numpy.reshape(self.yaxis.data.data, (N,))
        xy = numpy.vstack((x, y)).T
        numpy.savetxt(filename, xy)

    def deepcopy(self):
        return copy.deepcopy(self)

    # def char(self):
    #     "Returns a short string representation of the object"
    #     return self.mpackage + "." + self.mclass + "." + self.mname

    def display(self):
        """Prints a string representation of this object to the terminal."""
        print(str(self))

    # ----------------------------------------------------
    # Overrides
    # ----------------------------------------------------

    def __str__(self):
        """

        :return:
        """
        s = "-------- XYData ---------\n"
        s += "  name: " + self._name + "\n"
        s += "  uuid: " + str(self.id) + "\n"
        s += (
            " xaxis: "
            + self.xaxis.name
            + "="
            + str(self.xaxis.data.shape)
            + self.xunits().char()
            + "\n"
        )
        s += (
            " yaxis: "
            + self.yaxis.name
            + "="
            + str(self.yaxis.data.shape)
            + self.yunits().char()
            + "\n"
        )
        s += (
            "    dx: "
            + self.xaxis.name
            + "="
            + str(self.xaxis.ddata.shape)
            + self.xunits().char()
            + "\n"
        )
        s += (
            "    dy: "
            + self.yaxis.name
            + "="
            + str(self.yaxis.ddata.shape)
            + self.yunits().char()
            + "\n"
        )

        s += "\n-----------------------------"
        return s

    # ----------------------------------------------------
    # Properties
    # ----------------------------------------------------

    # name
    @property
    def name(self):
        return self._name

    @name.setter
    def name(self, val=None):
        self._name = val

    @name.deleter
    def name(self):
        del self._name

    # xaxis
    @property
    def xaxis(self):
        return self._xaxis

    @xaxis.setter
    def xaxis(self, val=None):

        # Is this really necessary here to check this? Can we just pass val to Axis() and handle that inside
        #  the Axis class?
        if val is not None:
            # ensure we have Axis objects
            if isinstance(val, numpy.ndarray) or isinstance(val, list):
                val = Axis(data=val)
            elif isinstance(val, numbers.Number):
                val = Axis(data=numpy.array([val]))
            elif isinstance(val, pyda.xydata.XYData):
                val = Axis(data=val.xdata())
            elif isinstance(val, pyda.ydata.YData):
                val = Axis(data=val.ydata())
            elif isinstance(val, Axis):
                pass
            else:
                raise Exception(
                    "The xaxis property must be an numpy.ndarray or an pyda.Axis object."
                )

        self._xaxis = val

    @xaxis.deleter
    def xaxis(self):
        del self._xaxis

    # yaxis
    @property
    def yaxis(self):
        return self._yaxis

    @yaxis.setter
    def yaxis(self, val=None):

        # Is this really necessary here to check this? Can we just pass val to Axis() and handle that inside
        #  the Axis class?
        if not val is None:
            # ensure we have Axis objects
            if isinstance(val, numpy.ndarray) or isinstance(val, list):
                val = Axis(data=val)
            elif isinstance(val, numbers.Number):
                val = Axis(data=numpy.array([val]))
            elif isinstance(val, pyda.ydata.YData):
                val = Axis(data=val.ydata())
            elif isinstance(val, Axis):
                pass
            else:
                raise Exception(
                    "The yaxis property must be an numpy.ndarray or an pyda.Axis object."
                )

        self._yaxis = val

    @yaxis.deleter
    def yaxis(self):
        del self._yaxis

    # # dxaxis
    # @property
    # def dxaxis(self):
    #     return self._dxaxis
    #
    # @dxaxis.setter
    # def dxaxis(self, val=None):
    #
    #     if not val is None:
    #         # ensure we have Axis objects
    #         if isinstance(val, numpy.ndarray):
    #             val = Axis(data=val)
    #         elif isinstance(val, numbers.Number):
    #             val = Axis(data=numpy.array([val]))
    #         elif isinstance(val, Axis):
    #             pass
    #         else:
    #             raise Exception('The dxaxis property must be an numpy.ndarray or an pyda.Axis object.')
    #
    #     self._dxaxis = val
    #
    # @dxaxis.deleter
    # def dxaxis(self):
    #     del self._dxaxis
    #
    # # dyaxis
    # @property
    # def dyaxis(self):
    #     return self._dyaxis
    #
    # @dyaxis.setter
    # def dyaxis(self, val=None):
    #
    #     if not val is None:
    #         # ensure we have Axis objects
    #         if isinstance(val, numpy.ndarray):
    #             val = Axis(data=val)
    #         elif isinstance(val, numbers.Number):
    #             val = Axis(data=numpy.array([val]))
    #         elif isinstance(val, Axis):
    #             pass
    #         else:
    #             raise Exception('The dyaxis property must be an numpy.ndarray or an pyda.Axis object.')
    #
    #     self._dyaxis = val
    #
    # @dyaxis.deleter
    # def dyaxis(self):
    #     del self._dyaxis
