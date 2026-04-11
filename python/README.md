# pyda

Python package for LTPDA-style signal processing and LTI system analysis. Fork of
[pyda-group/pyda](https://gitlab.com/pyda-group/pyda), extended for integration with the
LTPDA repository stack.

---

## Overview

pyda provides Python equivalents of the core LTPDA MATLAB toolbox objects: time-series and
frequency-series data classes, spectral estimation, pole/zero models, digital filters, and a
physical unit algebra. The "it just works" principle of the original MATLAB toolbox is preserved —
common analysis tasks require very few lines of code, while the underlying data structures remain
fully accessible for advanced use.

The package is in active development. Core signal processing is stable; IIR filter design and
some higher-level LTPDA concepts are not yet implemented.

---

## Requirements

- Python 3.7.1 or later (tested up to 3.13)
- numpy ≥ 1.18, scipy ≥ 1.5, matplotlib ≥ 3.0, h5py ≥ 3
- lpsd ≥ 1.0.2 (log-scale PSD estimator — see Installation)

---

## Installation

### End users — pip from source

```bash
git clone <this-repo>
cd LTPDA/python
pip install .
```

### Developers — Poetry

```bash
cd LTPDA/python
poetry install
poetry run pre-commit install   # enable Black, isort, mypy, pylint hooks
```

### lpsd

The log-scale PSD estimator (`logpsd`) depends on the `lpsd` package hosted at
`git.physnet.uni-hamburg.de`. Install it separately if your environment does not pull it in
automatically:

```bash
pip install lpsd
```

**Apple Silicon (M1/M2):** `lpsd` contains C code that uses `long double` arithmetic.
On Apple Silicon, `long double` is the same width as `double` (64-bit), which is correct
but the `polyreg` step has been observed to dominate runtime. If `logpsd` is unusably slow,
compile `lpsd` from source with architecture-specific flags:

```bash
# from the lpsd source directory
gcc -arch arm64 -c -fPIC ltpda_dft.c
gcc -arch arm64 -shared -o ltpda_dft.so ltpda_dft.o
```

Check for `long double` uses throughout if contributing performance fixes for M1.

---

## Quick start

```python
from pyda.tsdata import TSData
from pyda.dsp.spectral import psd, asd

# 10000 s of white noise at 10 Hz
ts = TSData.randn(nsecs=10000, fs=10, name='noise', yunits='m')

# Power and amplitude spectral density
Pxx = psd(ts, navs=10, window='BH92')
Sxx = asd(ts, navs=10, window='BH92')
Sxx.loglog()
```

---

## Documentation

### Creating data objects

**`TSData`** — time-series with a sampling rate. The time axis is auto-generated from `fs`.

```python
from pyda.tsdata import TSData

# White noise
ts = TSData.randn(nsecs=1000, fs=100, name='noise', yunits='V')

# Sine wave
s = TSData.sinewave(fs=100, nsecs=10, A0=2.0, f0=1.2, phi=0, name='sine', yunits='V')

# Zeros
z = TSData.zeros(nsecs=100, fs=10, yunits='m')
```

**`XYData`** / **`FSData`** — general 2-D data and frequency-series.

```python
from pyda.xydata import XYData
from pyda.fsdata import FSData
import numpy as np

xy = XYData(xaxis=np.linspace(0, 1, 100), yaxis=np.random.randn(100),
            xname='Time', yname='Signal', xunits='s', yunits='V')

# FSData from a parametric function (e.g. noise model)
fs_noise = FSData.from_function(
    lambda f: 13.5e-12**2 * (1 + (2e-3 / f)**4),
    xmin=1e-4, xmax=1, npts=1000, xunits='Hz', yunits='m^2/Hz',
)
```

**`YData`** — scalar data with units (no x axis).

```python
from pyda.ydata import YData

y = YData(yaxis=3.14, yunits='m')
```

---

### Arithmetic and error propagation

All arithmetic operations are supported between data objects and between objects and
scalars / numpy arrays. Gaussian errors in `ddata` are propagated automatically.

```python
ts  = TSData.randn(nsecs=100, fs=10, yunits='V')
ts2 = TSData.randn(nsecs=100, fs=10, yunits='V')

result = ts + ts2          # addition
ratio  = ts / ts2          # division — units cancel, errors propagate
power  = ts ** 3           # power — errors propagated via chain rule
scaled = ts * 10           # scalar multiply

# Attach per-sample errors and plot with error bars
ts.dyaxis = 0.1            # uniform error (shorthand for ts.yaxis.ddata = 0.1)
ts.plot(ShowErrors=True, ErrorType='area')
```

Units are tracked through every operation:

```python
from pyda.utils.unit import Unit

u = Unit('m^2 Hz^-1')
print(u.char())        # [m^(2)][Hz^(-1)]
print(u.sqrt().char()) # [m][Hz^(-1/2)]
```

---

### Spectral analysis

All estimators accept a `TSData` input and return `FSData`.

```python
from pyda.dsp.spectral import psd, asd, csd, mscohere, cohere, tfe, logpsd

# Welch PSD / ASD
Pxx = psd(ts, navs=10, window='BH92')          # Power spectral density
Sxx = asd(ts, navs=10, window='BH92')          # Amplitude spectral density (= √PSD)

# Scale options: 'PSD' (default), 'ASD', 'PS', 'AS'
Sxx2 = psd(ts, navs=10, window='BH92', scale='ASD')

# Cross-spectral quantities (two inputs)
Pxy  = csd(ts1, ts2, navs=10, window='BH92')   # Cross-spectral density
coh  = mscohere(ts1, ts2, navs=10)             # Magnitude-squared coherence
ccoh = cohere(ts1, ts2, navs=10)               # Complex coherence
H    = tfe(ts1, ts2, navs=10, window='BH92')   # Transfer function estimate

# Log-scale PSD (requires lpsd package)
lPxx = logpsd(ts)
lPxx2 = logpsd(ts, order=3)                    # higher-order debiasing

# Plot with errors
lPxx.sqrt().loglog(lPxx2.sqrt(), ShowErrors=True, ErrorType='area')
```

> **Nfft vs navs:** Pass `Nfft` to set the segment length in samples, or `navs` to
> set the target number of averages. Both control the frequency resolution / variance
> trade-off.

---

### Spectral windows

```python
from pyda.utils.specwin import Specwin

# List all available windows
Specwin.supportedWindows()
# ['Rectangular', 'Welch', 'Bartlett', 'Hanning', 'Hamming',
#  'Nuttall3', 'Nuttall4', 'Nuttall3a', 'Nuttall3b', 'Nuttall4a',
#  'Nuttall4b', 'Nuttall4c', 'BH92', 'SFT3F', 'SFT3M', 'FTNI',
#  'SFT4F', 'SFT5F', 'SFT4M', 'FTHP', 'HFT70', 'FTSRS', 'SFT5M',
#  'HFT90D', 'HFT95', 'HFT116D', 'HFT144D', 'HFT169D', 'HFT196D',
#  'HFT223D', 'HFT248D', 'Kaiser']

# Inspect a window
w = Specwin('BH92', N=1024)
print(w.nenbw)   # Normalised equivalent noise bandwidth
print(w.psll)    # Peak sidelobe level (dB)

# Kaiser window: specify sidelobe level
w_k = Specwin('Kaiser', N=1024, psll=200)
```

Pass the window name as a string to any spectral estimator: `window='BH92'`.

---

### Pole/zero models

```python
from pyda.pzmodel import PZModel, PZ
import numpy as np

# PZ objects: real pole (f only) or complex pair (f + Q)
p1 = PZ(0.01, Q=2)   # complex pair at 0.01 Hz, Q=2
p2 = PZ(3)           # real pole at 3 Hz
z1 = PZ(0.1)         # real zero at 0.1 Hz
z2 = PZ(0.2)         # real zero at 0.2 Hz

pzm = PZModel(poles=[p1, p2], zeros=[z1, z2], gain=2, delay=0,
              iunits='m', ounits='V')
print(pzm)

# Evaluate frequency response → returns FSData
freqs = np.logspace(-3, 1, 500)
r = pzm.resp(freqs=freqs)
r.abs().loglog()
```

---

### Noise generation

Generate a time-series with a spectral shape defined by a `PZModel` using the Franklin
algorithm. The result can be arbitrarily long; state is maintained across calls.

```python
from pyda.dsp.noisegen import NoiseGen
from pyda.dsp.spectral import logpsd

ng = NoiseGen(pzm=pzm, fs=30)
ts = ng.generateNoise(nsecs=1e5)

# Verify: compare generated spectrum against model response
S  = logpsd(ts)
r  = pzm.resp(freqs=S.xaxis.data)
S.sqrt().loglog(r.abs())
```

---

### FIR digital filters

```python
from pyda.dsp.filter import FIR

# Design filters (scipy windowed-sinc method)
lp = FIR.lowpass( fc=1,          gain=1, fs=10, order=32,   win='blackmanharris',
                  iunits='V', ounits='m')
hp = FIR.highpass(fc=1,          gain=1, fs=10, order=32,   win='blackmanharris',
                  iunits='V', ounits='m')
bp = FIR.bandpass(fc=[0.01, 0.1], gain=2, fs=10, order=1024, iunits='V', ounits='m')
bs = FIR.bandstop(fc=[0.01, 0.1], gain=2, fs=10, order=1024, iunits='V', ounits='m')

# Frequency response → FSData
r = lp.resp(f1=0.1, f2=5, nf=1000)
r.loglog()

# Apply to a time-series
ts_filtered = lp.filter(ts)
```

---

### Differentiation

Five numerical differentiation methods are available via `TSData.diff()`.

```python
s = TSData.sinewave(fs=100, nsecs=10, A0=1, f0=1.2, phi=0, yunits='V')

# method: 'diff', '2point', '3point', '5point', 'order2', 'order2Smooth'
# order:  'Zero' (smoothed input), 'First' (first derivative), 'Second'
ds1 = s.diff(method='3point', order='First')
ds2 = s.diff(method='5point', order='Second')

# order2 and order2Smooth do not take an 'order' argument
ds_o2 = s.diff(method='order2Smooth')

s.plot(ds1, ds2)
```

| Method | Notes |
|--------|-------|
| `diff` | Simple numpy finite difference |
| `2point` | Two-point stencil |
| `3point` | Three-point centered stencil |
| `5point` | Five-point centered stencil, higher accuracy |
| `order2` | Polynomial fitting on irregular grids |
| `order2Smooth` | `order2` with 5-point smoothing pass |

---

### Splitting data

```python
# Time-series: split by time window [start, stop] in seconds
segment = ts.split_by_time(times=[10, 60])

# Frequency-series: split by frequency range [f_low, f_high] in Hz
band = Sxx.split_by_frequency(freqs=[0.1, 1.0])
```

> **Known bug (#5):** `split_by_time` currently uses time values as sample indices
> rather than comparing against the actual time axis. Use with care on data that does
> not start at t = 0.

---

### File I/O

Objects are serialised to HDF5 with a versioned format. The file extension is `.pyda`.

```python
# Save
ts.save('my_timeseries.pyda')

# Load
from pyda.tsdata import TSData
ts2 = TSData.load('my_timeseries.pyda')

# Load from text file
ts3 = TSData.from_txt_file('data.txt', fs=100, yunits='V',
                            xcol=0, ycol=1, delimiter=',')
```

---

## Core classes

### Data hierarchy

```
YData                   Y-axis data with units and Gaussian error propagation
  └── XYData            adds an X axis (general 2-D data)
        ├── TSData      time-series — sampling-rate aware; auto-generates time axis
        └── FSData      frequency-series — X units default to Hz
```

### Supporting classes

| Class | Purpose |
|-------|---------|
| `Axis` | Wraps a numpy array with a `Unit`, error array (`ddata`), and a name |
| `Unit` | Symbolic unit algebra — parse, multiply, simplify, convert to SI |
| `Specwin` | 30+ spectral window functions |
| `PZ` | Single pole or zero in f/Q or complex (s-plane) representation |
| `PZModel` | Poles, zeros, gain, and delay — evaluates to `FSData` via `.resp()` |
| `DFilter` / `FIR` | Digital filter classes with `.resp()` and `.filter()` |
| `NoiseGen` | Franklin-algorithm colored-noise generator driven by a `PZModel` |

---

## Features

- **Time and frequency series** — `TSData` and `FSData` with unit tracking, error propagation,
  and HDF5 serialisation (`.pyda` files, versioned format)
- **Physical unit algebra** — parses unit strings (`"m/s^2"`, `"pm^1.5"`, …), multiplies,
  simplifies, converts to SI, and produces LaTeX axis labels
- **Error propagation** — Gaussian errors tracked through every arithmetic operation including
  `+`, `-`, `*`, `/`, `**`, `abs`, `sqrt`, `log10`, `exp`
- **Spectral estimation** — Welch WOSA: `psd`, `asd`, `csd`, `mscohere`, `cohere`, `tfe`;
  log-scale `logpsd` via the external `lpsd` library; PSD / ASD / PS / AS output scaling
- **Spectral windows** — 30+ types; each exposes NENBW, PSLL, and 3 dB bandwidth properties
- **Pole/zero models** — `PZModel` with frequency-response evaluation; automatic f/Q ↔ complex
  root conversion; complex-conjugate pole pairs handled correctly
- **FIR digital filters** — lowpass, highpass, bandpass, bandstop; frequency response and
  time-domain filtering of `TSData`
- **Noise generation** — Franklin algorithm; arbitrary spectral shape prescribed by a `PZModel`;
  state maintained across calls for arbitrarily long sequences
- **Differentiation** — five methods: 2-point, 3-point, 5-point, order-2 polynomial fit,
  and order-2 with 5-point smoothing; orders Zero, First, Second
- **Resampling and fractional delay** — windowed-sinc interpolation with Blackman window
- **Plotting** — `plot`, `loglog`, `semilogy`, `semilogx`; complex data automatically splits
  into magnitude and phase panels; error bars with `ShowErrors=True`, `ErrorType='area'`
- **File I/O** — `save()` / `load()` on all data objects; `from_txt_file()` and
  `from_complex_txt_file()` class-method constructors

### Not yet implemented

- IIR filters (MATLAB `miir`)
- `plist` parameter-list objects (currently plain Python keyword arguments)
- `XYZData` class with spectrogram support
- Additional math operators on `XYData`: `sin`, `cos`, `tan` and friends
- Log-scale spectral estimators: `ltfe`, `lcohere`, and equivalents of the remaining LTPDA lpsd family
- `fpsder` — fractional polynomial derivative (started, not finished)
- Vectorised spectral functions — `psd(*ts_list)` / `asd(*ts_list)` to operate on multiple objects at once
- Axis-level method helper — a generic wrapper to apply arbitrary functions to an `Axis` with correct error propagation
- Time-domain simulation / step response for `PZModel`
- Calibration objects and control-system design utilities
- Docstrings — help text coverage is incomplete throughout the package

---

## Directory layout

```
python/
├── pyda/
│   ├── ydata.py          YData base class
│   ├── xydata.py         XYData (general 2-D data)
│   ├── tsdata.py         TSData (time-series)
│   ├── fsdata.py         FSData (frequency-series)
│   ├── pzmodel.py        PZModel + PZ (pole/zero transfer functions)
│   ├── functions.py      Module-level function wrappers
│   ├── utils/
│   │   ├── axis.py       Axis — numpy array with units and errors
│   │   ├── unit.py       Unit — symbolic algebra and SI conversion
│   │   ├── specwin.py    Spectral windows (30+ types)
│   │   └── math/         Helper math utilities (rat, intfact, normal_round)
│   ├── dsp/
│   │   ├── filter.py     TF, DFilter, FIR digital filter classes
│   │   ├── spectral.py   PSD, ASD, CSD, coherence, TFE estimators
│   │   └── noisegen.py   Franklin noise generator
│   ├── mixins/           Composable mixins (operators, plotting, diff, DSP)
│   └── Examples/         Jupyter notebooks (26 examples)
├── docker/               Dockerfile for CI / containerised testing
└── tests/                pytest test suite (~54% coverage)
```

---

## Development

### Run the tests

```bash
make test
# or
poetry run pytest
```

All tests must pass and coverage must not drop below 54 %.

### Docker

A `docker/Dockerfile` builds a self-contained Python environment with pyda installed (Python 3.10 by default, also tested against 3.7). The Makefile provides helpers:

```bash
make docker         # build gwdiexp/pyda:develop (and :develop-3.10)
make docker-push    # push both tags to Docker Hub
make test-docker    # run the test suite inside the container
```

The Docker image is primarily used for CI. To run tests in the container locally:

```bash
docker run -v $(pwd):/code --rm -it gwdiexp/pyda:develop make test
```

### Code style

Black (88-character lines), isort, pylint, and mypy are enforced via pre-commit. The hooks
run automatically before each commit once enabled:

```bash
poetry run pre-commit install
```

### Release a new version

```bash
poetry version patch   # bug fixes
poetry version minor   # new features
poetry version major   # breaking changes
```

Then merge to `main`.

### Open design questions

These architectural decisions are unresolved and worth settling before the relevant areas grow further:

- **Plotter separation** — plotting methods (`plot`, `loglog`, …) currently live as mixins on
  the data classes. An alternative is a standalone `TSPlotter` / `FSPlotter` class:
  `tsplt.loglog(ts1, ts2, ts3)`. This would decouple visualisation from data and make the
  classes easier to test.

- **Spectral and filter mixins** — `psd`, `asd`, `tfe`, and filter application currently live
  in separate modules. Since they only operate on `TSData`, mixing them directly onto `TSData`
  (like `TSDataDSP`) would give `ts.psd(navs=10)` call syntax. Trade-off: convenience vs
  separation of concerns.

- **Setter validation in `Axis`** — input checking for `data`, `ddata`, and `units` is spread
  across the data classes. Moving it into `Axis.__set__` would centralise validation and make
  subclassing safer.

---

## Known issues

The following open issues are tracked upstream at
[gitlab.com/pyda-group/pyda/-/issues](https://gitlab.com/pyda-group/pyda/-/issues).

**Bugs:**

- **[#6](https://gitlab.com/pyda-group/pyda/-/issues/6) — `ydata / ydata` raises `WrongSizeException`**
  Division between two `XYData` / `YData` objects fails due to a unit exponent list length
  mismatch. Workaround: divide the underlying numpy arrays directly.

- **[#5](https://gitlab.com/pyda-group/pyda/-/issues/5) — `split_by_time` uses indices instead of time values**
  Start/stop times are multiplied by `fs` and used as sample indices rather than compared
  against the actual time axis. Results are incorrect for data that does not start at t = 0.

- **[#23](https://gitlab.com/pyda-group/pyda/-/issues/23) — `numpy.array * YData` calls `YData.__mul__` element-wise**
  When a numpy array is the left operand, Python dispatches multiplication to `YData.__mul__`
  repeatedly rather than treating the array as a single operand. Operator test coverage is
  incomplete.

**Design limitations:**

- **[#11](https://gitlab.com/pyda-group/pyda/-/issues/11) — No vectorised operations on lists of objects**
  There is no array-of-objects type. Calling `.plot()` on a Python list of `TSData` objects
  requires `my_list[0].plot(*my_list[1:])` as a workaround.

**Enhancements under discussion:**

- **[#9](https://gitlab.com/pyda-group/pyda/-/issues/9) — Replace `ddata` with the `uncertainties` library**
  Proposal to use `uncertainties.uarray` instead of separate data/error arrays for more
  transparent error propagation.

- **[#8](https://gitlab.com/pyda-group/pyda/-/issues/8) — Object `__str__` should show data values**
  `print(ts)` currently shows shape only. Request to show first/last values
  following the numpy convention.

- **[#7](https://gitlab.com/pyda-group/pyda/-/issues/7) — Mixed-unit plots should warn**
  Plotting objects with incompatible units silently produces a misleading axis label.
  Request to display `[Mixed]` or raise a warning.

- **[#3](https://gitlab.com/pyda-group/pyda/-/issues/3) — Package name `pyda` is taken on PyPI**
  The name `pyda` is already registered on PyPI by an unrelated project. An alternative
  name must be chosen before the package can be published.

---

## Heritage

pyda was created by Martin Hewitson, Artem Basalaev, Christian Darsow-Fromm, and Oliver
Gerberding as a Python reimplementation of the
[LTPDA MATLAB toolbox](https://www.lisamission.org/ltpda/index.html) for gravitational-wave and
precision-measurement data analysis. The upstream project is maintained at
[gitlab.com/pyda-group/pyda](https://gitlab.com/pyda-group/pyda).

This fork extends the upstream work for integration with the LTPDA repository stack.

Original authors:
- Martin Hewitson — martin.hewitson@aei.mpg.de
- Artem Basalaev — artem.basalaev@physik.uni-hamburg.de
- Christian Darsow-Fromm — cdarsowf@physnet.uni-hamburg.de
- Oliver Gerberding — oliver.gerberding@physik.uni-hamburg.de

---

## License

Licensed under the Apache License, Version 2.0.
Full text: [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)
