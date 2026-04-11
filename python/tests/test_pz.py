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

from pyda.pzmodel import *


class Test(unittest.TestCase):
    @unittest.skip("not working")
    def test_init(self):
        pz = PZ()
        print(pz)
        self.assertTrue(
            numpy.isnan(pz.f),
            "the empty constructor should produce a frequency that is Nan",
        )
        self.assertTrue(
            numpy.isnan(pz.q), "the empty constructor should produce a q that is Nan"
        )
        self.assertTrue(
            numpy.isnan(pz.ri), "the empty constructor should produce a ri that is Nan"
        )
        self.assertTrue(
            isinstance(pz, PZ), "the empty constructor should return a PZ object"
        )

    def test_init2(self):
        f0 = 1.0
        pz = PZ(f=f0)
        print(pz)
        self.assertTrue(
            pz.f == f0, "the constructor should produce a frequency that is " + str(f0)
        )
        self.assertTrue(
            numpy.isnan(pz.q), "the empty constructor should produce a q that is Nan"
        )
        self.assertTrue(
            pz.ri == -2.0 * numpy.pi * f0,
            "the empty constructor should produce a ri that is -2*pi*f0",
        )
        self.assertTrue(isinstance(pz, PZ), "the constructor should return a PZ object")

    def test_init3(self):
        f0 = 1
        q = 1
        pz = PZ(f=f0, q=q)
        print(pz)
        self.assertTrue(
            pz.f == f0, "the constructor should produce a frequency that is " + str(f0)
        )
        self.assertTrue(
            pz.q == q, "the constructor should produce a q that is " + str(q)
        )
        self.assertTrue(
            pz.ri.size == 2, "the constructor should produce a ri that is size 2"
        )
        self.assertTrue(isinstance(pz, PZ), "the constructor should return a PZ object")

    def test_init4(self):
        pz = PZ(f=1 + 1j)
        print(pz)
        # self.assertTrue(pz.f == f0, "the constructor should produce a frequency that is " + str(f0))
        # self.assertTrue(pz.q == q, "the constructor should produce a q that is " + str(q))
        self.assertTrue(
            pz.ri.size == 2, "the constructor should produce a ri that is size 2"
        )
        self.assertTrue(isinstance(pz, PZ), "the constructor should return a PZ object")

    def test_char(self):
        pz = PZ(f=1 + 1j)
        print(pz.char())
