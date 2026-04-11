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
from pyda.utils.math import *


class TSDataDSP:
    def resample(self, fsout=None, filter=None):
        """
        Resample the input time-series to the specified output sample rate.

        calls scipy.signal.resample_poly

        :param fsout: output sample rate
        :param filter: FIR filter to apply in the resampling process.
        """
        out = self.deepcopy()

        # Compute the resampling factors
        [P_fs, Q_fs] = intfact(fsout, self.fs())
        [Q_Ts, P_Ts] = intfact(1 / fsout, 1.0 / self.fs())
        if P_fs <= P_Ts:
            P = P_fs
            Q = Q_fs
        else:
            P = P_Ts
            Q = Q_Ts

        print(f"resampling by {P}/{Q}")

        if filter is None:
            newy = scipy.signal.resample_poly(x=self.ydata(), up=P, down=Q)
            out.yaxis.data = newy
        else:
            b = filter.a
            newy = scipy.signal.resample_poly(x=self.ydata(), up=P, down=Q, window=b)
            out.yaxis.data = newy

        step = 1.0 / fsout
        N = newy.size
        out.xaxis.data = numpy.arange(
            start=out.xaxis.data[0], stop=N / fsout, step=step
        )

        # clear errors (what else can we do?)
        out.xaxis.ddata = 0
        out.yaxis.ddata = 0

        out.name = "resample(" + out.name + ")"
        return out

    def delay(self, tau: float = 0, taps: int = 51, method: str = "fdfilter") -> object:
        """
        Delay time-series data using different methods.

        Delay methods
            "fdfilter": fractional delay filtering

        :param tau: time to delay in seconds
        :param taps: number of filter taps/coefficients for fractional delay filtering
        :param method: see methods above.
        :return: delayed time-series object (TSData)
        """

        if method.lower() == "fdfilter":
            D = tau * self.fs()
            vals = TSDataDSP._fdfilt_delay(y=self.ydata(), D=D, N=taps)
        else:
            raise Exception(f"Unknown method {method}")

        out = self.deepcopy()
        out.yaxis.data = vals
        out.name = "delay(" + out.name + ")"
        return out

    def unwrap(self, **kwargs):
        """
        Unwrap phase data.
        """
        out = self.deepcopy()
        out.yaxis.data = numpy.unwrap(self.ydata(), **kwargs)
        out.name = "unwrap(" + out.name + ")"
        return out

    @classmethod
    def _fdfilt_delay(cls, y=None, D=0, N=51):

        # check if delay is an integer number of samples
        if numpy.mod(D, 1) == 0:
            Di = int(D)
            yd = numpy.zeros(y.size)
            if Di > 0:
                yd[Di:-1] = y[0 : -Di - 1]
            else:
                yd[0:Di] = y[-Di:-1]

            return yd

        # otherwise use combination integer and fractional delay
        else:

            # define k
            k = numpy.arange(start=-(N - 1) / 2, stop=1 + (N - 1) / 2)

            # compute window
            w = (
                0.42
                + 0.5 * numpy.cos((2 * numpy.pi * k) / (N - 1))
                + 0.08 * numpy.cos((4 * numpy.pi * k) / (N - 1))
            ) ** 3

            # integer portion of delay
            Dint = round(D)

            # compute filter kernel
            h = numpy.sinc(D - Dint - k) * w
            h = h / sum(h)

            # compute mean
            m = numpy.mean(y)

            # zero-pad
            S = y.size
            Npad = numpy.amax([Dint, N])
            if numpy.mod(Npad, 2) == 0:
                Npad = Npad + 1

            zpad = numpy.zeros(Npad)
            z = numpy.append(zpad, y - numpy.ones(S) * m)
            z = numpy.append(z, zpad)

            # perform fractional delay
            yd = scipy.signal.lfilter(h, 1, z)

            # add mean value back in
            yd = yd + numpy.ones(yd.size) * m

            # pull out desired piece
            startIdx = int(Npad + (N - 1) / 2 - Dint + 1)
            stopIdx = int(startIdx + S - 1)

            yd = yd[startIdx - 1 : stopIdx]

            return yd



