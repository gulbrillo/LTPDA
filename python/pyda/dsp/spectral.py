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

import numpy
import scipy
import scipy.signal

import pyda.utils.math
from pyda.utils.math import normal_round
from pyda.utils.specwin import Specwin

import lpsd
import pandas
import pyda

from pyda.utils.unit import Unit
from pyda.xydata import XYData
from pyda.tsdata import TSData
from pyda.fsdata import FSData
from scipy.stats import norm


# ---------------------------------------
# Log-axis estimators
# ---------------------------------------


def logpsd(
    ts=None,
    window_function=numpy.hanning,
    psll=200,
    olap=50,
    bmin=1,
    Lmin=0,
    Jdes=1000,
    Kdes=100,
    order=0,
    scale="PSD",
):
    """
    Computes log-scale PSD as described in:
        https://www.sciencedirect.com/science/article/abs/pii/S026322410500117X?via%3Dihub

    Requires pandas and lpsd (from https://git.physnet.uni-hamburg.de/gwd/lpsd)

    :param ts: input time-series
    :param window_function: a numpy window function
    :param psll: peak side-lobe suppression for kaiser windows
    :param olap: % overlap
    :param bmin: minimum bin number to be used
    :param Lmin: minimum segment length
    :param Jdes: desired number of frequencies
    :param Kdes: desired number of averages
    :param order:
    :param scale:
    :return:
    """

    print("* computing lpsd of " + ts.name + " ...")

    # Create pandas DataFrame
    d = pandas.DataFrame(
        data=ts.ydata(),
        index=pandas.Series(ts.xdata(), name="Time (s)"),
        columns=["Data"],
    )

    # Call lpsd()
    Pxx = lpsd.lpsd(
        d,
        detrending_order=order,
        n_averages=Kdes,
        n_frequencies=Jdes,
        window_function=window_function,
        overlap=olap / 100.0,
        min_segment_length=Lmin,
        n_min_bins=bmin,
        psll=psll,
    )

    # extract data
    if scale == "PSD":
        Pxxd = Pxx["psd"].values
        Pvxd = Pxx["psd_std"].values
    elif scale == "ASD":
        Pxxd = numpy.sqrt(["psd"].values)
        Pvxd = numpy.sqrt(Pxx["psd_std"].values)
    elif scale == "PS":
        Pxxd = Pxx["ps"].values
        Pvxd = Pxx["ps_std"].values
    elif scale == "AS":
        Pxxd = numpy.sqrt(Pxx["ps"].values)
        Pvxd = numpy.sqrt(Pxx["ps_std"].values)
    else:
        raise Exception("Unknown PSD scaling supplied: " + scale)

    # set output yunits
    yu = ts.yaxis.units
    if scale == "PSD":
        if not yu.strs:
            ou = Unit("1/Hz")
        else:
            ou = yu**2
            ou = ou / Unit("Hz")
    elif scale == "PS":
        ou = yu**2
    elif scale == "ASD":
        if not yu.strs:
            ou = Unit("Hz^-0.5")
        else:
            ou = yu / Unit("Hz^0.5")
    elif scale == "AS":
        ou = yu
    else:
        raise Exception("Unknown PSD scaling supplied: " + scale)

    f = Pxx.index.values

    Sxx = FSData(
        xaxis=f,
        yaxis=numpy.abs(Pxxd),
        yunits=ou,
        name="L" + scale + "(" + ts.name + ")",
    )
    Sxx.yaxis.ddata = Pvxd

    return Sxx


# ---------------------------------------
# Standard welch-type estimators
# ---------------------------------------


