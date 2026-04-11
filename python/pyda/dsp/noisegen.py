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
from pyda.tsdata import TSData
from mpmath import *


class NoiseGen:
    """
    This class implements the Franklin noise generator.

    Franklin's noise generator is a method to generate arbitrarily
    long time series with a prescribed spectral density. The algorithm is based on the following paper:

    Franklin, Joel N.: Numerical simulation of stationary and non-stationary gaussian random processes , SIAM review, Volume { 7}, Issue 1, page 68--80, 1965.

    The Document Generation of Random time series with prescribed spectra by Gerhard Heinzel (S2-AEI-TN-3034)
    corrects a mistake in the aforesaid paper and describes the practical implementation.

    Initialise with a pole/zero model (PZModel) and a sample rate (fs).

    Example

    poles = [PZ(0.01,2), PZ(3)]
    zeros = [PZ(0.1), PZ(0.2)]
    pzm = PZModel(poles=poles, zeros=zeros, gain=2, delay=0)
    ng = NoiseGen(pzm=pzm, fs=30)
    ts = ng.generateNoise(1e5)


    """

    def __init__(self, pzm=None, fs=None):

        self.fs = fs
        self.pzm = pzm

        # ngconv
        self.num, self.den = NoiseGen.ngconv(pzm.zeros, pzm.poles)

        # ngsetup
        self.Tinit, self.Tprop, self.E = NoiseGen.ngsetup_mpa(self.den, fs)

        # nginit
        self.yinit = NoiseGen.nginit(self.Tinit)

    def generateNoise(self, nsecs, state=None):
        if state is not None:
            y, state = NoiseGen.ngprop(
                self.Tprop, self.E, self.num, state, self.fs, nsecs
            )
        else:
            y, state = NoiseGen.ngprop(
                self.Tprop, self.E, self.num, self.yinit, self.fs, nsecs
            )

        ts = TSData(
            yaxis=numpy.squeeze(y) * self.pzm.gain,
            fs=self.fs,
            name=self.pzm.name,
            yunits=self.pzm.ounits,
        )

        return ts, state

    @classmethod
    def fq2fac(cls, f, q):
        n = len(f)
        polzero = numpy.zeros((n, 3))

        for i in numpy.arange(0, n):
            if numpy.isnan(q[i]):
                polzero[i, 0:2] = [1.0, 1.0 / (2.0 * numpy.pi * f[i])]
            else:
                polzero[i, 0:3] = [
                    1.0,
                    1.0 / (2.0 * numpy.pi * f[i] * q[i]),
                    1.0 / ((2.0 * numpy.pi * f[i]) * (2.0 * numpy.pi * f[i])),
                ]

        return polzero

    @classmethod
    def ngconv(cls, zs, ps):

        f_zer = []
        q_zer = []
        for z in zs:
            f_zer = numpy.append(f_zer, z.f)
            q_zer = numpy.append(q_zer, z.q)

        f_pol = []
        q_pol = []
        for p in ps:
            f_pol = numpy.append(f_pol, p.f)
            q_pol = numpy.append(q_pol, p.q)

        # calculate factors from f and q
        pol = NoiseGen.fq2fac(f_pol, q_pol)
        zer = NoiseGen.fq2fac(f_zer, q_zer)

        [b, a] = NoiseGen.conv_noisegen(pol, zer)

        return a, b

    @classmethod
    def conv_noisegen(cls, pol, zer):

        [m, k] = pol.shape
        [n, l] = zer.shape

        coefb = pol[0, :]

        for i in numpy.arange(1, m):
            coefb = numpy.convolve(coefb, pol[i, :])

        b = coefb[numpy.nonzero(coefb)]

        if n != 0:
            coefa = zer[0, :]
            for i in numpy.arange(1, n):
                coefa = numpy.convolve(coefa, zer[i, :])
            a = coefa[numpy.nonzero(coefa)]
        else:
            a = 1

        # normalize to bn = 1
        m = len(b)
        normfac = b[m - 1]
        b /= normfac
        a /= normfac * numpy.sqrt(2)

        return b, a

    @classmethod
    def ngsetup(cls, den, fs):

        dt = 1.0 / fs

        n = len(den) - 1

        # setting up matrix Aij

        m_a = numpy.zeros((n, n))
        for i in numpy.arange(0, n):
            for j in numpy.arange(0, n):
                if j == i + 1:
                    m_a[i, j] = 1
                if i == n - 1:
                    m_a[i, j] = -den[j]

        # print(f"m_a = {m_a}")

        # Matrix exponential E
        E = scipy.linalg.expm(m_a * dt)

        # setting up matrix Bij
        B = numpy.zeros((n, n))
        for i in numpy.arange(0, n):
            if numpy.remainder(i + 1, 2) != 0:
                j0 = (i + 2) / 2
                # print(f"j0 = {j0}")
                s = (-1.0) ** (j0 + 1)
                j = int(j0) - 1
                # print(f"j = {j}")
                # print(f"s = {s}")
                for k in range(0, (n + 1), 2):
                    # print(f"i = {i}")
                    # print(f"k = {k}")
                    B[i, j] = s * den[k]
                    s = -s
                    j = j + 1
            else:
                j0 = (i + 1) / 2 + 1
                # print(f"j0 = {j0}")
                s = (-1.0) ** j0
                j = int(j0) - 1
                # print(f"j = {j}")
                # print(f"s = {s}")
                for k in numpy.arange(1, (n + 1), 2):
                    # print(f"i = {i}")
                    # print(f"j = {j}")
                    B[i, j] = s * den[k]
                    s = -s
                    j = j + 1

        # solve B * m = k
        m_k = numpy.zeros(n)
        m_k[n - 1] = 0.5
        # m_m = B\m_k;
        # print(B)
        # print(m_k)
        m_m, resid, rank, s = numpy.linalg.lstsq(B, m_k, rcond=None)
        # print(m_m)

        # filling covariance matrix Cinit
        Cinit = numpy.zeros((n, n))
        for i in numpy.arange(0, n):
            for j in numpy.arange(0, n):
                if numpy.remainder((i + j), 2) == 0:  # even
                    Cinit[i, j] = (-1) ** ((i - j) / 2) * m_m[int((i + j) / 2)]
                else:
                    Cinit[i, j] = 0

        # cholesky decomposition
        Tinit = numpy.linalg.cholesky(Cinit)  # lower triangular matrix

        # setting up matrix D
        N = int(n * (n + 1) / 2)

        m_d = numpy.zeros((N, N))
        g = numpy.zeros((n, n))
        for i in numpy.arange(0, n):
            for j in numpy.arange(0, n):
                if i >= j:
                    g[i, j] = int(((i + 1) * (i + 1) - (i + 1)) / 2 + j)
                else:
                    g[i, j] = int(((j + 1) * (j + 1) - (j + 1)) / 2 + i)

        g = g.astype(int)
        # print(g)

        for i in numpy.arange(0, n):
            for j in numpy.arange(i, n):
                for k in numpy.arange(0, n):
                    m_d[g[i, j], g[j, k]] += m_a[i, k]
                    m_d[g[i, j], g[i, k]] += m_a[j, k]

        # setting up q from D * p = q
        m_q = numpy.zeros(g[n - 1, n - 1] + 1)
        for i in numpy.arange(0, n):
            # print(f"i = {i}")
            for j in numpy.arange(i, n):
                # print(f"j = {j}")
                if i == n - 1:
                    m_q[g[i, j]] = E[n - 1, n - 1] * E[n - 1, n - 1] - 1
                else:
                    m_q[g[i, j]] = E[i, n - 1] * E[j, n - 1]

        # m_p = m_d\m_q';
        # print(m_d)
        # print(m_q)
        m_p, resid, rank, s = numpy.linalg.lstsq(m_d, m_q, rcond=None)
        # print(m_p)

        Cprop = numpy.zeros((n, n))
        for i in numpy.arange(0, n):
            for j in numpy.arange(0, n):
                Cprop[i, j] = m_p[g[i, j]]

        Tprop = numpy.linalg.cholesky(Cprop)  # lower triangular matrix

        return Tinit, Tprop, E

    @classmethod
    def ngsetup_mpa(cls, den, fs):

        # set fairly high precision. Seems to be enough for most typical cases
        mp.dps = 32

        dt = 1.0 / fs

        n = len(den) - 1

        # setting up matrix Aij

        m_a = numpy.zeros((n, n))
        for i in numpy.arange(0, n):
            for j in numpy.arange(0, n):
                if j == i + 1:
                    m_a[i, j] = 1
                if i == n - 1:
                    m_a[i, j] = -den[j]

        # print(f"m_a = {m_a}")

        # Matrix exponential E
        # E = scipy.linalg.expm(m_a * dt)
        E = expm(m_a * dt)

        # setting up matrix Bij
        B = numpy.zeros((n, n))
        for i in numpy.arange(0, n):
            if numpy.remainder(i + 1, 2) != 0:
                j0 = (i + 2) / 2
                # print(f"j0 = {j0}")
                s = (-1.0) ** (j0 + 1)
                j = int(j0) - 1
                # print(f"j = {j}")
                # print(f"s = {s}")
                for k in range(0, (n + 1), 2):
                    # print(f"i = {i}")
                    # print(f"k = {k}")
                    B[i, j] = s * den[k]
                    s = -s
                    j = j + 1
            else:
                j0 = (i + 1) / 2 + 1
                # print(f"j0 = {j0}")
                s = (-1.0) ** j0
                j = int(j0) - 1
                # print(f"j = {j}")
                # print(f"s = {s}")
                for k in numpy.arange(1, (n + 1), 2):
                    # print(f"i = {i}")
                    # print(f"j = {j}")
                    B[i, j] = s * den[k]
                    s = -s
                    j = j + 1

        # solve B * m = k
        m_k = numpy.zeros(n)
        m_k[n - 1] = 0.5
        # m_m = B\m_k;
        # print(B)
        # print(m_k)
        m_m, resid, rank, s = numpy.linalg.lstsq(B, m_k, rcond=None)
        m_m = lu_solve(B, m_k)
        # print(m_m)

        # filling covariance matrix Cinit
        Cinit = zeros(n)
        for i in numpy.arange(0, n):
            for j in numpy.arange(0, n):
                if numpy.remainder((i + j), 2) == 0:  # even
                    Cinit[i, j] = (-1) ** ((i - j) / 2) * m_m[int((i + j) / 2)]
                else:
                    Cinit[i, j] = 0

        # cholesky decomposition
        Tinit = cholesky(Cinit)  # lower triangular matrix

        # setting up matrix D
        N = int(n * (n + 1) / 2)

        m_d = numpy.zeros((N, N))
        g = numpy.zeros((n, n))
        for i in numpy.arange(0, n):
            for j in numpy.arange(0, n):
                if i >= j:
                    g[i, j] = int(((i + 1) * (i + 1) - (i + 1)) / 2 + j)
                else:
                    g[i, j] = int(((j + 1) * (j + 1) - (j + 1)) / 2 + i)

        g = g.astype(int)
        # print(g)

        for i in numpy.arange(0, n):
            for j in numpy.arange(i, n):
                for k in numpy.arange(0, n):
                    m_d[g[i, j], g[j, k]] += m_a[i, k]
                    m_d[g[i, j], g[i, k]] += m_a[j, k]

        # setting up q from D * p = q
        m_q = numpy.zeros(g[n - 1, n - 1] + 1)
        for i in numpy.arange(0, n):
            # print(f"i = {i}")
            for j in numpy.arange(i, n):
                # print(f"j = {j}")
                if i == n - 1:
                    m_q[g[i, j]] = E[n - 1, n - 1] * E[n - 1, n - 1] - 1
                else:
                    m_q[g[i, j]] = E[i, n - 1] * E[j, n - 1]

        # m_p = m_d\m_q';
        # print(m_d)
        # print(m_q)
        # m_p2, resid, rank, s = numpy.linalg.lstsq(m_d, m_q, rcond=None)
        m_p = lu_solve(m_d, m_q)
        # m_p = numpy.array(m_p.tolist(),dtype=numpy.float64)

        # print(m_p2)
        # print(m_p)
        # print(m_p[0])

        Cprop = zeros(n)
        # print(Cprop)
        for i in numpy.arange(0, n):
            for j in numpy.arange(0, n):
                idx = int(g[i, j])
                Cprop[i, j] = m_p[idx]

        # print(Cprop)
        Tprop = cholesky(Cprop)  # lower triangular matrix

        Tinit = numpy.array(Tinit.tolist(), dtype=float)
        Tprop = numpy.array(Tprop.tolist(), dtype=float)
        E = numpy.array(E.tolist(), dtype=float)

        # print(Tinit)
        # print(Tprop)
        # print(E)

        return Tinit, Tprop, E

    @classmethod
    def nginit(cls, Tinit):
        n = len(Tinit)
        # writing the generator
        r = numpy.random.randn(1, n)
        y = numpy.inner(Tinit, r)
        return y

    @classmethod
    def ngprop(cls, Tprop, E, num, y, fs, nsecs):

        ns = int(fs * nsecs)
        lengT = len(Tprop)
        lengb = lengT + 1

        y = numpy.squeeze(y)
        num = numpy.squeeze(num)

        # print(num.shape)
        num = numpy.append(num, numpy.zeros((1, (lengb - len(num) - 1))))
        # print(num.shape)
        x = numpy.zeros((ns, 1))
        # print(x.shape)
        R = numpy.random.randn(ns, lengT)
        RT = numpy.inner(Tprop, R)
        for ii in numpy.arange(0, ns):
            # print("y shape = " + str(y.shape))
            # print("num shape = " + str(num.shape))
            y = numpy.inner(E, y) + RT[:, ii]  # Tprop * R(:,ii);
            # print("y shape = " + str(y.shape))
            # print(f"num = {num}")
            # print(f"y = {y}")
            # print(val)
            x[ii] = numpy.inner(num, y)

        return x, y
