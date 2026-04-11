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

from pyda.utils.axis import Axis
import numpy
from pyda.exceptions.sizeexceptions import DataSizeException
from pyda.utils.unit import Unit
from pyda.exceptions.typeexceptions import WrongDataTypeException


class Test(unittest.TestCase):
    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_empty_constructor(self):
        obj = Axis()
        s = obj.data.shape
        self.assertIsNotNone(obj, "the empty constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, Axis), "the empty constructor should return an Axis object"
        )
        self.assertTrue(s == (0, 0), "The data should be empty, not " + str(s))

    def test_data_constructor(self):
        obj = Axis(numpy.random.randn(1, 100))
        s = obj.data.shape
        self.assertIsNotNone(obj, "the data constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, Axis), "the data constructor should return an Axis object"
        )
        self.assertTrue(s == (1, 100), "The data should not be empty, it is " + str(s))

    def test_data_ddata_constructor(self):
        nData = 10000
        x = numpy.random.randn(1, nData)
        dx = numpy.random.randn(1, nData)
        obj = Axis(x, dx)
        s = obj.data.shape
        ds = obj.ddata.shape
        self.assertIsNotNone(obj, "the data constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, Axis), "the data constructor should return an Axis object"
        )
        self.assertTrue(
            s == (1, nData), "The data should not be empty, it is " + str(s)
        )
        self.assertTrue(
            ds == (1, nData), "The error data should not be empty, it is " + str(s)
        )

    def test_wrong_ddata_constructor(self):
        x = numpy.random.randn(1, 100)
        dx = numpy.random.randn(1, 10)
        with self.assertRaises(DataSizeException):
            obj = Axis(x, dx)

    def test_data_ddata_units_constructor(self):
        x = numpy.random.randn(1, 100)
        dx = numpy.random.randn(1, 100)
        u = Unit("m")
        obj = Axis(x, dx, u)
        self.assertIsNotNone(obj, "the constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, Axis), "the data constructor should return an Axis object"
        )
        self.assertTrue(
            isinstance(obj.units, Unit),
            "The object should have a Unit object, it is " + str(obj.units),
        )
        self.assertTrue(
            obj.units.char() == "[m]",
            "The object should have a unit string '[m]', it is " + obj.units.char(),
        )

    def test_data_ddata_units_string_constructor(self):
        x = numpy.random.randn(1, 100)
        dx = numpy.random.randn(1, 100)
        obj = Axis(x, dx, "m")
        self.assertIsNotNone(obj, "the constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, Axis), "the data constructor should return an Axis object"
        )
        self.assertTrue(
            isinstance(obj.units, Unit),
            "The object should have a Unit object, it is " + str(obj.units),
        )
        self.assertTrue(
            obj.units.char() == "[m]",
            "The object should have a unit string '[m]', it is " + obj.units.char(),
        )

    def test_data_ddata_units_wrong_constructor(self):
        x = numpy.random.randn(1, 100)
        dx = numpy.random.randn(1, 100)
        with self.assertRaises(WrongDataTypeException):
            obj = Axis(x, dx, 123)

    def test_data_ddata_units_name_constructor(self):
        x = numpy.random.randn(1, 100)
        dx = numpy.random.randn(1, 100)
        u = Unit("m")
        n = "my name"
        obj = Axis(x, dx, u, n)
        self.assertIsNotNone(obj, "the constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, Axis), "the data constructor should return an Axis object"
        )
        self.assertTrue(
            isinstance(obj.name, type("")),
            "The object should have a Unit object, it is " + str(obj.units),
        )
        self.assertTrue(
            obj.name == n,
            "The object should have a name '" + n + "', it is " + obj.name,
        )

    def test_data_ddata_units_wrong_name_constructor(self):
        x = numpy.random.randn(1, 10)
        dx = numpy.random.randn(1, 10)
        u = Unit("m")
        with self.assertRaises(WrongDataTypeException):
            obj = Axis(data=x, ddata=dx, units=u, name=123)

    def test_axis_mean(self):
        x = numpy.array([1, 2, 3])
        a = Axis(data=x)
        mu_a = a.mean()
        self.assertTrue(
            a.data.size == 3,
            "The original data should remain unaffected by computing the mean",
        )
        self.assertTrue(
            numpy.mean(a.data) == mu_a.data,
            "The object data should be the mean of the input data",
        )