def mscohere(
    ts_a: TSData = None,
    ts_b: TSData = None,
    window: str = "Hanning",
    navs: numbers.Number = None,
    percent_overlap: numbers.Number = None,
    Nfft: numbers.Number = None,
    detrend_order: int = 0,
) -> FSData:
    """
    Compute magnitude squared coherence of the two input time-series.

    :param ts_a:
    :param ts_b:
    :param window:
    :param navs:
    :param percent_overlap:
    :param Nfft:
    :param detrend_order:
    :return:
    """
    scale = "PSD"

    Nfft, win, percent_overlap = _process_spectral_options(
        ts_a=ts_a,
        ts_b=ts_b,
        window=window,
        navs=navs,
        percent_overlap=percent_overlap,
        Nfft=Nfft,
        scale=scale,
    )

    # Call wosa here
    Pxx, f, info, dev = _wosa(
        a=ts_a,
        b=ts_b,
        winVals=win.win(),
        olap=percent_overlap,
        nfft=Nfft,
        esttype="mscohere",
        scale=scale,
        detrendOrder=detrend_order,
    )

    # scale output
    Pxx, ou = _scale_output(Pxx, scale, info)

    Sxx = FSData(
        xaxis=f,
        yaxis=Pxx,
        yunits=ou,
        name="mscohere(" + ts_a.name + ", " + ts_b.name + ")",
    )
    Sxx.yaxis.ddata = dev

    return Sxx


def cohere(
    ts_a: TSData = None,
    ts_b: TSData = None,
    window: str = "Hanning",
    navs: numbers.Number = None,
    percent_overlap: numbers.Number = None,
    Nfft: numbers.Number = None,
    detrend_order: int = 0,
) -> FSData:
    """
    Compute complex coherence between two input time-series.

    :param ts_a:
    :param ts_b:
    :param window:
    :param navs:
    :param percent_overlap:
    :param Nfft:
    :param detrend_order:
    :return:
    """
    scale = "PSD"

    Nfft, win, percent_overlap = _process_spectral_options(
        ts_a=ts_a,
        ts_b=ts_b,
        window=window,
        navs=navs,
        percent_overlap=percent_overlap,
        Nfft=Nfft,
        scale=scale,
    )

    # Call wosa here
    Pxx, f, info, dev = _wosa(
        a=ts_a,
        b=ts_b,
        winVals=win.win(),
        olap=percent_overlap,
        nfft=Nfft,
        esttype="cohere",
        scale=scale,
        detrendOrder=detrend_order,
    )

    # scale output
    Pxx, ou = _scale_output(Pxx, scale, info)

    Sxx = FSData(
        xaxis=f,
        yaxis=Pxx,
        yunits=ou,
        name="Cohere(" + ts_a.name + ", " + ts_b.name + ")",
    )
    Sxx.yaxis.ddata = dev

    return Sxx


def cpsd(
    ts_a: TSData = None,
    ts_b: TSData = None,
    window: str = "Hanning",
    navs: numbers.Number = None,
    percent_overlap: numbers.Number = None,
    Nfft: numbers.Number = None,
    detrend_order: int = 0,
) -> FSData:
    """
    Compute cross-power-spectral-density of the two input timeseries.

    :param ts_a:
    :param ts_b:
    :param window:
    :param navs:
    :param percent_overlap:
    :param Nfft:
    :param detrend_order:
    :return:
    """
    scale = "PSD"

    Nfft, win, percent_overlap = _process_spectral_options(
        ts_a=ts_a,
        ts_b=ts_b,
        window=window,
        navs=navs,
        percent_overlap=percent_overlap,
        Nfft=Nfft,
        scale=scale,
    )

    # Call wosa here
    Pxx, f, info, dev = _wosa(
        a=ts_a,
        b=ts_b,
        winVals=win.win(),
        olap=percent_overlap,
        nfft=Nfft,
        esttype="cpsd",
        scale=scale,
        detrendOrder=detrend_order,
    )

    # scale output
    Pxx, ou = _scale_output(Pxx, scale, info)

    Sxx = FSData(
        xaxis=f, yaxis=Pxx, yunits=ou, name="CPSD(" + ts_a.name + ", " + ts_b.name + ")"
    )
    Sxx.yaxis.ddata = dev

    return Sxx


