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

from pyda.xydata import XYData


class XYDataTestCase(unittest.TestCase):
    def test_empty_constructor(self):
        obj = XYData()
        s = obj.yaxis.data.shape
        self.assertIsNotNone(obj, "the empty constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, XYData),
            "the empty constructor should return an XYData object",
        )
        self.assertTrue(s == (0, 0), "The data should be empty, not " + str(s))

    def test_data_constructor(self):
        x = numpy.arange(1, 101)
        y = numpy.random.randn(1, 100)
        obj = XYData(xaxis=x, yaxis=y)
        sx = obj.xaxis.data.size
        sy = obj.yaxis.data.size
        self.assertIsNotNone(obj, "the data constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, XYData), "the data constructor should return an Axis object"
        )
        self.assertTrue(
            sy == 100, "The yaxis data should not be empty, it is " + str(sy)
        )
        self.assertTrue(
            sx == 100, "The xaxis data should not be empty, it is " + str(sx)
        )

    def test_ydata_mean(self):
        y = XYData(xaxis=[1, 2, 3], yaxis=[1, 2, 3])
        mu_y = y.mean()
        self.assertTrue(
            y.yaxis.data.size == 3,
            "The original data should remain unaffected by computing the mean",
        )
        self.assertTrue(
            numpy.mean(y.yaxis.data) == mu_y.yaxis.data,
            "The object yaxis data should be the mean of the input data",
        )
        self.assertTrue(
            numpy.mean(y.xaxis.data) == mu_y.xaxis.data,
            "The object xaxis data should be the mean of the input data",
        )
