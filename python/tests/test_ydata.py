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
import numpy

from pyda.ydata import YData


class YDataTestCase(unittest.TestCase):
    def test_empty_constructor(self):
        obj = YData()
        s = obj.yaxis.data.shape
        self.assertIsNotNone(obj, "the empty constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, YData),
            "the empty constructor should return an YData object",
        )
        self.assertTrue(s == (0, 0), "The data should be empty, not " + str(s))

    def test_data_constructor(self):
        x = numpy.random.randn(1, 100)
        obj = YData(yaxis=x)
        s = obj.yaxis.data.shape
        self.assertIsNotNone(obj, "the data constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, YData), "the data constructor should return an Axis object"
        )
        self.assertTrue(s == (1, 100), "The data should not be empty, it is " + str(s))

    def test_ydata_mean(self):
        y = YData(yaxis=[1, 2, 3])
        mu_y = y.mean()
        self.assertTrue(
            y.yaxis.data.size == 3,
            "The original data should remain unaffected by computing the mean",
        )
        self.assertTrue(
            numpy.mean(y.yaxis.data) == mu_y.yaxis.data,
            "The object data should be the mean of the input data",
        )

    def test_mul(self):
        y = YData(yaxis=3, yunits="m", name="y")
        a = 3.0 * y
        b = y * 3.0
        self.assertTrue(
            isinstance(a, YData), "Result of multiplication should be a ydata object"
        )
        self.assertTrue(
            isinstance(b, YData), "Result of multiplication should be a ydata object"
        )
        self.assertTrue(
            a.yaxis.units.char() == "[m]",
            "The units of the original data should be preserved",
        )
        self.assertTrue(
            b.yaxis.units.char() == "[m]",
            "The units of the original data should be preserved",
        )
        self.assertTrue(
            y.name == "y", "The name of the original data should be preserved"
        )
        self.assertTrue(
            a.name == "(3.0*y)",
            "The name of the original data should include the value",
        )
        self.assertTrue(
            b.name == "(y*3.0)",
            "The name of the original data should include the value",
        )
        self.assertTrue(a.yaxis.data == 9.0, "The new data should have value 9")
        self.assertTrue(b.yaxis.data == 9.0, "The new data should have value 9")

    def test_mul2(self):
        x = YData(yaxis=2, yunits="m", name="x")
        y = YData(yaxis=3, yunits="m", name="y")
        a = x * y
        b = y * x
        self.assertTrue(
            isinstance(a, YData), "Result of multiplication should be a ydata object"
        )
        self.assertTrue(
            isinstance(b, YData), "Result of multiplication should be a ydata object"
        )
        self.assertTrue(
            a.yaxis.units.char() == "[m^(2)]",
            "The units of the original data should be preserved",
        )
        self.assertTrue(
            b.yaxis.units.char() == "[m^(2)]",
            "The units of the original data should be preserved",
        )
        self.assertTrue(
            y.name == "y", "The name of the original data should be preserved"
        )
        self.assertTrue(
            a.name == "(x*y)", "The name of the original data should include the value"
        )
        self.assertTrue(
            b.name == "(y*x)", "The name of the original data should include the value"
        )
        self.assertTrue(a.yaxis.data == 6.0, "The new data should have value 9")
        self.assertTrue(b.yaxis.data == 6.0, "The new data should have value 9")

    @unittest.skip(
        "This does not work because the error propagation produces a vector of length 2 for the y*x case. "
        "Probably we need to reconsider the default error being 0 (length 1). But there were issues with "
        "the shape of numpy arrays when empty."
    )
    def test_mul3(self):
        x = YData(yaxis=[1, 2], yunits="m", name="x")
        y = YData(yaxis=3, yunits="m", name="y")
        a = x * y
        b = y * x
        self.assertTrue(
            isinstance(a, YData), "Result of multiplication should be a ydata object"
        )
        self.assertTrue(
            isinstance(b, YData), "Result of multiplication should be a ydata object"
        )
        self.assertTrue(
            a.yaxis.data.size == 2, "Result of multiplication should be a ydata object"
        )
        self.assertTrue(
            b.yaxis.data.size == 2, "Result of multiplication should be a ydata object"
        )
        self.assertTrue(
            a.yaxis.units.char() == "[m^(2)]",
            "The units of the original data should be preserved",
        )
        self.assertTrue(
            b.yaxis.units.char() == "[m^(2)]",
            "The units of the original data should be preserved",
        )
        self.assertTrue(
            y.name == "y", "The name of the original data should be preserved"
        )
        self.assertTrue(
            a.name == "(x*y)", "The name of the original data should include the value"
        )
        self.assertTrue(
            b.name == "(y*x)", "The name of the original data should include the value"
        )
        self.assertTrue(
            all(a.yaxis.data == b.yaxis.data), "The new data should have value 9"
        )

    def test_pow(self):
        x = YData(yaxis=2, yunits="m", name="x")
        y = YData(yaxis=3, yunits="m", name="y")
        a = x**y

        print(a.ydata())

    def test_rdivide_number_obj(self):
        f = YData(yaxis=numpy.logspace(-4, 0, 10), yunits="Hz", name="f")
        print(f)
        a = 1e-3 / f
        print(a)
        print(a.ydata())

    def test_rdivide_number_obj2(self):
        y = YData(yaxis=[2, 3], yunits="m")
        a = 1e-3 / y
        print(a)
        print(a.ydata())

        # b = y + x
        # print(b)

    def test_numpy_obj(self):
        x = numpy.array([1, 2, 3])
        print(x)
        # print(x+1)

        y = YData(yaxis=[1, 3], yunits="m", name="y")
        a = x + y
        print(a)
        print(type(a))

        # b = y + x
        # print(b)

    def test_radd_float_ydata(self):
        y = YData(yaxis=2, yunits="m")

        b = 1.0 + y
        print(b)

    def test_rsub_float_ydata(self):
        y = YData(yaxis=2, yunits="m")

        b = 1.0 - y
        print(b)
        print(b.ydata())