def tfe(
    ts_a: TSData = None,
    ts_b: TSData = None,
    window: str = "Hanning",
    navs: numbers.Number = None,
    percent_overlap: numbers.Number = None,
    Nfft: numbers.Number = None,
    detrend_order: int = 0,
) -> FSData:
    """
    Compute a transfer function estimate between the two input time-series.

    :param ts_a:
    :param ts_b:
    :param window:
    :param navs:
    :param percent_overlap:
    :param Nfft:
    :param detrend_order:
    :return:
    """
    scale = "PSD"

    Nfft, win, percent_overlap = _process_spectral_options(
        ts_a=ts_a,
        ts_b=ts_b,
        window=window,
        navs=navs,
        percent_overlap=percent_overlap,
        Nfft=Nfft,
        scale=scale,
    )

    # Call wosa here
    Pxx, f, info, dev = _wosa(
        a=ts_a,
        b=ts_b,
        winVals=win.win(),
        olap=percent_overlap,
        nfft=Nfft,
        esttype="tfe",
        scale=scale,
        detrendOrder=detrend_order,
    )

    # scale output
    Pxx, ou = _scale_output(Pxx, scale, info)

    Sxx = FSData(
        xaxis=f, yaxis=Pxx, yunits=ou, name="TF(" + ts_a.name + ", " + ts_b.name + ")"
    )
    Sxx.yaxis.ddata = dev

    return Sxx


def psd(
    ts: TSData = None,
    window: str = "Hanning",
    navs: numbers.Number = None,
    percent_overlap: numbers.Number = None,
    Nfft: numbers.Number = None,
    scale: str = "PSD",
    detrend_order: int = 0,
) -> FSData:
    """
    Compute PSD of input TSData object.

    Uses scipy.signal.welch

    :param scale: choose from 'PSD', 'PS', 'ASD', or 'AS'
    :param ts:
    :param window:
    :param navs:
    :param percent_overlap:  overlap in %
    :param Nfft:
    :param detrend_order:
    :return:
    :rtype: FSData
    """

    Nfft, win, percent_overlap = _process_spectral_options(
        ts_a=ts,
        window=window,
        navs=navs,
        percent_overlap=percent_overlap,
        Nfft=Nfft,
        scale=scale,
    )

    # Call wosa here
    Pxx, f, info, dev = _wosa(
        a=ts,
        b=None,
        winVals=win.win(),
        olap=percent_overlap,
        nfft=Nfft,
        esttype="psd",
        scale=scale,
        detrendOrder=detrend_order,
    )

    # scale output
    ou = info["units"]
    Sxx = FSData(xaxis=f, yaxis=Pxx, yunits=ou, name=scale + "(" + ts._name + ")")
    Sxx.yaxis.ddata = dev

    return Sxx


