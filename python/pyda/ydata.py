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
import uuid

import pyda

# import pyda.xydata

from pyda.utils.axis import Axis
from pyda.utils.unit import Unit
import copy
import numpy
import matplotlib.pyplot as plt

import h5py
from pyda.utils._pyda_obj import _pyda_obj
from pyda.mixins._ydata_operators import YDataOperators


class YData(_pyda_obj, YDataOperators):
    """
    A class to encapsulate a set of time-series data.

    """

    def __init__(
        self,
        name: str = "YData",
        description: str = "",
        yaxis: object = None,
        yunits: object = "",
        yname: str = "Y-Values",
    ) -> None:
        """

        Create a TSData object

        :param name:
        :param description:
        :param yaxis:
        :param yunits:
        :param yname:
        """

        super().__init__()

        if yaxis is None:
            yaxis = Axis()

        # defaults
        self.yaxis = yaxis
        # self.id = uuid.uuid4()  # ensure we have a new UUID
        self.name = name
        self.description = description
        self.marker = None
        self.linestyle = None
        self.color = None
        self.linewidth = None

        # set units on axes
        self._yaxis.units = yunits

        # axis names
        self._yaxis.name = yname

    # ----------------------------------------------------
    # Class Methods
    # ----------------------------------------------------
    @classmethod
    def randn(cls, ndata=10, name="", yunits=""):
        """
        Generate a series of random values. Values are generated with numpy.random.randn.

        :param ndata:
        :param name:
        :param yunits:
        :return:
        """
        y = YData(
            yaxis=numpy.random.randn(
                int(ndata),
            ),
            name=name,
            yunits=yunits,
        )
        return y

    @classmethod
    def ones(cls, ndata=10, name="", yunits=""):
        """
        Generate a series of ones.

        :param ndata:
        :param name:
        :param yunits:
        :return:
        """
        y = YData(
            yaxis=numpy.ones(
                ndata,
            ),
            name=name,
            yunits=yunits,
        )
        return y

    @classmethod
    def from_txt_file(cls, filename=""):
        """
        Very simple method to read a single-column text file.

        :param filename:
        :return:
        """
        if not filename:
            raise Exception("Please specify a file to load from")

        print("Loading from " + filename + "...")

        y = numpy.loadtxt(filename, usecols=0)

        obj = YData(yaxis=y, name=filename)
        return obj

    # ----------------------------------------------------
    # Methods
    # ----------------------------------------------------

    def plot(self, *args, **kwargs):
        """
        Plot YData objects on linear axes. For complex objects, magnitude/phase subplots will be generated.

        ErrorType = "bar" or "area"

        :param args: List of objects to plot
        :param kwargs: Additional arguments for plot configuration. Options: FigSize, ErrorType...
        :return: a list with (figure handle, list of axis handles, list of errorbar handles)
        """

        h = self._plot(args, kwargs)

        return h

    def _plot(self, args, kwargs):

        ts = self

        # Process arguments (THERE MUST BE A MORE NATURAL WAY TO DO THIS!)
        FigSize = None
        ShowErrors = False
        ErrorType = "bar"
        for key, value in kwargs.items():
            if key.lower() == "figsize":
                FigSize = value

            if key.lower() == "showerrors":
                ShowErrors = True

            if key.lower() == "errortype":
                ErrorType = value

        # make plot
        fh = plt.figure(figsize=FigSize)

        # collect axis errorbar handles
        ebhs = []
        axhs = []

        if any(numpy.iscomplex(ts.ydata())):
            print("plotting complex data...")

            f, (ax1, ax2) = plt.subplots(2, 1)
            axhs.append(ax1)
            axhs.append(ax2)

            if ShowErrors:
                ebh1, ebh2 = YData._plot_complex_object_with_errors(
                    ts, ax1, ax2, ErrorType
                )
                ebhs.append(ebh1)
                ebhs.append(ebh2)

                for t in args:
                    if not isinstance(t, YData):
                        print("! Skipping non YData " + str(t))
                    else:
                        ebh1, ebh2 = YData._plot_complex_object_with_errors(
                            t, ax1, ax2, ErrorType
                        )
                        ebhs.append(ebh1)
                        ebhs.append(ebh2)

            else:
                YData._plot_complex_object(ts, ax1, ax2)

                for t in args:
                    if not isinstance(t, YData):
                        print("! Skipping non YData " + str(t))
                    else:
                        YData._plot_complex_object(t, ax1, ax2)

            ax1.set_ylabel(ts.yaxis.name + " " + ts.yunitsLabel())
            ax1.grid(visible=True)
            ax1.legend()
            ax2.grid(visible=True)
            ax2.legend()
            ax2.set_ylabel("Phase (º)")
            ax2.set_xlabel("Index")

        else:
            if ShowErrors:
                f, ax1 = plt.subplots(1, 1)
                axhs.append(ax1)

                ebh1 = YData._plot_object_with_errors(ts, ax1, ErrorType)
                ebhs.append(ebh1)

                for t in args:
                    if not isinstance(t, YData):
                        print("! Skipping non YData " + str(t))
                    else:
                        ebh1 = YData._plot_object_with_errors(t, ax1, ErrorType)
                        ebhs.append(ebh1)

                ax1.set_xlabel("Index")
                ax1.set_ylabel(ts.yaxis.name + " " + ts.yunitsLabel())
                ax1.grid(visible=True)
                ax1.legend()

            else:
                f, ax1 = plt.subplots(1, 1)
                axhs.append(ax1)

                YData._plot_object(ts, ax1)

                for t in args:
                    if not isinstance(t, YData):
                        print("! Skipping non YData " + str(type(t)))
                    else:
                        YData._plot_object(t, ax1)

                ax1.set_xlabel("Index")
                ax1.set_ylabel(ts.yaxis.name + " " + ts.yunitsLabel())
                ax1.grid(visible=True)
                ax1.legend()

        return [fh, axhs, ebhs]

    @classmethod
    def _plot_complex_object(cls, ts, ax1, ax2):

        x = numpy.arange(start=0, stop=ts.ydata().size, step=1)

        ax1.plot(
            x,
            numpy.abs(ts.ydata()),
            label=ts.name,
            color=ts.color,
            linestyle=ts.linestyle,
            linewidth=ts.linewidth,
            marker=ts.marker,
        )
        ax2.plot(
            x,
            numpy.angle(ts.ydata()) * 180.0 / numpy.pi,
            label=ts.name,
            color=ts.color,
            linestyle=ts.linestyle,
            linewidth=ts.linewidth,
            marker=ts.marker,
        )

    @classmethod
    def _plot_object(cls, ts, ax1):

        x = numpy.arange(start=0, stop=ts.ydata().size, step=1)
        ax1.plot(
            x,
            ts.ydata(),
            label=ts.name,
            color=ts.color,
            linestyle=ts.linestyle,
            linewidth=ts.linewidth,
            marker=ts.marker,
        )

    @classmethod
    def _plot_object_with_errors(cls, ts, ax1, ErrorType):

        # errorbar() doesn't interpret a list of length 1 as a scalar :(
        yerr = ts.yaxis.ddata
        if yerr.size == 1:
            yerr = yerr[0]
        elif yerr.size == 0:
            yerr = 0

        y = ts.ydata()
        x = numpy.arange(start=0, stop=y.size, step=1)

        ebh1 = None

        if ErrorType.lower() == "bar":
            ebh1 = ax1.errorbar(
                x,
                y,
                yerr=yerr,
                label=ts.name,
                color=ts.color,
                linestyle=ts.linestyle,
                linewidth=ts.linewidth,
                marker=ts.marker,
            )
        elif ErrorType.lower() == "area":
            (lh,) = ax1.plot(
                x,
                y,
                label=ts.name,
                color=ts.color,
                linestyle=ts.linestyle,
                linewidth=ts.linewidth,
                marker=ts.marker,
            )
            ax1.fill_between(x, y - yerr, y + yerr, facecolor=lh.get_color(), alpha=0.2)
        else:
            raise Exception("Unknown ErrorType " + ErrorType)

        return ebh1

    @classmethod
    def _plot_complex_object_with_errors(cls, ts, ax1, ax2, ErrorType):

        yerr = ts.yaxis.ddata
        if yerr.size == 1:
            yerr = yerr[0]
        elif yerr.size == 0:
            yerr = 0

        y1 = numpy.abs(ts.ydata())
        y2 = numpy.angle(ts.ydata()) * 180.0 / numpy.pi
        x = numpy.arange(start=0, stop=y1.size, step=1)

        yerr1 = numpy.abs(yerr)
        yerr2 = numpy.angle(yerr) * 180.0 / numpy.pi

        ebh1 = None
        ebh2 = None

        if ErrorType.lower() == "bar":
            ebh1 = ax1.errorbar(
                x,
                y1,
                yerr=yerr1,
                label=ts.name,
                color=ts.color,
                linestyle=ts.linestyle,
                linewidth=ts.linewidth,
                marker=ts.marker,
            )
            ebh2 = ax2.errorbar(
                x,
                y2,
                yerr=yerr2,
                label=ts.name,
                color=ts.color,
                linestyle=ts.linestyle,
                linewidth=ts.linewidth,
                marker=ts.marker,
            )
        elif ErrorType.lower() == "area":
            (lh,) = ax1.plot(
                x,
                y1,
                label=ts.name,
                color=ts.color,
                linestyle=ts.linestyle,
                linewidth=ts.linewidth,
                marker=ts.marker,
            )
            ax1.fill_between(
                x, y1 - yerr, y1 + yerr, facecolor=lh.get_color(), alpha=0.2
            )
            (lh,) = ax2.plot(
                x,
                y2,
                label=ts.name,
                color=ts.color,
                linestyle=ts.linestyle,
                linewidth=ts.linewidth,
                marker=ts.marker,
            )
            ax2.fill_between(
                x, y1 - yerr, y1 + yerr, facecolor=lh.get_color(), alpha=0.2
            )
        else:
            raise Exception("Unknown ErrorType " + ErrorType)

        return ebh1, ebh2

    def save(self, filename=""):

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

        print("Loading " + filename + "...")

        with h5py.File(filename, "r") as f:
            if not f:
                raise Exception("Failed to load file at " + filename)

            return cls._from_hd5f_structure(hd5f_file=f)

    @classmethod
    def _from_hd5f_structure(cls, hd5f_file=None):
        y = YData()
        group_name = "YData"

        # we can check the saved file version and do any actions
        FILE_PYDA_FILE_VERSION = hd5f_file[group_name].attrs["PYDA_FILE_VERSION"]
        if FILE_PYDA_FILE_VERSION < pyda.PYDA_FILE_VERSION:
            pass

        y.name = hd5f_file[group_name].attrs["name"]
        y.id = hd5f_file[group_name].attrs["id"]
        y.yaxis = Axis._from_hd5f_structure(
            hd5f_file=hd5f_file, group_name=group_name + "/yaxis"
        )
        return y

    def _add_to_hd5f_structure(self, hd5f_file=None):
        group_name = "YData"
        g = hd5f_file.create_group(group_name)
        g.attrs["name"] = self.name
        g.attrs["description"] = self.description
        g.attrs["PYDA_FILE_VERSION"] = pyda.PYDA_FILE_VERSION
        # g.create_dataset('fs', data=self.fs())
        g.attrs["id"] = str(self.id)
        self.yaxis._add_to_hd5f_structure(
            hd5f_file=hd5f_file, group_name=group_name + "/yaxis"
        )

    def max(self):
        """
        Returns a new object with the max of the input yaxis data.

        :return:
        """

        y = self.deepcopy()
        y.yaxis = numpy.amax(self.yaxis.data)
        idx = numpy.argmax(self.yaxis.data)

        if len(self.yaxis.ddata) > 0:
            y.yaxis.ddata = self.yaxis.ddata[idx]

        y.name = "max(" + self.name + ")"
        return y

    def min(self):
        """
        Returns a new object with the min of the input yaxis data.

        :return:
        """

        y = self.deepcopy()
        y.yaxis = numpy.amin(self.yaxis.data)
        idx = numpy.argmin(self.yaxis.data)

        if len(self.yaxis.ddata) > 0:
            y.yaxis.ddata = self.yaxis.ddata[idx]

        y.name = "min(" + self.name + ")"
        return y

    def mean(self):
        """
        Returns a new object with the mean of the input yaxis data.

        :return:
        """

        y = self.deepcopy()
        y.yaxis = self.yaxis.mean()
        y.name = "mean(" + self.name + ")"
        return y

    def abs(self):
        """
        Returns a new object with the absolute value of the input yaxis data.

        :return:
        """
        fs = self.deepcopy()
        fs.yaxis = fs.yaxis.abs()
        fs._name = "abs(" + fs._name + ")"
        return fs


    def int(self):

        fs = self.deepcopy()

        # sqrt data
        fs.yaxis = fs.yaxis.int()

        # handle name
        fs._name = "int(" + fs._name + ")"
        return fs

        return fs

    def float(self):

        fs = self.deepcopy()

        # sqrt data
        fs.yaxis = fs.yaxis.float()

        # handle name
        fs._name = "float(" + fs._name + ")"
        return fs

    def log10(self):
        """
        Returns a new object with the log10 of the input yaxis data.

        :return:
        """
        fs = self.deepcopy()

        # sqrt data
        fs.yaxis = fs.yaxis.log10()

        # handle name
        fs._name = "log10(" + fs._name + ")"
        return fs

    def exp(self):
        """
        Returns a new object with the exponential of the input yaxis data.

        :return:
        """
        fs = self.deepcopy()

        # sqrt data
        fs.yaxis = fs.yaxis.exp()

        # handle name
        fs._name = "exp(" + fs._name + ")"
        return fs

    def sqrt(self):
        """
        Returns a new object with the square-root of the input yaxis data.

        :return:
        """
        fs = self.deepcopy()

        # sqrt data
        fs.yaxis = fs.yaxis.sqrt()

        # handle name
        fs._name = "sqrt(" + fs._name + ")"
        return fs

    def cos(self):
        """
        Returns a new object with the cos of the input yaxis data.

        :return:
        """
        fs = self.deepcopy()

        # sqrt data
        fs.yaxis = fs.yaxis.cos()

        # handle name
        fs._name = "cos(" + fs._name + ")"
        return fs

    def sin(self):
        """
        Returns a new object with the sin of the input yaxis data.

        :return:
        """
        fs = self.deepcopy()

        # sqrt data
        fs.yaxis = fs.yaxis.sin()

        # handle name
        fs._name = "sin(" + fs._name + ")"
        return fs

    def toSI(self, exceptions=["Hz", "rad"]):
        self.yaxis.units = self.yaxis.units.toSI(exceptions=exceptions)
        return self

    # ----------------------------------------------------
    # Operators
    # ----------------------------------------------------

    def __rtruediv__(self, other):

        # print("*** YData rtruediv")

        t1 = self.deepcopy()
        t2 = other

        # handle special case of "other" being a number
        if isinstance(t2, numbers.Number):
            t1.yaxis.data = t2 / t1.yaxis.data
            t1._name = str(t2) + "/" + t1._name
            t1.yaxis.units = Unit() / t1.yaxis.units
            return t1

        # check length
        if (
            t1.size() != 1
            and t2.size() != 1
            and t1.yaxis.data.size != t2.yaxis.data.size
        ):
            raise Exception(
                "Can only divide objects of same length, or an object of length 1 by longer object, "
                "or a longer object by an object of length 1"
                ": " + str(t1.size) + " != " + str(t2.size())
            )

        # error propagation
        y1 = t1.yaxis.data
        y2 = t2.yaxis.data
        dy1 = t1.yaxis.ddata
        dy2 = t2.yaxis.ddata
        dy = numpy.sqrt(
            (dy1 / y2) ** 2
            + ((-y1 / y2 ** 2) * dy2) ** 2
            + ((y1 / y2 ** 3) * (dy2 ** 2)) ** 2
            + (((-1.0 / y2) ** 2) * dy1 * dy2) ** 2
        )

        # divide data
        t1.yaxis.data = y2 / y1
        t1.yaxis.units = t2.yaxis.units / t1.yaxis.units
        t1.yaxis.ddata = dy

        # name
        t1.name = t2.name + "/" + t1.name

        return t1

    def __truediv__(self, other):

        # print("*** YData truediv")

        t1 = self.deepcopy()
        t2 = other

        # handle special case of "other" being a number
        if isinstance(t2, numbers.Number):
            t1.yaxis.data = t1.yaxis.data / t2
            t1._name = t1._name + "/" + str(t2)
            return t1

        # check length
        if (
            t1.size() != 1
            and t2.size() != 1
            and t1.yaxis.data.size != t2.yaxis.data.size
        ):
            raise Exception(
                "Can only divide objects of same length, or an object of length 1 by longer object, "
                "or a longer object by an object of length 1"
                ": " + str(t1.size) + " != " + str(t2.size())
            )

        # error propagation
        y1 = t1.yaxis.data
        y2 = t2.yaxis.data
        dy1 = t1.yaxis.ddata
        dy2 = t2.yaxis.ddata
        dy = numpy.sqrt(
            (dy1 / y2) ** 2
            + ((-y1 / y2 ** 2) * dy2) ** 2
            + ((y1 / y2 ** 3) * (dy2 ** 2)) ** 2
            + (((-1.0 / y2) ** 2) * dy1 * dy2) ** 2
        )

        # divide data
        t1.yaxis.data = y1 / y2
        t1.yaxis.units /= t2.yaxis.units
        t1.yaxis.ddata = dy

        # name
        t1.name = t1.name + "/" + t2.name

        return t1

    def __rpow__(self, t1, modulo=None):
        power = self.deepcopy()
        pname = power.name

        # print("ydata/rpow")
        # print(t1)
        # print(power)

        # if we have number ** object, convert number to a YData
        if isinstance(t1, numbers.Number):
            t1 = YData(yaxis=1.0 * t1, name=str(t1))
            out = power
        else:
            raise Exception("Calls to __rpow__ are expected to be number**object")

        if isinstance(power, pyda.utils._pyda_obj._pyda_obj):
            if power.yaxis.data.size != 1:
                raise Exception("Need single valued YData to raise to power")
            powerval = 1.0 * power.ydata()[0]

        # error propagation
        y1 = 1.0 * t1.yaxis.data
        dy = 1.0 * t1.yaxis.ddata
        dy = dy * numpy.abs(powerval * y1 ** (powerval - 1))

        # raise to power
        # print(f"raising {y1} to {power}")

        out.yaxis.data = y1 ** powerval
        out.yaxis.units **= powerval
        out.yaxis.ddata = dy

        out.name = t1.name + "**" + out.name

        return out

    def __pow__(self, power, modulo=None):
        t1 = self.deepcopy()

        # print("ydata/pow")
        # print(t1)
        # print(power)

        if isinstance(power, pyda.utils._pyda_obj._pyda_obj):
            if power.yaxis.data.size != 1:
                raise Exception("Need single valued YData to raise to power")
            power = 1.0 * power.ydata()[0]

        # error propagation
        y1 = 1.0 * t1.yaxis.data
        dy = 1.0 * t1.yaxis.ddata
        dy = dy * numpy.abs(power * y1 ** (power - 1))

        # raise to power
        # print(f"raising {y1} to {power}")
        t1.yaxis.data = y1 ** power
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

        if not isinstance(t2, YData) and not isinstance(t2, YData):
            raise Exception("Second object should be a number or a YData object")

        # check units
        u1 = t1.yunits()
        u2 = t2.yunits()
        if u1 != u2:
            raise Exception(
                "Units of object 1 " + u1.char() + " not equal to object 2 " + u2.char()
            )

        # check length
        if t1.yaxis.data.size != t2.yaxis.data.size:
            raise Exception(
                "Can only subtract objects of same length: "
                + str(t1.size)
                + " != "
                + str(t2.size())
            )

        # error propagation
        y1 = t1.yaxis.data
        y2 = t2.yaxis.data
        dy1 = t1.yaxis.ddata
        dy2 = t2.yaxis.ddata
        dy = numpy.sqrt(dy1 ** 2 + dy2 ** 2)
        t1.yaxis.ddata = dy

        # subtract data
        t1.yaxis.data = y2 - y1

        # handle name
        t1.name = "(" + t2.name + " - " + t1.name + ")"

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

        if not isinstance(t2, YData) and not isinstance(t2, YData):
            raise Exception("Second object should be a number or a YData object")

        # check units
        u1 = t1.yunits()
        u2 = t2.yunits()
        if u1 != u2:
            raise Exception(
                "Units of object 1 " + u1.char() + " not equal to object 2 " + u2.char()
            )

        # check length
        if t1.yaxis.data.size != t2.yaxis.data.size:
            raise Exception(
                "Can only subtract objects of same length: "
                + str(t1.size)
                + " != "
                + str(t2.size())
            )

        # error propagation
        y1 = t1.yaxis.data
        y2 = t2.yaxis.data
        dy1 = t1.yaxis.ddata
        dy2 = t2.yaxis.ddata
        dy = numpy.sqrt(dy1 ** 2 + dy2 ** 2)
        t1.yaxis.ddata = dy

        # subtract data
        t1.yaxis.data = y1 - y2

        # handle name
        t1.name = "(" + t1.name + " - " + t2.name + ")"

        return t1

    def __radd__(self, other):
        new_name = self.name
        out = self.__add__(other)
        # handle name
        out.name = "(" + str(other) + "+" + new_name + ")"
        return out

    def __add__(self, other):
        """
        Add two data series or a number

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

        # handle special case of "other" being a numpy array
        if isinstance(t2, numpy.ndarray):
            t1.yaxis.data = t1.yaxis.data + t2
            t1._name = "(" + t1._name + "+ndarray" + ")"
            return t1

        if not isinstance(t2, YData) and not isinstance(t2, YData):
            raise Exception("Second object should be a number or a YData object")

        # check units
        u1 = t1.yunits()
        u2 = t2.yunits()
        if u1 != u2:
            raise Exception(
                "Units of object 1 " + u1.char() + " not equal to object 2 " + u2.char()
            )

        # check length
        if (
            t1.yaxis.data.size != 1
            and t2.yaxis.data.size != 1
            and t1.yaxis.data.size != t2.yaxis.data.size
        ):
            raise Exception(
                "Can only add objects of same length: "
                + str(t1.size)
                + " != "
                + str(t2.size())
            )

        # error propagation
        y1 = t1.yaxis.data
        y2 = t2.yaxis.data
        dy1 = t1.yaxis.ddata
        dy2 = t2.yaxis.ddata
        dy = numpy.sqrt(dy1 ** 2 + dy2 ** 2)

        # add data
        t1.yaxis.data = y1 + y2
        t1.yaxis.ddata = dy

        # handle name
        t1.name = "(" + t1.name + " + " + t2.name + ")"

        return t1

    def __rmul__(self, other):
        new_name = self.name
        out = self.__mul__(other)
        # handle name
        out.name = "(" + str(other) + "*" + new_name + ")"
        return out

    def __mul__(self, other):

        t1 = self.deepcopy()
        t2 = other

        # handle special case of "other" being a number
        if isinstance(t2, numbers.Number):
            t1.yaxis.data = t1.yaxis.data * t2
            t1._name = "(" + t1._name + "*" + str(t2) + ")"
            return t1

        # handle special case of "other" being a numpy array
        if isinstance(t2, numpy.ndarray):
            t1.yaxis.data = t1.yaxis.data * t2
            t1._name = "(" + t1._name + "*ndarray" + ")"
            return t1

        t1.yaxis = t1.yaxis * t2.yaxis

        # handle name
        t1.name = "(" + t1.name + "*" + t2.name + ")"

        return t1

    # ----------------------------------------------------
    # Methods
    # ----------------------------------------------------

    def split_by_samples(self, indices=[0, None]):
        """
        Split the YData into multiple objects by specifying pairs of start and stop samples. The
        method returns objects that contain the start samples and run up to (but don't include) the
        stop samples.

        If a single start/stop pair are specified, a single YData will be returned. Otherwise
        a list of YData objects will be returned.

        Example:
            out = y.split_by_samples(indices=[0, 10, 10, 20]

        will return two objects, each with 10 samples.

        :return:
        """

        # identify start and stop indices
        starts = indices[0:None:2]
        stops = indices[1:None:2]

        print(starts)
        print(stops)

        y = self.ydata()
        dy = self.yaxis.ddata
        output = []
        kk = 0
        for start, stop in zip(starts, stops):
            print(str(start) + " to " + str(stop))
            ts = self.deepcopy()
            ts.yaxis.data = y[start:stop]
            ts.yaxis.ddata = dy[start:stop]
            ts.name = ts.name + "[" + str(kk) + "]"
            output.append(ts)
            kk += 1

        if len(output) == 1:
            return output[0]

        return output

    def size(self):
        """
        Returns the size of the yaxis data.

        :return:
        """
        return self.yaxis.data.size

    def yunitsLabel(self):
        s = self.yaxis.units.toLabel()
        return s

    def yunits(self) -> Unit:
        """
        Returns the y-axis units of this time-series object as a string
        :return:
        """
        return self.yaxis.units

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
        y = numpy.reshape(self.yaxis.data.data, (N,))
        numpy.savetxt(filename, y)

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
        s = "-------- YData ---------\n"
        s += "  name: " + self._name + "\n"
        s += "  uuid: " + str(self.id) + "\n"
        s += (
            " yaxis: "
            + self.yaxis.name
            + "="
            + str(self.yaxis.data.shape)
            + self.yunits().char()
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

    # yaxis
    @property
    def yaxis(self):
        return self._yaxis

    @yaxis.setter
    def yaxis(self, val=None):

        if val is not None:
            # ensure we have Axis objects
            if isinstance(val, numpy.ndarray):
                val = Axis(data=val)
            elif isinstance(val, numbers.Number):
                val = Axis(data=numpy.array([val]))
            elif isinstance(val, YData):
                val = Axis(data=val.ydata())
            elif isinstance(val, list):
                val = Axis(data=numpy.array(val))
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
    #         elif isinstance(val, list):
    #             val = Axis(data=numpy.array(val))
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
