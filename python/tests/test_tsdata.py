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

#  Martin Hewitson, 2021
#
#

import unittest

from pyda.tsdata import TSData
from pyda.utils.axis import Axis

import numpy
from pyda.exceptions.sizeexceptions import DataSizeException
from pyda.utils.unit import Unit
from pyda.exceptions.typeexceptions import WrongDataTypeException


class Test(unittest.TestCase):

    # Test objects
    testObj = TSData(
        xaxis=numpy.arange(0, 10, 0.1),
        yaxis=numpy.random.randn(
            100,
        ),
        fs=10,
        yname="Rand",
    )
    testFilename = "test_tsdata.txt"

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_empty_constructor(self):
        obj = TSData()
        xs = obj.xaxis.data.shape
        ys = obj.yaxis.data.shape

        self.assertIsNotNone(obj, "the empty constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, TSData),
            "the empty constructor should return a TSData object",
        )
        self.assertTrue(xs == (0, 0), "The data should be empty, not " + str(xs))
        self.assertTrue(ys == (0, 0), "The data should be empty, not " + str(ys))

    def test_uuid(self):
        o1 = TSData()
        o2 = TSData()
        # print(o1)
        # print(o2)
        self.assertIsNotNone(o1.id, "UUID should not be empty")
        self.assertNotEqual(o1.id, o2.id, "Objects should have different UUIDs")

    def test_axis_names(self):
        xname = "X"
        yname = "Y"
        obj = TSData(xname=xname, yname=yname)
        # print(obj)

        self.assertEqual(obj.xaxis.name, xname, "X-axis name not set right")
        self.assertEqual(obj.yaxis.name, yname, "Y-axis name not set right")

    def test_xaxis_constructor(self):
        obj = TSData(
            xaxis=numpy.random.randn(
                100,
            ),
            xname="Rand",
        )
        print(obj)
        sx = obj.xaxis.data.shape
        sy = obj.yaxis.data.shape
        # print(obj.xaxis)
        # print(obj.yaxis)
        self.assertIsNotNone(obj, "the data constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, TSData),
            "the data constructor should return a TSData object",
        )
        self.assertTrue(sx == (100,), "The data should not be empty, it is " + str(sx))
        self.assertTrue(sx == sy, "The x and y axes should have the same size.")

    # THIS NEEDS WORK
    @unittest.skip("not working :(")
    def test_empty_xaxis(self):
        obj = TSData(xaxis=Axis(), xname="Rand")
        print(obj)
        sx = obj.xaxis.data.shape
        sy = obj.yaxis.data.shape
        # print(obj.xaxis)
        # print(obj.yaxis)
        self.assertIsNotNone(obj, "the data constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, TSData),
            "the data constructor should return a TSData object",
        )
        self.assertTrue(sx == (0, 0), "The data should be empty, it is " + str(sx))
        self.assertTrue(sx == sy, "The x and y axes should have the same size.")

    def test_yaxis_constructor_fs_error(self):
        self.assertRaisesRegex(
            Exception, ".*", TSData, yaxis=numpy.random.randn(1, 100)
        )

    def test_yaxis_constructor(self):
        obj = TSData(
            yaxis=numpy.random.randn(
                100,
            ),
            fs=10,
            yname="Rand",
        )
        print(obj)
        sx = obj.xaxis.data.shape
        sy = obj.yaxis.data.shape
        # print(obj.xaxis)
        # print(obj.yaxis)
        dx = obj.xaxis.data.data[1] - obj.xaxis.data.data[0]
        self.assertEqual(dx, 0.1, "Sample rate should be 10 Hz, not" + str(dx))
        self.assertIsNotNone(obj, "the data constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, TSData),
            "the data constructor should return a TSData object",
        )
        self.assertTrue(sy == (100,), "The data should not be empty, it is " + str(sy))
        self.assertTrue(sx == sy, "The x and y axes should have the same size.")

    def test_xyaxis_constructor(self):
        obj = TSData(
            xaxis=numpy.arange(0, 10, 0.1),
            yaxis=numpy.random.randn(
                100,
            ),
            fs=10,
            yname="Rand",
        )
        print(obj)
        sx = obj.xaxis.data.shape
        sy = obj.yaxis.data.shape
        self.assertTrue(sy == (100,), "The data should not be empty, it is " + str(sy))
        self.assertTrue(sx == sy, "The x and y axes should have the same size.")

    def test_tsdata_export(self):
        self.__class__.testObj.export(self.__class__.testFilename)

    def test_tsdata_from_txt_file(self):
        obj = TSData.from_txt_file(filename=self.__class__.testFilename)
        print(obj)
        print(obj.ydata()[0])
        print(self.__class__.testObj.ydata()[0])
        self.assertTrue(
            all(self.__class__.testObj.xdata() == obj.xdata()),
            "x-axis data should be equal to test file",
        )
        self.assertTrue(
            all(self.__class__.testObj.ydata() == obj.ydata()),
            "y-axis data should be equal to test file",
        )
        self.assertIsNotNone(obj, "the data constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, TSData),
            "the data constructor should return a TSData object",
        )

    def test_tsdata_yunits(self):
        obj = TSData(
            yaxis=numpy.random.randn(
                100,
            ),
            fs=10,
            yname="Rand",
            yunits="m",
        )
        print(obj)
        sx = obj.xaxis.data.shape
        sy = obj.yaxis.data.shape
        xu = obj.xunits().char()
        yu = obj.yunits().char()
        self.assertEqual(xu, "[s]", "x-axis units should be [s], not" + xu)
        self.assertEqual(yu, "[m]", "y-axis units should be [m], not" + yu)
        self.assertIsNotNone(obj, "the data constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, TSData),
            "the data constructor should return a TSData object",
        )

    def test_randn(self):
        nsecs = 1000
        fs = 3
        ts = TSData.randn(nsecs=nsecs, fs=fs, name="MyData", yunits="m")
        N = ts.yaxis.data.size
        self.assertTrue(
            isinstance(ts, TSData), "the data constructor should return a TSData object"
        )
        self.assertTrue(
            N == nsecs * fs, "the timeseries should be 1000 samples, not " + str(N)
        )

    def test_add_unit_error(self):
        nsecs = 10
        fs = 1
        t1 = TSData.randn(nsecs=nsecs, fs=fs, name="MyData", yunits="m")
        t2 = TSData.ones(nsecs=nsecs, fs=fs, name="MyOnes", yunits="s")
        print(t2)
        self.assertRaisesRegex(Exception, ".*", TSData.__add__, t1, t2)

    def test_add_size_error(self):
        nsecs = 10
        fs = 1
        t1 = TSData.randn(nsecs=nsecs, fs=fs, name="MyData", yunits="m")
        t2 = TSData.ones(nsecs=nsecs, fs=3, name="MyOnes", yunits="m")
        self.assertRaisesRegex(Exception, ".*", TSData.__add__, t1, t2)

    def test_add_number(self):
        nsecs = 10
        fs = 1
        ts = TSData.randn(nsecs=nsecs, fs=fs, name="MyData", yunits="m")
        t2 = ts + 10
        d1 = ts.ydata()
        d2 = t2.ydata()
        dx = d2 - d1
        res = dx == 10
        self.assertTrue(all(res), "All samples should be +10")
        self.assertTrue(
            t2.yaxis.units == ts.yaxis.units, "The original units should be preserved"
        )

    def test_radd_number(self):
        nsecs = 10
        fs = 1
        ts = TSData.randn(nsecs=nsecs, fs=fs, name="MyData", yunits="m")
        t2 = 10 + ts
        print(t2)
        d1 = ts.ydata()
        d2 = t2.ydata()
        dx = d2 - d1
        res = dx == 10
        self.assertTrue(all(res), "All samples should be +10")
        self.assertTrue(
            t2.yaxis.units == ts.yaxis.units, "The original units should be preserved"
        )

    def test_sub_number(self):
        nsecs = 10
        fs = 1
        ts = TSData.randn(nsecs=nsecs, fs=fs, name="MyData", yunits="m")
        t2 = ts - 10
        d1 = ts.ydata()
        d2 = t2.ydata()
        dx = d2 - d1
        res = dx == -10
        self.assertTrue(all(res), "All samples should be -10")
        self.assertTrue(
            t2.yaxis.units == ts.yaxis.units, "The original units should be preserved"
        )

    def test_rsub_number(self):
        nsecs = 10
        fs = 1
        ts = TSData.randn(nsecs=nsecs, fs=fs, name="MyData", yunits="m")
        t2 = 10 - ts
        d1 = ts.ydata()
        d2 = t2.ydata()
        dx = d2 + d1
        print(dx)
        res = dx == 10
        self.assertTrue(all(res), "All samples should be +10")
        self.assertTrue(
            t2.yaxis.units == ts.yaxis.units, "The original units should be preserved"
        )

    def test_add_two_TSData(self):
        nsecs = 10
        fs = 1
        t1 = TSData.ones(nsecs=nsecs, fs=fs, name="MyOnes", yunits="m")
        t2 = TSData.ones(nsecs=nsecs, fs=fs, name="MyOnes", yunits="m")
        t3 = t1 + t2
        self.assertTrue(all(t3.yaxis.data == 2), "All samples should be +2")

    def test_mul_number(self):
        nsecs = 10
        fs = 1
        t1 = TSData.ones(nsecs=nsecs, fs=fs, name="MyOnes", yunits="m")
        t2 = t1 * 2
        self.assertTrue(all(t2.yaxis.data == 2), "All samples should be +2")

    def test_mul_number2(self):
        nsecs = 10
        fs = 1
        t1 = TSData.ones(nsecs=nsecs, fs=fs, name="MyOnes", yunits="m")
        t2 = 2.0 * t1
        self.assertTrue(all(t2.yaxis.data == 2), "All samples should be +2")

    def test_mul_size_error(self):
        nsecs = 10
        fs = 1
        t1 = TSData.randn(nsecs=nsecs, fs=fs, name="MyData", yunits="m")
        t2 = TSData.ones(nsecs=nsecs, fs=3, name="MyOnes", yunits="m")
        self.assertRaisesRegex(Exception, ".*", TSData.__mul__, t1, t2)

    def test_mul_two_TSData(self):
        nsecs = 10
        fs = 1
        t1 = TSData.ones(nsecs=nsecs, fs=fs, name="MyOnes", yunits="m") * 2
        t2 = TSData.ones(nsecs=nsecs, fs=fs, name="MyOnes", yunits="m") * 2
        t3 = t1 * t2
        self.assertTrue(all(t3.yaxis.data == 4), "All samples should be +4")