def logBinPSD(
    ts: TSData = None,
    window: str = "BH92",
    Nmax: int = None,
    fmax: float = None,
    Nsigma: float = 1,
    order=0,
):
    """
    Computes a binned PSD estimate with minimal correlation.



    :return:
    """

    p = norm.cdf([-Nsigma, Nsigma])
    c = p[1] - p[0]

    if not Nmax:
        Nseg = ts.size()
    else:
        Nseg = Nmax

    if not fmax:
        flim = ts.fs() / 2
    else:
        flim = fmax

    detrendOrder = 1

    # Compute frequencies

    dT = 1 / ts.fs()
    M = 4

    r = 3 / 5
    f = M / (Nseg * dT)
    print(f"f(1) = {f}, N={numpy.floor(Nseg)}\n")
    L = [Nseg]
    kk = 2
    freqs = [f]

    while f < flim:
        N = r ** (kk - 2) * Nseg
        f = 2 * M / (N * dT)
        L.append(N)
        kk += 1
        freqs.append(f)

    # drop last frequency
    freqs = freqs[:-1]

    # Process segments
    fs = ts.fs()
    Ndata = ts.size()
    x = ts.xdata()
    y = ts.ydata()
    olap = 50  # %
    nf = freqs.__len__()

    ENBW = numpy.zeros(nf)
    Sxx = numpy.zeros(nf)
    S = numpy.zeros(nf)
    Smin = numpy.zeros(nf)
    Smax = numpy.zeros(nf)
    navs = numpy.zeros(nf)

    jj = 0
    for f in freqs:
        print(f"computing frequency {jj} of {nf}: {freqs[jj]} Hz")

        # compute DFT exponent and window
        l = int(numpy.floor(L[jj]))

        win = Specwin("BH92", int(l))

        # window vector
        wvals = win.win()

        # segment start indices
        sidx = numpy.arange(0, Ndata - l, l * olap / 100, dtype=int)
        # print(f"sidx = {sidx}")

        # dft coefficients
        p = -2 * numpy.pi * 1j * numpy.arange(0, l) / fs
        C = numpy.exp(freqs[jj] * p)
        # print(f"C = {C}")
        navs[jj] = sidx.__len__()

        A = 0.0

        # average
        for ii in numpy.arange(0, navs[jj], dtype=int):

            # start and end indices for the current segment
            istart = sidx[ii]
            iend = istart + l

            # print(f"istart = {istart}, iend = {iend}")

            # get segment data
            xs = x[istart:iend]
            ys = y[istart:iend]

            # detrend segment
            if order == -1:
                pass
            elif order == 0:
                ys = ys - numpy.mean(ys)
            else:
                ys = XYData._polydetrend(xs, ys, order)

            # window data
            ys = [wvals * ys]

            # make DFT
            a = numpy.inner(C, ys)
            A = A + numpy.abs(numpy.inner(a, numpy.conj(a)))

        # scale and store results
        S1 = win.win().sum()
        S12 = S1 * S1
        S2 = (win.win() ** 2).sum()
        # print(f"S2 = {S2}")
        A2ns = 2 * A / navs[jj]
        ENBW[jj] = fs * S2 / S12
        Sxx[jj] = A2ns / fs / S2
        S[jj] = A2ns / S12

        a = navs[jj] - 1
        z = (1 + c) / 2
        gm = scipy.special.gammaincinv(a, z)
        Smin[jj] = navs[jj] * Sxx[jj] / gm

        z = (1 - c) / 2
        gm = scipy.special.gammaincinv(a, z)
        Smax[jj] = navs[jj] * Sxx[jj] / gm

        jj += 1  # next frequency

    info = {}
    info["units"] = ts.yaxis.units
    info["nfft"] = L
    info["enbw"] = ENBW
    info["norm"] = norm

    # scale output
    scale = "PSD"
    Sxx, ou = _scale_output(Sxx, scale, info)
    # err = numpy.array([Sxx-Smin, Sxx+Smax])
    err = numpy.array([Smin, Smax])

    Sxx = FSData(
        xaxis=numpy.array(freqs),
        yaxis=Sxx,
        yunits=ou,
        name=scale + "(" + ts._name + ")",
    )
    Sxx.marker = "."
    Sxx.markersize = 20
    Sxx.linestyle = "none"
    # Sxx.yaxis.ddata = err

    Smin = FSData(
        xaxis=numpy.array(freqs),
        yaxis=Smin,
        yunits=ou,
        name=scale + "(" + ts._name + ")",
    )
    Smax = FSData(
        xaxis=numpy.array(freqs),
        yaxis=Smax,
        yunits=ou,
        name=scale + "(" + ts._name + ")",
    )

    return Sxx, Smin, Smax


# -----------------------------------------------------------
# -----------------------------------------------------------
# ---------------- Private functions
# -----------------------------------------------------------
# -----------------------------------------------------------


