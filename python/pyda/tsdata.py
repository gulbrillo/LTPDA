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

import h5py
import numpy
from datetime import datetime

from pyda.utils.axis import Axis
from pyda.xydata import XYData
from pyda.mixins._tsdata_dsp import *


class TSData(XYData, TSDataDSP):
    """
    A class to encapsulate a set of time-series data.

    """

    def __init__(
        self,
        name: str = "TSdata",
        description: str = "",
        fs: float = 0.0,
        xaxis: object = Axis(),
        yaxis: object = Axis(),
        xunits: str = "s",
        yunits: str = "",
        xname: str = "Time",
        yname: str = "Amplitude",
        t0: datetime = None,
    ) -> None:
        """

        Create a TSData object

        :param name:
        :param description:
        :param fs:
        :param xaxis:
        :param yaxis:
        :param xunits:
        :param yunits:
        :param xname:
        :param yname:
        :param t0: absolute UTC start time of the time-series (datetime or None).
                   Used when submitting to / retrieving from the LTPDA repository.
        """

        if isinstance(xaxis, Axis):
            xsize = xaxis.data.size
        else:
            xsize = xaxis.size

        if isinstance(yaxis, Axis):
            ysize = yaxis.data.size
        else:
            ysize = yaxis.size

        # Consistency checks
        if xsize == 0 and ysize != 0 and fs > 0:
            # print('Assuming evenly sampled data with fs=' + str(fs))
            N = ysize
            tEnd = N / fs
            tdata = numpy.arange(0, tEnd, 1 / fs)
            xaxis = Axis(data=tdata, units=xunits)

        super().__init__(
            description=description,
            xaxis=xaxis,
            yaxis=yaxis,
            xunits=xunits,
            yunits=yunits,
            xname=xname,
            yname=yname,
        )
        self.name = name
        self.t0 = t0  # absolute UTC start time; None means "unknown"

    # ----------------------------------------------------
    # Constructors
    # ----------------------------------------------------
    @classmethod
    def from_txt_file(cls, filename=""):
        """
        Load a time-series from a two-column (time, data) text file.

        :param filename:
        :return:
        """
        if not filename:
            raise Exception("Please specify a file to load from")

        print("Loading from " + filename + "...")

        x = numpy.loadtxt(filename, usecols=0)
        y = numpy.loadtxt(filename, usecols=1)

        obj = TSData(xaxis=x, yaxis=y, name=filename)
        return obj

    # ----------------------------------------------------
    # Class Methods
    # ----------------------------------------------------
    @classmethod
    def randn(cls, nsecs=10, fs=10, name="", yunits=""):
        """
        Generate a timeseries of random values with a unit PSD. Values are generated with numpy.random.randn.

        :param nsecs:
        :param fs:
        :param name:
        :param yunits:
        :return:
        """
        ts = TSData(
            yaxis=numpy.sqrt(fs / 2.0)
            * numpy.random.randn(
                int(nsecs * fs),
            ),
            fs=fs,
            name=name,
            yunits=yunits,
        )
        return ts

    @classmethod
    def zeros(cls, nsecs=10, fs=10, name="", yunits=""):
        """
        Generate a timeseries of zeros.

        :param nsecs:
        :param fs:
        :param name:
        :param yunits:
        :return:
        """
        ts = TSData(
            yaxis=numpy.zeros(
                int(nsecs * fs),
            ),
            fs=fs,
            name=name,
            yunits=yunits,
        )
        return ts

    @classmethod
    def ones(cls, nsecs=10, fs=10, name="", yunits=""):
        """
        Generate a timeseries of ones.

        :param nsecs:
        :param fs:
        :param name:
        :param yunits:
        :return:
        """
        ts = TSData(
            yaxis=numpy.ones(
                int(nsecs * fs),
            ),
            fs=fs,
            name=name,
            yunits=yunits,
        )
        return ts

    @classmethod
    def sinewave(
        cls,
        nsecs: float = 10.0,
        fs: float = 10.0,
        A0: float = 1.0,
        f0: float = 1.0,
        phi: float = 0.0,
        name: str = "",
        yunits: str = "",
    ) -> object:
        """
        Generate sinewave timeseries

        Note: currently only generates a single frequency. TODO: add code for multiple frequencies

        :param nsecs:
        :param A0: amplitude(s) of the sinewave
        :param f0: frequency(ies) (in Hz) of the sinewave
        :param phi: initial phase(s) of the sinewave (radians)
        :param fs:
        :param name:
        :param yunits:
        :return:
        """

        Tstep = 1.0 / fs
        tv = numpy.arange(start=0, stop=nsecs, step=Tstep)
        y = A0 * numpy.sin(2.0 * numpy.pi * f0 * tv + phi)
        ts = TSData(yaxis=y, fs=fs, name=name, yunits=yunits)
        return ts

    # ----------------------------------------------------
    # Operators
    # ----------------------------------------------------

    # ----------------------------------------------------
    # Methods
    # ----------------------------------------------------

    def split_by_time(self, times=[]):
        """
        Split the TSData into multiple objects by specifying pairs of start and stop times. The
        method returns objects that contain the start times and run up to (but don't include) the
        stop times.

        An end time of 0 will run up to and including the last sample.
        A negative end time will count from the end of the time-series.

        If a single start/stop pair are specified, a single TSData will be returned. Otherwise
        a list of TSData objects will be returned.

        Example:
            out = ts.split_by_time(times=[0, 10, 10, 20]

        will return two TSData objects, each with 10*fs samples.

        :return:
        """
        fs = self.fs()

        times = 1.0 * numpy.array(times)

        starts = numpy.floor(times[0:None:2] * fs)
        stops = numpy.floor(times[1:None:2] * fs)
        # print(starts)
        # print(stops)

        starts = starts.astype(int)
        stops = stops.astype(int)
        # print(starts)
        # print(stops)

        x = self.xdata()
        y = self.ydata()
        dx = self.xaxis.ddata
        dy = self.yaxis.ddata

        output = []
        kk = 0
        for start, stop in zip(starts, stops):
            if stop < 0:
                stop = len(x) + stop
                stop = stop.astype(int)
            elif stop == 0:
                stop = len(x)

            # print("splitting " + str(start/fs) + " to " + str(stop/fs))
            ts = self.deepcopy()
            ts.xaxis.data = x[start:stop]
            ts.yaxis.data = y[start:stop]
            ts.xaxis.ddata = dx[start:stop]
            ts.yaxis.ddata = dy[start:stop]
            ts.name = ts.name + "[" + str(kk) + "]"

            # check errors
            if ts.xaxis.ddata.size == 0:
                ts.xaxis.ddata = 0
            if ts.yaxis.ddata.size == 0:
                ts.yaxis.ddata = 0

            output.append(ts)
            kk += 1

        if len(output) == 1:
            return output[0]

        return output

    def _add_to_hd5f_structure(self, hd5f_file=None):
        super()._add_to_hd5f_structure(hd5f_file=hd5f_file)
        g = hd5f_file["XYData"]
        g.attrs["pyda_class"] = "TSData"
        g.attrs["t0"] = self.t0.isoformat() if self.t0 is not None else ""

    @classmethod
    def _from_hd5f_structure(cls, hd5f_file=None):
        from pyda.xydata import XYData
        xy = XYData._from_hd5f_structure(hd5f_file=hd5f_file)
        ts = TSData(xaxis=xy.xaxis, yaxis=xy.yaxis, name=xy.name)
        ts.id = xy.id
        ts.description = xy.description
        t0_str = hd5f_file["XYData"].attrs.get("t0", "")
        if t0_str:
            ts.t0 = datetime.fromisoformat(t0_str)
        return ts

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

    def nsecs(self):
        """
        Returns the number of seconds spanned by the time-series. Computed
        as the maximum time in the x-axis.

        :return:
        """
        return numpy.amax(self.xdata()) - numpy.amin(self.xdata()) + 1.0 / self.fs()

    def fs(self):
        """

        Return the sample rate of this time-series

        computes median(diff(x))

        :return:
        """
        ts = self

        # time differences
        dt = numpy.diff(ts.xdata())

        # for highly sampled data (>100Hz), the mean is more robust
        if numpy.mean(dt) < 1e-2:
            return 1.0 / numpy.mean(dt)
        else:
            return round(1.0 / numpy.median(dt), 6)

    # ----------------------------------------------------
    # Overrides
    # ----------------------------------------------------

    # def __deepcopy__(self, memo):
    #     p = TSData(xaxis=self.xaxis.__deepcopy__(), yaxis=self.yaxis.__deepcopy__(), name=self.name)
    #     return p

    def __str__(self):
        """

        :return:
        """
        s = "-------- TSData ---------\n"
        s += "  name: " + self.name + "\n"
        s += "  uuid: " + str(self.id) + "\n"
        s += "    fs: " + str(self.fs()) + "\n"
        s += " nsecs: " + str(self.nsecs()) + "\n"
        if self.t0 is not None:
            s += "    t0: " + self.t0.isoformat() + "\n"
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
