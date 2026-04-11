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
from pyda.exceptions.typeexceptions import WrongDataTypeException

from pyda.utils.unit import Unit
from pyda.utils._pyda_obj import _pyda_obj
from pyda.fsdata import FSData
import pyda


class PZModel(_pyda_obj):
    def __init__(
        self,
        name: str = "PZModel",
        description: str = "",
        poles=None,
        zeros=None,
        gain=1.0,
        delay=0.0,
        iunits=None,
        ounits=None
    ):
        """
        Pole/zero model constructor.

        Example constructors:

        pzm = PZModel(poles=PZ(f=1, q=2), zeros=PZ(2), gain=2, delay=0.2)
        pzm = PZModel(poles=[PZ(1), PZ(2)], zeros=[PZ(10)], gain=2, delay=0.2)
        pzm = PZModel(poles=[1,2], zeros=PZ(10), gain=2, delay=0.2)


        :param name:
        :param description:
        :param poles:
        :param zeros:
        :param gain:
        :param delay:
        """
        super().__init__(name, description)

        self.poles = []
        self.zeros = []
        self.gain = gain
        self.delay = delay

        if iunits is None:
            self.iunits = Unit()
        else:
            self.iunits = iunits

        if ounits is None:
            self.ounits = Unit()
        else:
            self.ounits = ounits

        # process poles
        self.poles = PZModel._processInputPoleZeros(poles)
        self.zeros = PZModel._processInputPoleZeros(zeros)

    def resp(self, freqs: numpy.ndarray = None) -> object:
        """
        Compute the frequency-domain response of the pole/zero model given a vector of frequencies.

        :param freqs: numpy array of frequencies on which to evaluate the response.
        :return:
        """
        # Compute response
        r = self.gain * numpy.ones(freqs.size)
        # print(type(r))
        for p in self.poles:
            pr = p.resp(freqs)
            r = r * pr

        for z in self.zeros:
            zr = z.resp(freqs)
            r = r / zr

        # delay
        r = r * numpy.exp(-2.0 * numpy.pi * freqs * 1j * self.delay)

        # output
        yunits = self.ounits / self.iunits
        fs = FSData(yaxis=r, xaxis=freqs, name="resp(" + self.name + ")", yunits=yunits)

        return fs

    @classmethod
    def _processInputPoleZeros(cls, poles):
        valid_poles = []
        if isinstance(poles, PZ):
            valid_poles.append(poles)
        elif isinstance(poles, list):
            for p in poles:
                if not isinstance(p, PZ):
                    p = PZ(p)
                valid_poles.append(p)

        return valid_poles

    def __str__(self):
        s = "-------- PZModel ---------\n"
        s += "  name: " + str(self.name) + "\n"
        s += "  desc: " + str(self.description) + "\n"
        s += "  gain: " + str(self.gain) + "\n"
        s += " delay: " + str(self.delay) + "\n"
        s += "iunits: " + self.iunits.char() + "\n"
        s += "ounits: " + self.ounits.char() + "\n"

        kk = 0
        for p in self.poles:
            s += f"pole{kk:02} = " + p.char() + "\n"
            kk += 1

        for z in self.zeros:
            s += f"zero{kk:02} = " + z.char() + "\n"
            kk += 1

        s += "\n-----------------------------"

        return s

    # iunits
    @property
    def iunits(self):
        return self._iunits

    @iunits.setter
    def iunits(self, val=None):

        # ensure we have Unit objects
        if isinstance(val, str):
            val = pyda.utils.unit.Unit(val)

        if not isinstance(val, pyda.utils.unit.Unit):
            raise WrongDataTypeException(
                "The units must be a Unit object, not a " + str(type(val))
            )

        self._iunits = val

    @iunits.deleter
    def iunits(self):
        del self._iunits

    # ounits
    @property
    def ounits(self):
        return self._ounits

    @ounits.setter
    def ounits(self, val=None):

        # ensure we have Unit objects
        if isinstance(val, str):
            val = pyda.utils.unit.Unit(val)

        if not isinstance(val, pyda.utils.unit.Unit):
            raise WrongDataTypeException(
                "The units must be a Unit object, not a " + str(type(val))
            )

        self._ounits = val

    @ounits.deleter
    def ounits(self):
        del self._ounits


class PZ:
    def __init__(self, f=None, q=None):

        self.f = numpy.nan
        self.q = numpy.nan
        self.ri = numpy.nan

        if numpy.isreal(f) and not q:
            self.f = f
            self.ri = PZ.fq2ri(f0=f)
        elif numpy.isreal(f) and q:
            self.f = f
            self.q = q
            self.ri = PZ.fq2ri(f0=f, q=q)
        elif numpy.iscomplex(f):
            self.f, self.q = PZ.ri2fq(f)
            self.ri = numpy.array([f, numpy.conj(f)])
        else:
            raise Exception("Unknown type for frequency")

    @classmethod
    def fq2ri(cls, f0=numpy.nan, q=numpy.nan):
        ri = numpy.array([])
        if numpy.isnan(q):
            ri = -(2 * numpy.pi * f0)
        elif q > 0:
            if q < 0.5:
                print("! splitting to two real poles/zeros")
                a = (
                    2.0
                    * numpy.pi
                    * f0
                    / (2.0 * q)
                    * (1 + numpy.sqrt(1.0 - 4.0 * q**2))
                )
                b = (
                    2.0
                    * numpy.pi
                    * f0
                    / (2.0 * q)
                    * (1 - numpy.sqrt(1.0 - 4.0 * q**2))
                )
                ri = numpy.array([a, b])
            elif q == 0.5:
                print("! splitting to two equal poles/zeros")
                w0 = 2.0 * numpy.pi * f0
                re = w0 / (2.0 * q)
                ri = numpy.array([re, re])
            else:
                w0 = 2.0 * numpy.pi * f0
                re = -w0 / (2.0 * q)
                im = w0 * numpy.sqrt(1.0 - 1.0 / (4.0 * q**2))
                tri = complex(re, im)
                ri = numpy.array([tri, numpy.conj(tri)])

        else:
            raise Exception("Q factor should be positive")

        return ri

    @classmethod
    def ri2fq(cls, ri):

        a = numpy.real(ri)
        b = numpy.imag(ri)

        f0 = numpy.sqrt(a**2 + b**2) / (2.0 * numpy.pi)
        q = 0.5 * numpy.sqrt(1 + b**2 / a**2)

        return f0, q

    def __str__(self):
        s = "-------- PZ ---------\n"
        s += "  f: " + str(self.f) + "\n"
        s += "  q: " + str(self.q) + "\n"
        s += " ri: " + str(self.ri) + "\n"
        s += "\n-----------------------------"
        return s

    def char(self):
        print(type(self.ri))
        if isinstance(self.ri, float):
            s_ri = self.ri
        elif isinstance(self.ri, list):
            s_ri = self.ri[0]
        else:
            s_ri = self.ri

        return f"(f={self.f} Hz, Q={self.q}, ri={s_ri})"

    @classmethod
    def _resp_pz_Q(cls, f, f0, q):
        re = 1.0 - (f**2 / f0**2)
        im = f / (f0 * q)
        r = 1.0 / (re + 1j * im)
        return r

    @classmethod
    def _resp_pz_noQ(cls, f, f0):
        re = 1.0
        im = f / f0
        r = 1.0 / (re + 1j * im)
        return r

    def resp(self, freqs=None):

        if self.q >= 0.5:
            r = PZ._resp_pz_Q(freqs, self.f, self.q)
        else:
            r = PZ._resp_pz_noQ(freqs, self.f)

        return r