def _process_spectral_options(
    ts_a: TSData = None,
    ts_b: TSData = None,
    window: str = "Hanning",
    navs: int = None,
    percent_overlap: numbers.Number = None,
    Nfft: numbers.Number = None,
    scale: str = "PSD",
    detrend_order: int = 0,
) -> tuple:
    if not isinstance(ts_a, TSData):
        raise Exception("psd acts only on TSData objects")

    if not isinstance(ts_a, TSData):
        raise Exception("psd acts only on TSData objects")

    # start with a default NFFT if not specified
    if not Nfft:
        Nfft = ts_a.size()

    # deal with the specified window
    win = Specwin(window, Nfft)

    # deal with overlap
    if not percent_overlap:
        # get the recommended overlap from the window
        percent_overlap = win.rov

    overlap = percent_overlap / 100

    # handle the case if the user specifies the number of averages
    if navs and navs > 1:
        # Compute the number of segments
        M = ts_a.size()
        L = normal_round(M / (navs * (1 - overlap) + overlap))
        # print('Asked for navs = ' + str(navs))
        # Checks it will really obtain the correct answer.
        # This is needed to cope with the need to work with integers
        while (
            numpy.fix((M - normal_round(L * overlap)) / (L - normal_round(L * overlap)))
            < navs
        ):
            L = L - 1

        navs_actual = numpy.fix(
            (M - normal_round(L * overlap)) / (L - normal_round(L * overlap))
        )
        # print('Expect to get navs_actual = ' + str(navs_actual))

        if L > 0:
            # Reset Nfft
            Nfft = L
            # reset window for new segment length
            win = Specwin(window, Nfft)

    # call welch
    olap = numpy.floor(Nfft * overlap)
    print(
        "Processing "
        + scale
        + " with segments of length "
        + str(Nfft)
        + " and overlap of "
        + str(olap)
        + " samples ("
        + str(percent_overlap)
        + "%)"
    )

    return Nfft, win, percent_overlap


def _scale_output(Pxx, scale, info):

    # if scale == "ASD" or scale == "AS":
    #     Pxx = numpy.sqrt(Pxx)

    # set output yunits
    yu = info["units"]
    if scale == "PSD":
        if not yu.strs:
            ou = pyda.utils.unit.Unit("1/Hz")
        else:
            ou = yu**2
            ou = ou / pyda.utils.unit.Unit("Hz")
    elif scale == "PS":
        ou = yu**2
    elif scale == "ASD":
        if not yu.strs:
            ou = pyda.utils.unit.Unit("Hz^-0.5")
        else:
            ou = yu / pyda.utils.unit.Unit("Hz^0.5")
    elif scale == "AS":
        ou = yu
    else:
        raise Exception("Unknown PSD scaling supplied: " + scale)

    return Pxx, ou


# scale averaged periodogram to PSD
def _scaleToPSD(Sxx: numpy.ndarray, Svxx: numpy.ndarray, nfft: int, fs: float):
    # Take 1-sided spectrum which means we double the power in the
    # appropriate bins
    if numpy.remainder(nfft, 2) > 0:
        indices = numpy.arange(start=0, step=1, stop=nfft / 2, dtype=int)  # ODD
        Sxx1sided = Sxx[indices]
        # double the power except for the DC bin
        Sxx = numpy.concatenate(([Sxx1sided[0]], 2 * Sxx1sided[1:None]))
        if Svxx.size > 0:
            Svxx1sided = Svxx[indices]
            Svxx = numpy.concatenate(([Svxx1sided[0]], 4 * Svxx1sided[1:None]))
    else:
        indices = numpy.arange(start=0, step=1, stop=nfft / 2 + 1, dtype=int)  # EVEN
        Sxx1sided = Sxx[indices]
        # Double power except the DC bin and the Nyquist bin
        Sxx = numpy.concatenate(([Sxx1sided[0]], 2 * Sxx1sided[1:-1], [Sxx1sided[-1]]))
        if Svxx.size > 0:
            Svxx1sided = Svxx[indices]  # Take only [0,pi] or [0,pi)
            Svxx = numpy.concatenate(
                ([Svxx1sided[0]], 4 * Svxx1sided[1:-1], [Svxx1sided[-1]])
            )

    # Now scale to PSD
    Pxx = Sxx / fs
    Pvxx = Svxx / fs**2

    return Pxx, Pvxx


