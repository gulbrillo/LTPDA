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


import scipy
from fractions import Fraction

import scipy.special
from numpy import *
import matplotlib.pyplot as plt

import copy
import re

from pyda.exceptions.typeexceptions import WrongDataTypeException
from pyda.exceptions.typeexceptions import InvalidOperatorException
from pyda.exceptions.rangeexceptions import WrongSizeException
from pyda.exceptions.rangeexceptions import IndexOutOfRangeException


class Specwin:
    """
    A class which encapsulates spectral windows.
    """

    def __init__(self, *args):
        """
        Construct spectral windows using the following options:

               w = specwin()                  - creates an empty object
               w = specwin(w)                 - copies a specwin object
               w = specwin('name')            - creates the specified specwin object
               w = specwin('name', N)         - creates a specwin object of a
                                                particular type and length.
               w = specwin('Kaiser', N, psll) - create a specwin Kaiser window
                                                with the prescribed psll.

            'name' should be one of the following standard windows:

            Rectangular, Welch, Bartlett, Hanning, Hamming,
            Nuttall3, Nuttall4, Nuttall3a, Nuttall3b, Nuttall4a
            Nuttall4b, Nuttall4c, BH92, SFT3F, SFT3M, FTNI, SFT4F, SFT5F
            SFT4M, FTHP, HFT70, FTSRS, SFT5M, HFT90D, HFT95, HFT116D
            HFT144D, HFT169D, HFT196D, HFT223D, HFT248D

        """

        # call superclass

        # defaults
        self.__name = ""
        self.__flatness = 0
        self.__length = 0
        self.__nenbw = 0
        self.__psll = 0
        self.__rov = 0
        self.__w3db = 0

        # process arguments
        nargs = len(args)

        if nargs == 0:
            pass
        elif nargs == 1:
            cmd = "self._win_" + args[0].lower() + "()"
            eval(cmd)
        elif nargs == 2:
            cmd = "self._win_" + args[0].lower() + "('define', " + str(args[1]) + ")"
            eval(cmd)
        elif nargs == 3:
            cmd = (
                "self._win_"
                + args[0].lower()
                + "('define', "
                + str(args[1])
                + ", "
                + str(args[2])
                + ")"
            )
            eval(cmd)
        else:
            raise IndexOutOfRangeException(
                "The Specwin constructor supports 0, 1, 2, or 3 input arguments"
            )

    # ----------------------------------------------------
    # Public Class Methods
    # ----------------------------------------------------

    @classmethod
    def supportedWindows(cls):
        return [
            "Rectangular",
            "Welch",
            "Bartlett",
            "Hanning",
            "Hamming",
            "Nuttall3",
            "Nuttall4",
            "Nuttall3a",
            "Nuttall3b",
            "Nuttall4a",
            "Nuttall4b",
            "Nuttall4c",
            "BH92",
            "SFT3F",
            "SFT3M",
            "FTNI",
            "SFT4F",
            "SFT5F",
            "SFT4M",
            "FTHP",
            "HFT70",
            "FTSRS",
            "SFT5M",
            "HFT90D",
            "HFT95",
            "HFT116D",
            "HFT144D",
            "HFT169D",
            "HFT196D",
            "HFT223D",
            "HFT248D",
            "Kaiser",
        ]

    # ----------------------------------------------------
    # Private Class Methods
    # ----------------------------------------------------
    @classmethod
    def __kaiser(cls, n_est, bta):
        nw = round(n_est + 1)
        bes = abs(scipy.special.iv(0, bta))
        odd = remainder(nw, 2)
        xind = pow(nw - 1, 2)
        n = fix((nw + 1) / 2)
        xi = arange(0, n) + 0.5 * (1 - odd)
        xi = 4 * pow(xi, 2)
        w = scipy.special.iv(0, bta * sqrt(1 - xi / xind)) / bes
        wi = w[: odd - 1 : -1]
        w = abs(concatenate([wi, w]))
        # return asymmetric window, so drop the last sample
        return w[:-1]

    @classmethod
    def __kaiser_alpha(cls, psll):
        a0 = -0.0821377
        a1 = 4.71469
        a2 = -0.493285
        a3 = 0.0889732

        x = psll / 100
        alpha = ((((a3 * x) + a2) * x) + a1) * x + a0
        return alpha

    @classmethod
    def __kaiser_flatness(cls, alpha):
        a0 = 0.141273
        a1 = 0.262425
        a2 = 0.00642551
        a3 = -0.000405621
        flatness = -1.0 / (((((a3 * alpha) + a2) * alpha) + a1) * alpha + a0)
        return flatness

    @classmethod
    def __kaiser_nenbw(cls, alpha):
        a0 = 0.768049
        a1 = 0.411986
        a2 = -0.0264817
        a3 = 0.000962211
        nenbw = ((((a3 * alpha) + a2) * alpha) + a1) * alpha + a0
        return nenbw

    @classmethod
    def __kaiser_rov(cls, alpha):
        a0 = 0.0061076
        a1 = 0.00912223
        a2 = -0.000925946
        a3 = 4.42204e-05
        rov = 100 - 1 / (((((a3 * alpha) + a2) * alpha) + a1) * alpha + a0)
        return rov

    @classmethod
    def __kaiser_w3db(cls, alpha):
        a0 = 0.757185
        a1 = 0.377847
        a2 = -0.0238342
        a3 = 0.00086012
        w3db = ((((a3 * alpha) + a2) * alpha) + a1) * alpha + a0
        return w3db

    @classmethod
    def __win_vec(cls, N):
        return 1.0 * r_[0:N]

    # ----------------------------------------------------
    # Public Methods
    # ----------------------------------------------------

    def deepcopy(self):
        "Returns a deep copy of this Specwin object."
        return copy.deepcopy(self)

    def display(self):
        "Prints a string representation of this Specwin object to the terminal."
        print(str(self))

    def char(self):
        "Returns a short string representation of this object."
        return "(" + self.name + ", length=" + str(self.length) + ")"

    def plot(self):
        """
        Plots the time-domain response of the window function.
        """
        t = arange(0, self.length)
        plt.ion()
        x = self.win()
        f1 = plt.figure()
        ax = f1.add_subplot(111)
        ax.plot(t, x, "r-o")
        plt.grid(True)
        plt.title("Window: " + self.name)
        plt.legend(
            [
                "psll = "
                + str(self.psll)
                + "\n"
                + "rov = "
                + str(self.rov)
                + "\n"
                + "nenbw = "
                + str(self.nenbw)
                + "\n"
                + "flatness = "
                + str(self.flatness)
            ]
        )
        plt.xlabel("Bin")
        plt.show()

    def win(self):
        """
        Returns a vector of window values for this window.

        Example:
                    w    = Specwin('Hanning', 10)
                    vals = w.win()

        """
        cmd = "self._win_" + self.name.lower() + "('build')"
        return eval(cmd)

    # ----------------------------------------------------
    # Private Methods
    # ----------------------------------------------------

    def _win_bartlett(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N)
            z = n / N
            vals = z * 2.0
            for (i, val) in enumerate(vals):
                if val > 1.0:
                    vals[i] = 2.0 - val

            return vals

        elif mode == "define":
            # Make window
            self.name = "Bartlett"
            self.psll = 26.5
            self.rov = 50
            self.nenbw = 1.3333
            self.w3db = 1.2736
            self.flatness = -1.8242
            self.length = N

    def _win_hft90d(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N
            vals = (
                1.0
                - 1.942604 * cos(z)
                + 1.340318 * cos(2.0 * z)
                - 0.440811 * cos(3.0 * z)
                + 0.043097 * cos(4.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "HFT90D"
            self.psll = 90.2
            self.rov = 76
            self.nenbw = 3.8832
            self.w3db = 3.8320
            self.flatness = -0.0039
            self.length = N

    def _win_bh92(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                0.35875
                - 0.48829 * cos(z)
                + 0.14128 * cos(2.0 * z)
                - 0.01168 * cos(3.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "BH92"
            self.psll = 92
            self.rov = 66.1
            self.nenbw = 2.0044
            self.w3db = 1.8962
            self.flatness = -0.8256
            self.length = N

    def _win_fthp(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                1.0
                + 1.912510941 * cos(z)
                + 1.079173272 * cos(2.0 * z)
                + 0.1832630879 * cos(3.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "FTHP"
            self.psll = 70.4
            self.rov = 72.3
            self.nenbw = 3.4279
            self.w3db = 3.3846
            self.flatness = 0.0096
            self.length = N

    def _win_ftni(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = 0.2810639 - 0.5208972 * cos(z) + 0.1980399 * cos(2.0 * z)

            return vals

        elif mode == "define":
            # Make window
            self.name = "FTNI"
            self.psll = 44.4
            self.rov = 65.6
            self.nenbw = 2.9656
            self.w3db = 2.9355
            self.flatness = 0.0169
            self.length = N

    def _win_ftsrs(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                1.0
                - 1.93 * cos(z)
                + 1.29 * cos(2.0 * z)
                - 0.388 * cos(3.0 * z)
                + 0.028 * cos(4.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "FTSRS"
            self.psll = 76.6
            self.rov = 75.4
            self.nenbw = 3.7702
            self.w3db = 3.7274
            self.flatness = -0.0156
            self.length = N

    def _win_hamming(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = 0.54 - 0.46 * cos(z)

            return vals

        elif mode == "define":
            # Make window
            self.name = "Hamming"
            self.psll = 42.7
            self.rov = 50
            self.nenbw = 1.3628
            self.w3db = 1.3008
            self.flatness = -1.7514
            self.length = N

    def _win_hanning(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = 0.5 * (1 - cos(z))

            return vals

        elif mode == "define":
            # Make window
            self.name = "Hanning"
            self.psll = 31.5
            self.rov = 50
            self.nenbw = 1.5
            self.w3db = 1.4382
            self.flatness = -1.4236
            self.length = N

    def _win_hft70(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                1.0 - 1.90796 * cos(z) + 1.07349 * cos(2.0 * z) - 0.18199 * cos(3.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "HFT70"
            self.psll = 70.4
            self.rov = 72.2
            self.nenbw = 3.4129
            self.w3db = 3.3720
            self.flatness = -0.0065
            self.length = N

    def _win_hft95(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                1.0
                - 1.9383379 * cos(z)
                + 1.3045202 * cos(2.0 * z)
                - 0.4028270 * cos(3.0 * z)
                + 0.0350665 * cos(4.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "HFT95"
            self.psll = 95
            self.rov = 75.6
            self.nenbw = 3.8112
            self.w3db = 3.759
            self.flatness = 0.0044
            self.length = N

    def _win_hft116d(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                1.0
                - 1.9575375 * cos(z)
                + 1.4780705 * cos(2.0 * z)
                - 0.6367431 * cos(3.0 * z)
                + 0.1228389 * cos(4.0 * z)
                - 0.0066288 * cos(5.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "HFT116d"
            self.psll = 116.8
            self.rov = 78.2
            self.nenbw = 4.2186
            self.w3db = 4.1579
            self.flatness = -0.0028
            self.length = N

    def _win_hft144d(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                1.0
                - 1.96760033 * cos(z)
                + 1.57983607 * cos(2.0 * z)
                - 0.81123644 * cos(3.0 * z)
                + 0.22583558 * cos(4.0 * z)
                - 0.02773848 * cos(5.0 * z)
                + 0.00090360 * cos(6.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "HFT144d"
            self.psll = 144.1
            self.rov = 79.9
            self.nenbw = 4.5386
            self.w3db = 4.4697
            self.flatness = 0.0021
            self.length = N

    def _win_hft169d(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                1.0
                - 1.97441843 * cos(z)
                + 1.65409889 * cos(2.0 * z)
                - 0.95788187 * cos(3.0 * z)
                + 0.33673420 * cos(4.0 * z)
                - 0.06364622 * cos(5.0 * z)
                + 0.00521942 * cos(6.0 * z)
                - 0.00010599 * cos(7.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "HFT169d"
            self.psll = 169.5
            self.rov = 81.2
            self.nenbw = 4.8347
            self.w3db = 4.7588
            self.flatness = 0.0017
            self.length = N

    def _win_hft196d(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                1.0
                - 1.979280420 * cos(z)
                + 1.710288951 * cos(2.0 * z)
                - 1.081629853 * cos(3.0 * z)
                + 0.448734314 * cos(4.0 * z)
                - 0.112376628 * cos(5.0 * z)
                + 0.015122992 * cos(6.0 * z)
                - 0.000871252 * cos(7.0 * z)
                + 0.000011896 * cos(8.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "HFT196d"
            self.psll = 196.2
            self.rov = 82.3
            self.nenbw = 5.1134
            self.w3db = 5.0308
            self.flatness = 0.0013
            self.length = N

    def _win_hft223d(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                1.0
                - 1.98298997309 * cos(z)
                + 1.75556083063 * cos(2.0 * z)
                - 1.19037717712 * cos(3.0 * z)
                + 0.56155440797 * cos(4.0 * z)
                - 0.17296769663 * cos(5.0 * z)
                + 0.03233247087 * cos(6.0 * z)
                - 0.00324954578 * cos(7.0 * z)
                + 0.00013801040 * cos(8.0 * z)
                - 0.00000132725 * cos(9.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "HFT223d"
            self.psll = 223
            self.rov = 83.3
            self.nenbw = 5.3888
            self.w3db = 5.3
            self.flatness = -0.0011
            self.length = N

    def _win_hft248d(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                1.0
                - 1.985844164102 * cos(z)
                + 1.791176438506 * cos(2.0 * z)
                - 1.282075284005 * cos(3.0 * z)
                + 0.667777530266 * cos(4.0 * z)
                - 0.240160796576 * cos(5.0 * z)
                + 0.056656381764 * cos(6.0 * z)
                - 0.008134974479 * cos(7.0 * z)
                + 0.000624544650 * cos(8.0 * z)
                - 0.000019808998 * cos(9.0 * z)
                + 0.000000132974 * cos(10.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "HFT248d"
            self.psll = 248.4
            self.rov = 84.1
            self.nenbw = 5.6512
            self.w3db = 5.5567
            self.flatness = 0.0009
            self.length = N

    def _win_kaiser(self, mode="define", N=0, psll=100):

        if mode == "build":
            if N == 0:
                N = self.length

            vals = Specwin.__kaiser(N, pi * self.alpha)

            return vals

        elif mode == "define":
            # Make window
            self.name = "Kaiser"
            self.alpha = Specwin.__kaiser_alpha(psll)
            self.psll = psll
            self.rov = Specwin.__kaiser_rov(self.alpha)
            self.nenbw = Specwin.__kaiser_nenbw(self.alpha)
            self.w3db = Specwin.__kaiser_w3db(self.alpha)
            self.flatness = Specwin.__kaiser_flatness(self.alpha)
            self.length = N

    def _win_nuttall3(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = 0.375 - 0.5 * cos(z) + 0.125 * cos(2.0 * z)

            return vals

        elif mode == "define":
            # Make window
            self.name = "Nuttall3"
            self.psll = 46.7
            self.rov = 64.7
            self.nenbw = 1.9444
            self.w3db = 1.8496
            self.flatness = -0.8630
            self.length = N

    def _win_nuttall3a(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = 0.40897 - 0.5 * cos(z) + 0.09103 * cos(2.0 * z)

            return vals

        elif mode == "define":
            # Make window
            self.name = "Nuttall3a"
            self.psll = 64.2
            self.rov = 61.2
            self.nenbw = 1.7721
            self.w3db = 1.6828
            self.flatness = -1.0453
            self.length = N

    def _win_nuttall3b(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = 0.4243801 - 0.4973406 * cos(z) + 0.0782793 * cos(2.0 * z)

            return vals

        elif mode == "define":
            # Make window
            self.name = "Nuttall3b"
            self.psll = 71.5
            self.rov = 59.8
            self.nenbw = 1.7037
            self.w3db = 1.6162
            self.flatness = -1.1352
            self.length = N

    def _win_nuttall4(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                0.3125
                - 0.46875 * cos(z)
                + 0.1875 * cos(2.0 * z)
                - 0.03125 * cos(3.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "Nuttall4"
            self.psll = 60.9
            self.rov = 70.5
            self.nenbw = 2.31
            self.w3db = 2.1884
            self.flatness = -0.6184
            self.length = N

    def _win_nuttall4a(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                0.338946
                - 0.481973 * cos(z)
                + 0.161054 * cos(2.0 * z)
                - 0.018027 * cos(3.0 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "Nuttall4a"
            self.psll = 82.6
            self.rov = 68
            self.nenbw = 2.1253
            self.w3db = 2.0123
            self.flatness = -0.7321
            self.length = N

    def _win_nuttall4b(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                0.355768
                - 0.487396 * cos(z)
                + 0.144232 * cos(2 * z)
                - 0.012604 * cos(3 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "Nuttall4b"
            self.psll = 93.3
            self.rov = 66.3
            self.nenbw = 2.0212
            self.w3db = 1.9122
            self.flatness = -0.8118
            self.length = N

    def _win_nuttall4c(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                0.3635819
                - 0.4891775 * cos(z)
                + 0.1365995 * cos(2 * z)
                - 0.0106411 * cos(3 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "Nuttall4c"
            self.psll = 98.1
            self.rov = 65.6
            self.nenbw = 1.9761
            self.w3db = 1.8687
            self.flatness = -0.8506
            self.length = N

    def _win_rectangular(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N)
            vals = ones_like(n)

            return vals

        elif mode == "define":
            # Make window
            self.name = "rectangular"
            self.psll = 13.3
            self.rov = 0.0
            self.nenbw = 1.0
            self.w3db = 0.8845
            self.flatness = -3.9224
            self.length = N

    def _win_sft3f(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = 0.26526 - 0.5 * cos(z) + 0.23474 * cos(2 * z)

            return vals

        elif mode == "define":
            # Make window
            self.name = "SFT3F"
            self.psll = 31.7
            self.rov = 66.7
            self.nenbw = 3.1681
            self.w3db = 3.1502
            self.flatness = 0.0082
            self.length = N

    def _win_sft3m(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = 0.28235 - 0.52105 * cos(z) + 0.19659 * cos(2 * z)

            return vals

        elif mode == "define":
            # Make window
            self.name = "SFT3M"
            self.psll = 44.2
            self.rov = 65.5
            self.nenbw = 2.9452
            self.w3db = 2.9183
            self.flatness = -0.0115
            self.length = N

    def _win_sft4f(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                0.21706 - 0.42103 * cos(z) + 0.28294 * cos(2 * z) - 0.07897 * cos(3 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "SFT4F"
            self.psll = 44.7
            self.rov = 75
            self.nenbw = 3.7970
            self.w3db = 3.7618
            self.flatness = 0.0041
            self.length = N

    def _win_sft4m(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                0.241906
                - 0.460841 * cos(z)
                + 0.255381 * cos(2 * z)
                - 0.041872 * cos(3 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "SFT4M"
            self.psll = 66.5
            self.rov = 72.1
            self.nenbw = 3.3868
            self.w3db = 3.3451
            self.flatness = -0.0067
            self.length = N

    def _win_sft5f(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                0.1881
                - 0.36923 * cos(z)
                + 0.28702 * cos(2 * z)
                - 0.13077 * cos(3 * z)
                + 0.02488 * cos(4 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "SFT5F"
            self.psll = 57.3
            self.rov = 78.5
            self.nenbw = 4.3412
            self.w3db = 4.2910
            self.flatness = -0.0025
            self.length = N

    def _win_sft5m(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N) * 2.0 * pi
            z = n / N

            vals = (
                0.209671
                - 0.407331 * cos(z)
                + 0.281225 * cos(2 * z)
                - 0.092669 * cos(3 * z)
                + 0.0091036 * cos(4 * z)
            )

            return vals

        elif mode == "define":
            # Make window
            self.name = "SFT5M"
            self.psll = 89.9
            self.rov = 76
            self.nenbw = 3.8852
            self.w3db = 3.8340
            self.flatness = 0.0039
            self.length = N

    def _win_welch(self, mode="define", N=0):

        if mode == "build":
            if N == 0:
                N = self.length

            # Calculate the values of the window
            n = Specwin.__win_vec(N)
            z = n / N

            vals = 1.0 - pow((2.0 * z - 1), 2)

            return vals

        elif mode == "define":
            # Make window
            self.name = "Welch"
            self.psll = 21.3
            self.rov = 29.3
            self.nenbw = 1.2
            self.w3db = 1.1535
            self.flatness = -2.2248
            self.length = N

    # ----------------------------------------------------
    # Overrides
    # ----------------------------------------------------

    def __deepcopy__(self, memo):
        if self.name == "Kaiser":
            return Specwin(self.name, self.length, self.psll)
        else:
            return Specwin(self.name, self.length)

    def __eq__(self, w):
        """
        Returns true if the specwin has the same length and name.
        """

        if self.name == w.name and self.length == w.length:
            return True
        else:
            return False

    def __repr__(self):
        """
        Returns an evaluable string representation of a specwin.
        """
        if self.name == "Kaiser":
            sout = "Specwin('" + self.name + "', " + str(self.length) + ")"
        else:
            sout = (
                "Specwin('"
                + self.name
                + "', "
                + str(self.length)
                + ", "
                + str(self.psll)
                + ")"
            )

        return sout

    def __str__(self):
        s = "-------- Specwin ---------\n"
        s += "    name: " + self.name + "\n"
        s += "    psll: " + str(self.psll) + "\n"
        s += "     rov: " + str(self.rov) + "\n"
        s += "   nenbw: " + str(self.nenbw) + "\n"
        s += "    w3db: " + str(self.w3db) + "\n"
        s += "flatness: " + str(self.flatness) + "\n"
        s += "  length: " + str(self.length) + "\n"
        s += "-------------------------"
        return s

    # ----------------------------------------------------
    # properties
    # ----------------------------------------------------

    # length
    @property
    def length(self):
        "The length of the window."
        return self.__length

    @length.setter
    def length(self, length):
        if not isinstance(length, (int)):
            raise WrongDataTypeException("The length parameter must be an integer.")

        self.__length = length

    # name
    @property
    def name(self):
        "The name of the window."
        return self.__name

    @name.setter
    def name(self, name):
        if not isinstance(name, type("")):
            raise WrongDataTypeException("The name parameter must be a string.")

        self.__name = name

    # psll
    @property
    def psll(self):
        "The peak side-lobe level of the window function."
        return self.__psll

    @psll.setter
    def psll(self, psll):
        if not isinstance(psll, (int, float)):
            raise WrongDataTypeException("The psll parameter must be a number.")

        self.__psll = psll

    # rov
    @property
    def rov(self):
        "The recommended overlap for the window function."
        return self.__rov

    @rov.setter
    def rov(self, rov):
        if not isinstance(rov, (int, float)):
            raise WrongDataTypeException("The rov parameter must be a number.")

        self.__rov = rov

    # nenbw
    @property
    def nenbw(self):
        "The normalise equivalent noise bandwidth for the window function."
        return self.__nenbw

    @nenbw.setter
    def nenbw(self, nenbw):
        if not isinstance(nenbw, (int, float)):
            raise WrongDataTypeException("The nenbw parameter must be a number.")

        self.__nenbw = nenbw

    # w3db
    @property
    def w3db(self):
        """
        The 3dB bandwidth in bins for the window function.
        """
        return self.__w3db

    @w3db.setter
    def w3db(self, w3db):
        if not isinstance(w3db, (int, float)):
            raise WrongDataTypeException("The w3db parameter must be a number.")

        self.__w3db = w3db

    # flatness
    @property
    def flatness(self):
        "The flatness of the window function."
        return self.__flatness

    @flatness.setter
    def flatness(self, flatness):
        if not isinstance(flatness, (int, float)):
            raise WrongDataTypeException("The flatness parameter must be a number.")

        self.__flatness = flatness
