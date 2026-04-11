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

from pyda.utils.axis import Axis
from pyda.xydata import XYData


class FSData(XYData):
    """
    A class to encapsulate a set of frequency-series data.

    """

    def __init__(
        self,
        name: str = "FSdata",
        description: str = "",
        xaxis: object = Axis(),
        yaxis: object = Axis(),
        xunits: object = "Hz",
        yunits: object = "",
        xname: str = "Frequency",
        yname: str = "Amplitude",
    ) -> None:
        """
        Initiate a FSData object
        :param name:
        :param description:
        :param xaxis: specify numpy.ndarray or pyda.Axis() object
        :param yaxis: specify numpy.ndarray or pyda.Axis() object
        :param xunits: specify a unit string or a pyda.Unit() object.
        :param yunits: specify a unit string or a pyda.Unit() object.
        :param xname:
        :param yname:
        """

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

    def _add_to_hd5f_structure(self, hd5f_file=None):
        super()._add_to_hd5f_structure(hd5f_file=hd5f_file)
        hd5f_file["XYData"].attrs["pyda_class"] = "FSData"

    @classmethod
    def _from_hd5f_structure(cls, hd5f_file=None):
        from pyda.xydata import XYData
        xy = XYData._from_hd5f_structure(hd5f_file=hd5f_file)
        fs = FSData(xaxis=xy.xaxis, yaxis=xy.yaxis, name=xy.name)
        fs.id = xy.id
        fs.description = xy.description
        return fs

    @classmethod
    def from_function(cls, name="", f=[], fcn="f", yunits=""):
        """
        Construct an FSData object by specifying a function of frequency, f.

        :param name: a name for the object
        :param f: a vector of frequencies on which to evaluate the function
        :param fcn: a string specifying the function of f in valid python syntax
        :param yunits: units for the output object
        """

        fs = FSData(name=name, xaxis=f, yaxis=eval(fcn), yunits=yunits)

        return fs

    @classmethod
    def from_complex_txt_file(cls, filename=""):
        """
        Very simple method to read a three-column (freq, real, imag) text file.

        :param filename:
        :return:
        """
        if not filename:
            raise Exception("Please specify a file to load from")

        print("Loading from " + filename + "...")

        x = numpy.loadtxt(filename, usecols=0)
        yr = numpy.loadtxt(filename, usecols=1)
        yi = numpy.loadtxt(filename, usecols=2)

        y = yr + 1j * yi

        obj = FSData(xaxis=x, yaxis=y, name=filename)
        return obj

    @classmethod
    def from_txt_file(cls, filename=""):
        """
        Very simple method to read a two-column (freq, data) text file.

        :param filename:
        :return:
        """
        if not filename:
            raise Exception("Please specify a file to load from")

        # print("Loading from " + filename + "...")

        x = numpy.loadtxt(filename, usecols=0)
        y = numpy.loadtxt(filename, usecols=1)

        obj = FSData(xaxis=x, yaxis=y, name=filename)
        return obj

    # ----------------------------------------------------
    # Operators
    # ----------------------------------------------------

    # ----------------------------------------------------
    # Methods
    # ----------------------------------------------------

    def rms(self):
        """
        Compute the RMS of the data
        """

        freq = self.xdata()
        sp = self.ydata()

        yvals = s_sc_phi.ydata() ** 2
        df = numpy.mean(numpy.diff(s_sc_phi.xdata()))

        RMS = numpy.sqrt(numpy.sum(yvals * df))

        rms = YData(data=RMS, units=self.yunits())
        rms.name = f"RMS({self.name})"
        return rms


    def split_by_frequency(self, frequencies=[]):
        """
        Split the FSData into multiple objects by specifying pairs of start and stop frequencies. The
        method returns objects that contain the start frequencies and run up to (but don't include) the
        stop frequencies.

        A negative end frequency will count from the end of the frequency-series.

        If a single start/stop pair are specified, a single FSData will be returned. Otherwise
        a list of FSData objects will be returned.

        Example:
            out = freq.split_by_frequency(indices=[0, 0.1, 0.2, 0.5]

        will return two FSData objects.

        :return:
        """

        frequencies = 1.0 * numpy.array(frequencies)

        starts = frequencies[0:None:2]
        stops = frequencies[1:None:2]

        x = self.xdata()
        y = self.ydata()
        dx = self.xaxis.ddata
        dy = self.yaxis.ddata

        output = []
        kk = 0
        for start, stop in zip(starts, stops):


            if stop < 0:
                stop = numpy.amax(x) + stop

            # find the start and stop indices
            # print("splitting " + str(start) + " to " + str(stop))
            start_idx = numpy.argmin(numpy.abs(x - start))
            stop_idx = numpy.argmin(numpy.abs(x - stop))

            # print("splitting " + str(start_idx) + " to " + str(stop_idx))
            out = self.deepcopy()
            out.xaxis.data = x[start_idx:stop_idx]
            out.yaxis.data = y[start_idx:stop_idx]
            out.xaxis.ddata = dx[start_idx:stop_idx]
            out.yaxis.ddata = dy[start_idx:stop_idx]
            out.name = out.name + "[" + str(kk) + "]"

            # check errors
            if out.xaxis.ddata.size == 0:
                out.xaxis.ddata = 0
            if out.yaxis.ddata.size == 0:
                out.yaxis.ddata = 0

            output.append(out)
            kk += 1

        if len(output) == 1:
            return output[0]

        return output


    # ----------------------------------------------------
    # Overrides
    # ----------------------------------------------------

    def __str__(self):
        s = "-------- FSData ---------\n"
        s += "  name: " + self.name + "\n"
        s += "  uuid: " + str(self.id) + "\n"
        s += (
            "     x: "
            + self.xaxis.name
            + "="
            + str(self.xaxis.data.shape)
            + self.xunits().char()
            + "\n"
        )
        s += (
            "     y: "
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