def _welchscale(xx, dxx, win: numpy.ndarray, fs, norm, inunits):
    nfft = win.size
    S1 = win.sum()
    S2 = (win**2).sum()
    enbw = fs * S2 / (S1 * S1)

    info = {}

    lnorm = norm.lower()

    if lnorm == "asd":
        yy = numpy.sqrt(xx)
        if dxx is None:
            dyy = dxx
        else:
            dyy = 1 / 2 / numpy.sqrt(xx) * dxx
        info["units"] = inunits / Unit("Hz^0.5")
    elif lnorm == "psd":
        yy = xx
        dyy = dxx
        info["units"] = inunits**2 / Unit("Hz")
    elif lnorm == "as":
        yy = numpy.sqrt(xx * enbw)
        if dxx is None:
            dyy = dxx
        else:
            dyy = 1.0 / 2.0 / numpy.sqrt(xx) * dxx * enbw
        info["units"] = inunits
    elif lnorm == "ps":
        yy = xx * enbw
        dyy = dxx * enbw
        info["units"] = inunits**2
    elif lnorm == "none":
        yy = xx
        dyy = dxx
        info["units"] = inunits
    else:
        raise Exception("Unknown normalisation " + lnorm)

    info["nfft"] = nfft
    info["enbw"] = enbw
    info["norm"] = norm

    return yy, dyy, info


