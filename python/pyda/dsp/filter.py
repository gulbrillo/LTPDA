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
import scipy.signal

from pyda.fsdata import FSData
from pyda.tsdata import TSData
from pyda.utils.unit import Unit


class TF:
    def __init__(self, name="", iunits=Unit(), ounits=Unit()):

        # ensure we have Unit objects
        if isinstance(iunits, str):
            iunits = Unit(iunits)

        if isinstance(ounits, str):
            ounits = Unit(ounits)

        self.name = name  # name of the object
        self.iunits = iunits  # input units of the object
        self.ounits = ounits  # output  units of the object


class DFilter(TF):
    def __init__(
        self, name="FIR Filter", a=numpy.ndarray, fs=None, iunits=Unit(), ounits=Unit()
    ):
        super().__init__(name=name, iunits=iunits, ounits=ounits)

        self.fs = fs  # sample rate that the filter is designed for
        self.gd = None  # group delay
        self.infile = ""  # filename if the filter was loaded from file
        self.a = a  # set of numerator coefficients
        self.histout = []  # output history values of the filter

        self.gd = (self.ntaps() - 1) / 2.0

    def ntaps(self):
        return int(self.a.size)


class FIR(DFilter):
    """
    A class to encapsulate an FIR digital filter.

    NOTES:
        The convention used here for naming the filter coefficients is
        the opposite to MATLAB's convention. The recursion formula
        for this convention is

        y(n) = a(1)*x(n) + a(2)*x(n-1) + ... + a(na+1)*x(n-na)

    """

    def __init__(
        self, name="FIR Filter", a=None, fs=None, iunits=Unit(), ounits=Unit()
    ):
        super().__init__(name=name, a=a, fs=fs, iunits=iunits, ounits=ounits)

    def resp(self, f=512, f1=None, f2=None, nf=512):

        if f1 and f2:
            f = numpy.linspace(f1, f2, nf)

        # filter response
        w, h = scipy.signal.freqz(b=self.a, fs=self.fs, worN=f)

        # create return object
        fd = FSData(
            name="resp(" + self.name + ")",
            xaxis=w,
            yaxis=h,
            yunits=self.ounits / self.iunits,
        )

        return fd

    def filter(self, *args):

        ft = self
        out = []
        for t in args:
            if isinstance(t, TSData):
                to = t.deepcopy()
                to.yaxis.data = scipy.signal.lfilter(b=ft.a, a=1, x=t.ydata())
                to.name = ft.name + "(" + to.name + ")"
                to.yaxis.units = to.yaxis.units * ft.ounits / ft.iunits
                out.append(to)

        if len(out) == 1:
            out = out[0]

        return out

    def __str__(self):
        """

        :return:
        """
        s = "-------- FIR ---------\n"
        s += "   name: " + self.name + "\n"
        s += "      a: " + str(self.a[0 : numpy.minimum(10, self.ntaps())]) + " ...\n"
        s += "     fs: " + str(self.fs) + "\n"
        s += "     gd: " + str(self.gd) + "\n"
        s += "  ntaps: " + str(self.ntaps()) + "\n"
        s += " iunits: " + self.iunits.char() + "\n"
        s += " ounits: " + self.ounits.char() + "\n"
        s += "\n-----------------------------"
        return s

    @classmethod
    def bandstop(
        cls,
        fc=None,
        gain=1,
        win="blackmanharris",
        fs=None,
        order=128,
        iunits=Unit(),
        ounits=Unit(),
    ):

        a = gain * scipy.signal.firwin(
            numtaps=order + 1,
            cutoff=fc,
            width=None,
            window=win,
            pass_zero=True,
            scale=True,
            fs=fs,
        )
        f = FIR(name="bandstop", a=a, fs=fs, iunits=iunits, ounits=ounits)
        f.gd = (f.ntaps() - 1) / 2
        f.histout = numpy.zeros((1, f.ntaps() - 1))  # initialise output history
        return f

    @classmethod
    def bandpass(
        cls,
        fc=None,
        gain=1,
        win="blackmanharris",
        fs=None,
        order=128,
        iunits=Unit(),
        ounits=Unit(),
    ):

        a = gain * scipy.signal.firwin(
            numtaps=order + 1,
            cutoff=fc,
            width=None,
            window=win,
            pass_zero=False,
            scale=True,
            fs=fs,
        )
        f = FIR(name="bandpass", a=a, fs=fs, iunits=iunits, ounits=ounits)
        f.gd = (f.ntaps() - 1) / 2
        f.histout = numpy.zeros((1, f.ntaps() - 1))  # initialise output history
        return f

    @classmethod
    def lowpass(
        cls,
        fc=None,
        gain=1,
        win="blackmanharris",
        fs=None,
        order=128,
        iunits=Unit(),
        ounits=Unit(),
    ):

        a = gain * scipy.signal.firwin(
            numtaps=order + 1,
            cutoff=fc,
            width=None,
            window=win,
            pass_zero=True,
            scale=True,
            fs=fs,
        )
        f = FIR(name="lowpass", a=a, fs=fs, iunits=iunits, ounits=ounits)
        f.gd = (f.ntaps() - 1) / 2
        f.histout = numpy.zeros((1, f.ntaps() - 1))  # initialise output history
        return f

    @classmethod
    def highpass(
        cls,
        fc=None,
        gain=1,
        win="blackmanharris",
        fs=None,
        order=128,
        iunits=Unit(),
        ounits=Unit(),
    ):

        a = gain * scipy.signal.firwin(
            numtaps=order + 1,
            cutoff=fc,
            width=None,
            window=win,
            pass_zero=False,
            scale=True,
            fs=fs,
        )
        f = FIR(name="highpass", a=a, fs=fs, iunits=iunits, ounits=ounits)
        f.gd = (f.ntaps() - 1) / 2
        f.histout = numpy.zeros((1, f.ntaps() - 1))  # initialise output history
        return f


