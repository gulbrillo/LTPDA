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

import unittest

import pyda.dsp.spectral

from pyda.tsdata import TSData
from pyda.fsdata import FSData

import numpy


class Test(unittest.TestCase):

    # Test objects

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_tsdata_psd_error(self):
        self.assertRaisesRegex(Exception, ".*", pyda.dsp.spectral.psd, ts=None)

    def test_tsdata_psd(self):
        ts = TSData(
            yaxis=numpy.random.randn(
                10000,
            ),
            fs=10,
            yname="Rand",
            yunits="m",
        )

        Sxx = pyda.dsp.spectral.psd(ts)
        print(Sxx)
        self.assertIsNotNone(Sxx, "the psd method didn't return an object")
        self.assertTrue(
            isinstance(Sxx, FSData), "the psd method should return an FSData object"
        )
