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
    def test_init(self):
        pzm = PZModel()
        print(pzm)
        self.assertTrue(
            len(pzm.poles) == 0,
            "the empty constructor should produce a model with no poles",
        )
        self.assertTrue(
            len(pzm.zeros) == 0,
            "the empty constructor should produce a model with no zeros",
        )
        self.assertTrue(
            isinstance(pzm, PZModel),
            "the empty constructor should return a PZModel object",
        )

    def test_init2(self):

        poles = PZ(1)
        zeros = PZ(2)

        pzm = PZModel(poles=poles, zeros=zeros, gain=2, delay=0.2)
        print(pzm)
        self.assertTrue(
            len(pzm.poles) == 1, "the constructor should produce a model with one pole"
        )
        self.assertTrue(
            len(pzm.zeros) == 1, "the constructor should produce a model with one zero"
        )

    def test_init3(self):

        poles = PZ(f=1, q=2)
        zeros = PZ(2)

        pzm = PZModel(poles=poles, zeros=zeros, gain=2, delay=0.2)
        print(pzm)
        self.assertTrue(
            len(pzm.poles) == 1 and all(numpy.iscomplex(pzm.poles[0].ri)),
            "the constructor should produce a model with one complex pole",
        )
        self.assertTrue(
            len(pzm.zeros) == 1, "the constructor should produce a model with one zero"
        )

    def test_init4(self):

        poles = [PZ(1), PZ(2)]
        zeros = PZ(10)
        gain = 2.2
        pzm = PZModel(poles=poles, zeros=zeros, gain=gain, delay=0.2)
        print(pzm)
        self.assertTrue(
            pzm.gain == gain,
            "the constructor should produce a model with gain of " + str(gain),
        )
        self.assertTrue(
            len(pzm.poles) == 2, "the constructor should produce a model with one pole"
        )
        self.assertTrue(
            len(pzm.zeros) == 1, "the constructor should produce a model with one zero"
        )

    def test_init5(self):

        poles = [PZ(1), PZ(2)]
        zeros = [PZ(10)]
        delay = 1.2
        pzm = PZModel(poles=poles, zeros=zeros, gain=2, delay=delay)
        print(pzm)
        self.assertTrue(
            pzm.delay == delay,
            "the constructor should produce a model with delay of " + str(delay),
        )
        self.assertTrue(
            len(pzm.poles) == 2, "the constructor should produce a model with one pole"
        )
        self.assertTrue(
            len(pzm.zeros) == 1, "the constructor should produce a model with one zero"
        )

    def test_init6(self):

        poles = [1, 2]
        zeros = PZ(10)
        pzm = PZModel(poles=poles, zeros=zeros, gain=2, delay=0.2)
        print(pzm)
        self.assertTrue(
            len(pzm.poles) == 2, "the constructor should produce a model with one pole"
        )
        self.assertTrue(
            len(pzm.zeros) == 1, "the constructor should produce a model with one zero"
        )

    def test_init7(self):

        poles = [PZ(f=1, q=2), 2]
        zeros = PZ(10)
        pzm = PZModel(poles=poles, zeros=zeros, gain=2, delay=0.2)
        print(pzm)
        self.assertTrue(
            all(numpy.iscomplex(pzm.poles[0].ri)),
            "the constructor should produce a model with one complex pole",
        )
        self.assertTrue(
            len(pzm.poles) == 2, "the constructor should produce a model with one pole"
        )
        self.assertTrue(
            len(pzm.zeros) == 1, "the constructor should produce a model with one zero"
        )

    def test_resp(self):

        poles = [PZ(f=1, q=2), 2]
        zeros = PZ(10)
        pzm = PZModel(poles=poles, zeros=zeros, gain=2, delay=0.2)
        r = pzm.resp(freqs=numpy.logspace(start=0, stop=1, num=100))
        print(r)
        self.assertTrue(
            isinstance(r, FSData), "the resp method should produce an FSData"
        )