class IIR(DFilter):
    def __init__(
        self, name="FIR Filter", a=None, b=None, fs=None, iunits=Unit(), ounits=Unit()
    ):
        super().__init__(name, a, fs, iunits, ounits)
        self.b = b

    def resp(self, f=512, f1=None, f2=None, nf=512):

        if f1 and f2:
            f = numpy.linspace(f1, f2, nf)

        # filter response
        w, h = scipy.signal.freqz(b=self.b, a=self.a, fs=self.fs, worN=f)

        # create return object
        fd = FSData(
            name="resp(" + self.name + ")",
            xaxis=w,
            yaxis=h,
            yunits=self.ounits / self.iunits,
        )

        return fd

    def filtfilt(self, *args):
        ft = self
        out = []
        for t in args:
            if isinstance(t, TSData):
                to = t.deepcopy()
                to.yaxis.data = scipy.signal.filtfilt(b=ft.b, a=ft.a, x=t.ydata())
                to.name = ft.name + "(" + to.name + ")"
                to.yaxis.units = to.yaxis.units * ft.ounits / ft.iunits
                out.append(to)

        if len(out) == 1:
            out = out[0]

        return out

    def filter(self, *args):

        ft = self
        out = []
        for t in args:
            if isinstance(t, TSData):
                to = t.deepcopy()
                to.yaxis.data = scipy.signal.lfilter(b=ft.b, a=ft.a, x=t.ydata())
                to.name = ft.name + "(" + to.name + ")"
                to.yaxis.units = to.yaxis.units * ft.ounits / ft.iunits
                out.append(to)

        if len(out) == 1:
            out = out[0]

        return out

    def __str__(self):
        """

        :return:
        """
        s = "-------- IIR ---------\n"
        s += "   name: " + self.name + "\n"
        s += "      a: " + str(self.a[0 : numpy.minimum(10, self.ntaps())]) + " ...\n"
        s += "      b: " + str(self.b[0 : numpy.minimum(10, self.ntaps())]) + " ...\n"
        s += "     fs: " + str(self.fs) + "\n"
        s += "  ntaps: " + str(self.ntaps()) + "\n"
        s += " iunits: " + self.iunits.char() + "\n"
        s += " ounits: " + self.ounits.char() + "\n"
        s += "\n-----------------------------"
        return s

    @classmethod
    def bandstop(
        cls,
        fc=None,
        gain=1,
        fs=None,
        order=2,
        pass_ripple=0.1,
        stop_ripple=0.1,
        design_type="butter",
        iunits=Unit(),
        ounits=Unit(),
    ):

        b, a = scipy.signal.iirfilter(
            N=order,
            Wn=fc,
            rp=pass_ripple,
            rs=stop_ripple,
            btype="bandstop",
            ftype=design_type,
            fs=fs,
            output="ba",
        )

        b *= gain

        f = IIR(name="bandstop", a=a, b=b, fs=fs, iunits=iunits, ounits=ounits)
        f.histout = numpy.zeros((1, f.ntaps() - 1))  # initialise output history
        return f

    @classmethod
    def bandpass(
        cls,
        fc=None,
        gain=1,
        fs=None,
        order=2,
        pass_ripple=0.1,
        stop_ripple=0.1,
        design_type="butter",
        iunits=Unit(),
        ounits=Unit(),
    ):

        b, a = scipy.signal.iirfilter(
            N=order,
            Wn=fc,
            rp=pass_ripple,
            rs=stop_ripple,
            btype="bandpass",
            ftype=design_type,
            fs=fs,
            output="ba",
        )

        b *= gain

        f = IIR(name="bandpass", a=a, b=b, fs=fs, iunits=iunits, ounits=ounits)
        f.histout = numpy.zeros((1, f.ntaps() - 1))  # initialise output history
        return f

    @classmethod
    def lowpass(
        cls,
        fc=None,
        gain=1,
        fs=None,
        order=2,
        pass_ripple=0.1,
        stop_ripple=0.1,
        design_type="butter",
        iunits=Unit(),
        ounits=Unit(),
    ):

        b, a = scipy.signal.iirfilter(
            N=order,
            Wn=fc,
            rp=pass_ripple,
            rs=stop_ripple,
            btype="lowpass",
            ftype=design_type,
            fs=fs,
            output="ba",
        )

        b *= gain

        f = IIR(name="lowpass", a=a, b=b, fs=fs, iunits=iunits, ounits=ounits)
        f.histout = numpy.zeros((1, f.ntaps() - 1))  # initialise output history
        return f

    @classmethod
    def highpass(
        cls,
        fc=None,
        gain=1,
        fs=None,
        order=2,
        pass_ripple=0.1,
        stop_ripple=0.1,
        design_type="butter",
        iunits=Unit(),
        ounits=Unit(),
    ):

        b, a = scipy.signal.iirfilter(
            N=order,
            Wn=fc,
            rp=pass_ripple,
            rs=stop_ripple,
            btype="highpass",
            ftype=design_type,
            fs=fs,
            output="ba",
        )

        b *= gain

        f = IIR(name="highpass", a=a, b=b, fs=fs, iunits=iunits, ounits=ounits)
        f.histout = numpy.zeros((1, f.ntaps() - 1))  # initialise output history
        return f
