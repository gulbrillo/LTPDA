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

from fractions import Fraction
import numpy


def rat(value):
    frac = Fraction.from_float(value).limit_denominator(10000000)
    return frac.numerator, frac.denominator


def normal_round(number):
    """Round a float to the nearest integer."""
    return int(number + 0.5)


def intfact(v1, v2):

    # Get input sample rates
    fs2 = int(numpy.floor(1e10 * v1))
    fs1 = int(numpy.floor(1e10 * v2))

    g = numpy.gcd(fs2, fs1)

    o1 = fs2 / g
    o2 = fs1 / g

    return o1, o2