def _wosa(
    a=None,
    b=None,
    winVals=None,
    olap=None,
    nfft=None,
    esttype="psd",
    scale="psd",
    detrendOrder=0,
):
    if not isinstance(a, TSData):
        raise Exception("_wosa requires input TSData")

    if b and not isinstance(b, TSData):
        raise Exception("_wosa requires input TSData")

    if b:
        if a.fs() != b.fs() or a.size() != b.size():
            raise Exception(
                "The two input time-series should have the same length and sample rate"
            )

        inunits = b.yaxis.units / a.yaxis.units
    else:
        inunits = a.yaxis.units

    L = a.size()
    fs = a.fs()

    # print("nfft = " + str(nfft))
    # print("L = " + str(L))

    # Compute segment details
    xOlap = normal_round(olap * nfft / 100.0)  # % Should this be round or floor?
    # print("xOlap = " + str(xOlap))
    nSegments = int(numpy.fix((L - xOlap) / (nfft - xOlap)))
    # print("nSegments = " + str(nSegments))

    # Compute start and end indices of each segment
    segmentStep = nfft - xOlap
    segmentStarts = numpy.arange(
        start=0, step=segmentStep, stop=nSegments * segmentStep
    )
    segmentEnds = segmentStarts + nfft - 1

    Sxy = numpy.empty((0, 0))
    Syy = numpy.empty((0, 0))
    Svxx = numpy.empty((0, 0))

    ltype = esttype.lower()
    if ltype == "psd":
        Sxx, Svxx = _psdPeriodogram(
            a, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder
        )
    elif ltype == "cpsd":
        Sxx, Svxx = _cpsdPeriodogram(
            a, b, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder
        )
    elif ltype in ["mscohere", "cohere", "tfe"]:
        Sxx, Sxy, Syy = _tfePeriodogram(
            a, b, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder
        )
    else:
        raise Exception("Unknown estimation type " + esttype)

    # Scale to PSD
    if ltype in ["psd", "cpsd"]:
        P, Pvxx = _scaleToPSD(Sxx, Svxx, nfft, fs)

        # For the errors, the 1/nSegments factor should come after welchscale
        # if we don't want to apply sqrt() to it. We correct for that here.
        # It is only needed for 'asd','as' in psd/cpsd, the other cases go
        # always through 'PSD'.
        if scale.lower() == "psd" or scale.lower() == "ps":
            dP = Pvxx
        elif scale.lower() == "asd" or scale.lower() == "as":
            dP = Pvxx / nSegments
        else:
            raise Exception("### Unknown scale " + scale)

    elif ltype == "tfe":
        # Compute the 1-sided or 2-sided PSD [Power/freq] or mean-square [Power].
        # Also, corresponding freq vector and freq units.
        # In the Cross PSD, the frequency vector and xunits are not used.
        Pxx, Pvxx = _scaleToPSD(Sxx, numpy.empty((0, 0)), nfft, fs)
        Pxy, Pvxy = _scaleToPSD(Sxy, numpy.empty((0, 0)), nfft, fs)
        Pyy, Pvyy = _scaleToPSD(Syy, numpy.empty((0, 0)), nfft, fs)
        # mean and std
        P = Pxy / Pxx  # Txy
        if nSegments == 1:
            dP = []
        else:
            dP = (
                (nSegments / (nSegments - 1) ** 2)
                * (Pyy / Pxx)
                * (1 - (abs(Pxy) ** 2) / (Pxx * Pyy))
            )

    elif ltype == "mscohere":
        # Magnitude Square Coherence estimate.
        # Auto PSD for 2nd input vector. The freq vector & xunits are not
        # used.
        Pxx, Pvxx = _scaleToPSD(Sxx, numpy.empty((0, 0)), nfft, fs)
        Pxy, Pvxy = _scaleToPSD(Sxy, numpy.empty((0, 0)), nfft, fs)
        Pyy, Pvyy = _scaleToPSD(Syy, numpy.empty((0, 0)), nfft, fs)
        # mean and std
        P = (abs(Pxy) ** 2) / (Pxx * Pyy)  # Magnitude-squared coherence
        dP = (2 * P / nSegments) * (1 - P) ** 2

    elif ltype == "cohere":
        # Complex Coherence estimate.
        # Auto PSD for 2nd input vector. The freq vector & xunits are not
        # used.
        Pxx, Pvxx = _scaleToPSD(Sxx, numpy.empty((0, 0)), nfft, fs)
        Pxy, Pvxy = _scaleToPSD(Sxy, numpy.empty((0, 0)), nfft, fs)
        Pyy, Pvyy = _scaleToPSD(Syy, numpy.empty((0, 0)), nfft, fs)
        P = Pxy / numpy.sqrt(Pxx * Pyy)  # Complex coherence
        dP = (2 * abs(P) / nSegments) * (1 - abs(P)) ** 2
    else:
        raise Exception("Unknown estimator option " + ltype)

    # Compute frequencies
    freqs = scipy.fft.rfftfreq(n=nfft, d=1.0 / fs)

    # Scale to required units
    Pxx, dP, info = _welchscale(P, dP, winVals, fs, scale, inunits)
    if nSegments == 1:
        dev = numpy.array([0])
    else:
        dev = numpy.sqrt(dP)

    # Set outputs
    return Pxx, freqs, info, dev


# Scaled periodogram of one or two input signals
def _wosa_periodogram(x, y, win, nfft):
    # window data
    xwin = x * win

    # take fft
    X = scipy.fft.fft(xwin, nfft)

    # Compute scale factor to compensate for the window power
    K = numpy.inner(win, win)
    # Compute scaled power
    Sxx = X * numpy.conj(X) / K

    if isinstance(y, numpy.ndarray):
        ywin = y * win
        Y = scipy.fft.fft(ywin, nfft)
        Sxx = X * numpy.conj(Y) / K

    return Sxx


def _tfePeriodogram(x, y, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder):
    nfft = segmentEnds[0]
    Sxx = numpy.zeros(nfft)  # Initialize Sxx
    Sxy = numpy.zeros(nfft)  # Initialize Sxy
    Syy = numpy.zeros(nfft)  # Initialize Syy

    # loop over segments
    for ii in range(nSegments):
        if detrendOrder < 0:
            xseg = x.yaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1]
            yseg = y.yaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1]
        else:
            xseg = XYData._polydetrend(
                x.xaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1],
                x.yaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1],
                detrendOrder,
            )
            yseg = XYData._polydetrend(
                y.xaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1],
                y.yaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1],
                detrendOrder,
            )

        # Compute periodograms
        Sxxk = _wosa_periodogram(xseg, [], winVals, nfft)
        Sxyk = _wosa_periodogram(yseg, xseg, winVals, nfft)
        Syyk = _wosa_periodogram(yseg, [], winVals, nfft)

        Sxx = Sxx + Sxxk
        Sxy = Sxy + Sxyk
        Syy = Syy + Syyk

    # don't need to be divided by k because only ratios are used here
    return Sxx, Sxy, Syy


def _psdPeriodogram(x, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder):
    Mnxx = 0
    Mn2xx = 0
    nfft = segmentEnds[0] - segmentStarts[0] + 1

    # Loop over the segments
    for ii in range(nSegments):
        # Detrend if desired
        if detrendOrder < 0:
            seg = x.yaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1]
        else:
            seg = XYData._polydetrend(
                x.xaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1],
                x.yaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1],
                detrendOrder,
            )

        # Compute periodogram
        Sxxk = _wosa_periodogram(seg, [], winVals, nfft)
        Sxxk = numpy.abs(Sxxk)  # ensure we have only vector length
        # Welford's algorithm for updating mean and variance
        if ii == 0:
            Mnxx = Sxxk
        else:
            Qxx = Sxxk - Mnxx
            Mnxx = Mnxx + Qxx / (ii + 1)
            Mn2xx = Mn2xx + Qxx * (Sxxk - Mnxx)

    Sxx = Mnxx

    if nSegments == 1:
        Svxx = numpy.empty((0, 0))
    else:
        Svxx = Mn2xx / (nSegments - 1) / nSegments

    return Sxx, Svxx


def _cpsdPeriodogram(
    x, y, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder
):
    variance_RI = True

    Mnxx = 0
    Mn2xx = 0
    Mnxx_R = 0
    Mnxx_I = 0
    Mn2xx_R = 0
    Mn2xx_I = 0

    nfft = segmentEnds[0]
    for ii in range(nSegments):
        if detrendOrder < 0:
            xseg = x.yaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1]
            yseg = y.yaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1]
        else:
            xseg = XYData._polydetrend(
                x.xaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1],
                x.yaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1],
                detrendOrder,
            )
            yseg = XYData._polydetrend(
                y.xaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1],
                y.yaxis.data[segmentStarts[ii] : segmentEnds[ii] + 1],
                detrendOrder,
            )

        # Compute periodogram
        Sxxk = _wosa_periodogram(xseg, yseg, winVals, nfft)
        Sxxk_R = numpy.real(Sxxk)
        Sxxk_I = numpy.imag(Sxxk)

        # Welford's algorithm to update mean
        Qxx = Sxxk - Mnxx
        Mnxx = Mnxx + Qxx / (ii + 1)

        # Welford's algorithm to update variance
        Mn2xx = Mn2xx + abs(Qxx * numpy.conj(Sxxk - Mnxx))

        # Welford's algorithm to update variance of real part
        Qxx_R = Sxxk_R - Mnxx_R
        Mnxx_R = Mnxx_R + Qxx_R / (ii + 1)
        Mn2xx_R = Mn2xx_R + Qxx_R * (Sxxk_R - Mnxx_R)

        # Welford's algorithm to update variance of imaginary part
        Qxx_I = Sxxk_I - Mnxx_I
        Mnxx_I = Mnxx_I + Qxx_I / (ii + 1)
        Mn2xx_I = Mn2xx_I + Qxx_I * (Sxxk_I - Mnxx_I)

    Sxx = Mnxx

    if nSegments == 1:
        Svxx = []
    else:
        if variance_RI:
            Svxx = (Mn2xx_R + 1j * Mn2xx_I) / (nSegments - 1) / nSegments
        else:
            Svxx = Mn2xx / (nSegments - 1) / nSegments

    return Sxx, Svxx
