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
from pyda.xydata import XYData


class YDataOperatorsTestCase(unittest.TestCase):
    """Test case for YData comparison operators."""

    def setUp(self):
        """Set up test fixtures."""
        # Create scalar YData objects
        self.y1 = YData(yaxis=3, yunits="m", name="y1")
        self.y2 = YData(yaxis=3, yunits="m", name="y2")  # Equal to y1
        self.y3 = YData(yaxis=4, yunits="m", name="y3")  # Greater than y1

        # Create array YData objects
        self.y4 = YData(yaxis=[1, -5], yunits="m", name="y4")
        self.y5 = YData(yaxis=[5, 6], yunits="m", name="y5")  # Greater than y4

        # Create YData with different units
        self.y6 = YData(yaxis=3, yunits="s", name="y6")

    def test_gt_scalar_scalar_equal(self):
        """Test greater than operator with equal scalar values."""
        result = self.y1 > self.y2
        self.assertEqual(result.ydata().size, 0, "Result should be empty for equal values")

    def test_gt_scalar_scalar_different(self):
        """Test greater than operator with different scalar values."""
        # y1 > y3 (3 > 4) should be False (empty result)
        result = self.y1 > self.y3
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 3 > 4")

        # y3 > y1 (4 > 3) should be True (non-empty result)
        result = self.y3 > self.y1
        self.assertEqual(result.ydata().size, 1, "Result should have one element for 4 > 3")
        self.assertEqual(result.ydata()[0], 4, "Result should contain the value 4")

    def test_gt_array_scalar(self):
        """Test greater than operator with array and scalar."""
        # y4 > y1 ([1, -5] > 3) should be False for all elements
        result = self.y4 > self.y1
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [1, -5] > 3")

        # y1 > y4 (3 > [1, -5]) should be True for all elements
        result = self.y1 > self.y4
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for 3 > [1, -5]")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

    def test_gt_array_array(self):
        """Test greater than operator with two arrays."""
        # y4 > y5 ([1, -5] > [5, 6]) should be False for all elements
        result = self.y4 > self.y5
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [1, -5] > [5, 6]")

        # y5 > y4 ([5, 6] > [1, -5]) should be True for all elements
        result = self.y5 > self.y4
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [5, 6] > [1, -5]")
        self.assertTrue(numpy.array_equal(result.ydata(), [5, 6]), "Result should contain the values [5, 6]")

    def test_gt_different_units(self):
        """Test greater than operator with different units."""
        with self.assertRaises(Exception):
            result = self.y1 > self.y6

    def test_lt_scalar_scalar_equal(self):
        """Test less than operator with equal scalar values."""
        result = self.y1 < self.y2
        self.assertEqual(result.ydata().size, 0, "Result should be empty for equal values")

    def test_lt_scalar_scalar_different(self):
        """Test less than operator with different scalar values."""
        # y1 < y3 (3 < 4) should be True (non-empty result)
        result = self.y1 < self.y3
        self.assertEqual(result.ydata().size, 1, "Result should have one element for 3 < 4")
        self.assertEqual(result.ydata()[0], 3, "Result should contain the value 3")

        # y3 < y1 (4 < 3) should be False (empty result)
        result = self.y3 < self.y1
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 4 < 3")

    def test_lt_array_scalar(self):
        """Test less than operator with array and scalar."""
        # y4 < y1 ([1, -5] < 3) should be True for all elements
        result = self.y4 < self.y1
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, -5] < 3")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

        # y1 < y4 (3 < [1, -5]) should be False for all elements
        result = self.y1 < self.y4
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 3 < [1, -5]")

    def test_lt_array_array(self):
        """Test less than operator with two arrays."""
        # y4 < y5 ([1, -5] < [5, 6]) should be True for all elements
        result = self.y4 < self.y5
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, -5] < [5, 6]")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

        # y5 < y4 ([5, 6] < [1, -5]) should be False for all elements
        result = self.y5 < self.y4
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [5, 6] < [1, -5]")

    def test_lt_different_units(self):
        """Test less than operator with different units."""
        with self.assertRaises(Exception):
            result = self.y1 < self.y6

    def test_ge_scalar_scalar_equal(self):
        """Test greater than or equal operator with equal scalar values."""
        result = self.y1 >= self.y2
        self.assertEqual(result.ydata().size, 1, "Result should have one element for equal values")
        self.assertEqual(result.ydata()[0], 3, "Result should contain the value 3")

    def test_ge_scalar_scalar_different(self):
        """Test greater than or equal operator with different scalar values."""
        # y1 >= y3 (3 >= 4) should be False (empty result)
        result = self.y1 >= self.y3
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 3 >= 4")

        # y3 >= y1 (4 >= 3) should be True (non-empty result)
        result = self.y3 >= self.y1
        self.assertEqual(result.ydata().size, 1, "Result should have one element for 4 >= 3")
        self.assertEqual(result.ydata()[0], 4, "Result should contain the value 4")

    def test_ge_array_scalar(self):
        """Test greater than or equal operator with array and scalar."""
        # y4 >= y1 ([1, -5] >= 3) should be False for all elements
        result = self.y4 >= self.y1
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [1, -5] >= 3")

        # y1 >= y4 (3 >= [1, -5]) should be True for all elements
        result = self.y1 >= self.y4
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for 3 >= [1, -5]")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

    def test_ge_array_array(self):
        """Test greater than or equal operator with two arrays."""
        # y4 >= y5 ([1, -5] >= [5, 6]) should be False for all elements
        result = self.y4 >= self.y5
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [1, -5] >= [5, 6]")

        # y5 >= y4 ([5, 6] >= [1, -5]) should be True for all elements
        result = self.y5 >= self.y4
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [5, 6] >= [1, -5]")
        self.assertTrue(numpy.array_equal(result.ydata(), [5, 6]), "Result should contain the values [5, 6]")

    def test_ge_different_units(self):
        """Test greater than or equal operator with different units."""
        with self.assertRaises(Exception):
            result = self.y1 >= self.y6

    def test_le_scalar_scalar_equal(self):
        """Test less than or equal operator with equal scalar values."""
        result = self.y1 <= self.y2
        self.assertEqual(result.ydata().size, 1, "Result should have one element for equal values")
        self.assertEqual(result.ydata()[0], 3, "Result should contain the value 3")

    def test_le_scalar_scalar_different(self):
        """Test less than or equal operator with different scalar values."""
        # y1 <= y3 (3 <= 4) should be True (non-empty result)
        result = self.y1 <= self.y3
        self.assertEqual(result.ydata().size, 1, "Result should have one element for 3 <= 4")
        self.assertEqual(result.ydata()[0], 3, "Result should contain the value 3")

        # y3 <= y1 (4 <= 3) should be False (empty result)
        result = self.y3 <= self.y1
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 4 <= 3")

    def test_le_array_scalar(self):
        """Test less than or equal operator with array and scalar."""
        # y4 <= y1 ([1, -5] <= 3) should be True for all elements
        result = self.y4 <= self.y1
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, -5] <= 3")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

        # y1 <= y4 (3 <= [1, -5]) should be False for all elements
        result = self.y1 <= self.y4
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 3 <= [1, -5]")

    def test_le_array_array(self):
        """Test less than or equal operator with two arrays."""
        # y4 <= y5 ([1, -5] <= [5, 6]) should be True for all elements
        result = self.y4 <= self.y5
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, -5] <= [5, 6]")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

        # y5 <= y4 ([5, 6] <= [1, -5]) should be False for all elements
        result = self.y5 <= self.y4
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [5, 6] <= [1, -5]")

    def test_le_different_units(self):
        """Test less than or equal operator with different units."""
        with self.assertRaises(Exception):
            result = self.y1 <= self.y6

    def test_eq_scalar_scalar_equal(self):
        """Test equal operator with equal scalar values."""
        result = self.y1 == self.y2
        self.assertEqual(result.ydata().size, 1, "Result should have one element for equal values")
        self.assertEqual(result.ydata()[0], 3, "Result should contain the value 3")

    def test_eq_scalar_scalar_different(self):
        """Test equal operator with different scalar values."""
        # y1 == y3 (3 == 4) should be False (empty result)
        result = self.y1 == self.y3
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 3 == 4")

    def test_eq_array_scalar(self):
        """Test equal operator with array and scalar."""
        # y4 == y1 ([1, -5] == 3) should be False for all elements
        result = self.y4 == self.y1
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [1, -5] == 3")

    def test_eq_array_array(self):
        """Test equal operator with two arrays."""
        # Create two equal arrays
        y7 = YData(yaxis=[1, 2], yunits="m", name="y7")
        y8 = YData(yaxis=[1, 2], yunits="m", name="y8")
        result = y7 == y8
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, 2] == [1, 2]")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, 2]), "Result should contain the values [1, 2]")

    def test_eq_different_units(self):
        """Test equal operator with different units."""
        with self.assertRaises(Exception):
            result = self.y1 == self.y6

    def test_ne_scalar_scalar_equal(self):
        """Test not equal operator with equal scalar values."""
        result = self.y1 != self.y2
        self.assertEqual(result.ydata().size, 0, "Result should be empty for equal values")

    def test_ne_scalar_scalar_different(self):
        """Test not equal operator with different scalar values."""
        # y1 != y3 (3 != 4) should be True (non-empty result)
        result = self.y1 != self.y3
        self.assertEqual(result.ydata().size, 1, "Result should have one element for 3 != 4")
        self.assertEqual(result.ydata()[0], 3, "Result should contain the value 3")

    def test_ne_array_scalar(self):
        """Test not equal operator with array and scalar."""
        # y4 != y1 ([1, -5] != 3) should be True for all elements
        result = self.y4 != self.y1
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, -5] != 3")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

    def test_ne_array_array(self):
        """Test not equal operator with two arrays."""
        # y4 != y5 ([1, -5] != [5, 6]) should be True for all elements
        result = self.y4 != self.y5
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, -5] != [5, 6]")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

    def test_ne_different_units(self):
        """Test not equal operator with different units."""
        with self.assertRaises(Exception):
            result = self.y1 != self.y6


class XYDataOperatorsTestCase(unittest.TestCase):
    """Test case for XYData comparison operators."""

    def setUp(self):
        """Set up test fixtures."""
        # Create scalar XYData objects
        self.xy1 = XYData(xaxis=[1], yaxis=3, yunits="m", name="xy1")
        self.xy2 = XYData(xaxis=[1], yaxis=3, yunits="m", name="xy2")  # Equal to xy1
        self.xy3 = XYData(xaxis=[1], yaxis=4, yunits="m", name="xy3")  # Greater than xy1

        # Create array XYData objects
        self.xy4 = XYData(xaxis=[1, 2], yaxis=[1, -5], yunits="m", name="xy4")
        self.xy5 = XYData(xaxis=[1, 2], yaxis=[5, 6], yunits="m", name="xy5")  # Greater than xy4

        # Create XYData with different units
        self.xy6 = XYData(xaxis=[1], yaxis=3, yunits="s", name="xy6")

    def test_gt_scalar_scalar_equal(self):
        """Test greater than operator with equal scalar values."""
        result = self.xy1 > self.xy2
        self.assertEqual(result.ydata().size, 0, "Result should be empty for equal values")

    def test_gt_scalar_scalar_different(self):
        """Test greater than operator with different scalar values."""
        # xy1 > xy3 (3 > 4) should be False (empty result)
        result = self.xy1 > self.xy3
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 3 > 4")

        # xy3 > xy1 (4 > 3) should be True (non-empty result)
        result = self.xy3 > self.xy1
        self.assertEqual(result.ydata().size, 1, "Result should have one element for 4 > 3")
        self.assertEqual(result.ydata()[0], 4, "Result should contain the value 4")

    def test_gt_array_scalar(self):
        """Test greater than operator with array and scalar."""
        # xy4 > xy1 ([1, -5] > 3) should be False for all elements
        result = self.xy4 > self.xy1
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [1, -5] > 3")

        # xy1 > xy4 (3 > [1, -5]) should be True for all elements
        result = self.xy1 > self.xy4
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for 3 > [1, -5]")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

    def test_gt_array_array(self):
        """Test greater than operator with two arrays."""
        # xy4 > xy5 ([1, -5] > [5, 6]) should be False for all elements
        result = self.xy4 > self.xy5
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [1, -5] > [5, 6]")

        # xy5 > xy4 ([5, 6] > [1, -5]) should be True for all elements
        result = self.xy5 > self.xy4
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [5, 6] > [1, -5]")
        self.assertTrue(numpy.array_equal(result.ydata(), [5, 6]), "Result should contain the values [5, 6]")

    def test_gt_different_units(self):
        """Test greater than operator with different units."""
        with self.assertRaises(Exception):
            result = self.xy1 > self.xy6

    def test_lt_scalar_scalar_equal(self):
        """Test less than operator with equal scalar values."""
        result = self.xy1 < self.xy2
        self.assertEqual(result.ydata().size, 0, "Result should be empty for equal values")

    def test_lt_scalar_scalar_different(self):
        """Test less than operator with different scalar values."""
        # xy1 < xy3 (3 < 4) should be True (non-empty result)
        result = self.xy1 < self.xy3
        self.assertEqual(result.ydata().size, 1, "Result should have one element for 3 < 4")
        self.assertEqual(result.ydata()[0], 3, "Result should contain the value 3")

        # xy3 < xy1 (4 < 3) should be False (empty result)
        result = self.xy3 < self.xy1
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 4 < 3")

    def test_lt_array_scalar(self):
        """Test less than operator with array and scalar."""
        # xy4 < xy1 ([1, -5] < 3) should be True for all elements
        result = self.xy4 < self.xy1
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, -5] < 3")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

        # xy1 < xy4 (3 < [1, -5]) should be False for all elements
        result = self.xy1 < self.xy4
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 3 < [1, -5]")

    def test_lt_array_array(self):
        """Test less than operator with two arrays."""
        # xy4 < xy5 ([1, -5] < [5, 6]) should be True for all elements
        result = self.xy4 < self.xy5
        print(result)
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, -5] < [5, 6]")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

        # xy5 < xy4 ([5, 6] < [1, -5]) should be False for all elements
        result = self.xy5 < self.xy4
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [5, 6] < [1, -5]")

    def test_lt_different_units(self):
        """Test less than operator with different units."""
        with self.assertRaises(Exception):
            result = self.xy1 < self.xy6

    def test_ge_scalar_scalar_equal(self):
        """Test greater than or equal operator with equal scalar values."""
        result = self.xy1 >= self.xy2
        self.assertEqual(result.ydata().size, 1, "Result should have one element for equal values")
        self.assertEqual(result.ydata()[0], 3, "Result should contain the value 3")

    def test_ge_scalar_scalar_different(self):
        """Test greater than or equal operator with different scalar values."""
        # xy1 >= xy3 (3 >= 4) should be False (empty result)
        result = self.xy1 >= self.xy3
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 3 >= 4")

        # xy3 >= xy1 (4 >= 3) should be True (non-empty result)
        result = self.xy3 >= self.xy1
        self.assertEqual(result.ydata().size, 1, "Result should have one element for 4 >= 3")
        self.assertEqual(result.ydata()[0], 4, "Result should contain the value 4")

    def test_ge_array_scalar(self):
        """Test greater than or equal operator with array and scalar."""
        # xy4 >= xy1 ([1, -5] >= 3) should be False for all elements
        result = self.xy4 >= self.xy1
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [1, -5] >= 3")

        # xy1 >= xy4 (3 >= [1, -5]) should be True for all elements
        result = self.xy1 >= self.xy4
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for 3 >= [1, -5]")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

    def test_ge_array_array(self):
        """Test greater than or equal operator with two arrays."""
        # xy4 >= xy5 ([1, -5] >= [5, 6]) should be False for all elements
        result = self.xy4 >= self.xy5
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [1, -5] >= [5, 6]")

        # xy5 >= xy4 ([5, 6] >= [1, -5]) should be True for all elements
        result = self.xy5 >= self.xy4
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [5, 6] >= [1, -5]")
        self.assertTrue(numpy.array_equal(result.ydata(), [5, 6]), "Result should contain the values [5, 6]")

    def test_ge_different_units(self):
        """Test greater than or equal operator with different units."""
        with self.assertRaises(Exception):
            result = self.xy1 >= self.xy6

    def test_le_scalar_scalar_equal(self):
        """Test less than or equal operator with equal scalar values."""
        result = self.xy1 <= self.xy2
        self.assertEqual(result.ydata().size, 1, "Result should have one element for equal values")
        self.assertEqual(result.ydata()[0], 3, "Result should contain the value 3")

    def test_le_scalar_scalar_different(self):
        """Test less than or equal operator with different scalar values."""
        # xy1 <= xy3 (3 <= 4) should be True (non-empty result)
        result = self.xy1 <= self.xy3
        self.assertEqual(result.ydata().size, 1, "Result should have one element for 3 <= 4")
        self.assertEqual(result.ydata()[0], 3, "Result should contain the value 3")

        # xy3 <= xy1 (4 <= 3) should be False (empty result)
        result = self.xy3 <= self.xy1
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 4 <= 3")

    def test_le_array_scalar(self):
        """Test less than or equal operator with array and scalar."""
        # xy4 <= xy1 ([1, -5] <= 3) should be True for all elements
        result = self.xy4 <= self.xy1
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, -5] <= 3")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

        # xy1 <= xy4 (3 <= [1, -5]) should be False for all elements
        result = self.xy1 <= self.xy4
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 3 <= [1, -5]")

    def test_le_array_array(self):
        """Test less than or equal operator with two arrays."""
        # xy4 <= xy5 ([1, -5] <= [5, 6]) should be True for all elements
        result = self.xy4 <= self.xy5
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, -5] <= [5, 6]")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

        # xy5 <= xy4 ([5, 6] <= [1, -5]) should be False for all elements
        result = self.xy5 <= self.xy4
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [5, 6] <= [1, -5]")

    def test_le_different_units(self):
        """Test less than or equal operator with different units."""
        with self.assertRaises(Exception):
            result = self.xy1 <= self.xy6

    def test_eq_scalar_scalar_equal(self):
        """Test equal operator with equal scalar values."""
        result = self.xy1 == self.xy2
        self.assertEqual(result.ydata().size, 1, "Result should have one element for equal values")
        self.assertEqual(result.ydata()[0], 3, "Result should contain the value 3")

    def test_eq_scalar_scalar_different(self):
        """Test equal operator with different scalar values."""
        # xy1 == xy3 (3 == 4) should be False (empty result)
        result = self.xy1 == self.xy3
        self.assertEqual(result.ydata().size, 0, "Result should be empty for 3 == 4")

    def test_eq_array_scalar(self):
        """Test equal operator with array and scalar."""
        # xy4 == xy1 ([1, -5] == 3) should be False for all elements
        result = self.xy4 == self.xy1
        self.assertEqual(result.ydata().size, 0, "Result should be empty for [1, -5] == 3")

    def test_eq_array_array(self):
        """Test equal operator with two arrays."""
        # Create two equal arrays
        xy7 = XYData(xaxis=[1, 2], yaxis=[1, 2], yunits="m", name="xy7")
        xy8 = XYData(xaxis=[1, 2], yaxis=[1, 2], yunits="m", name="xy8")
        result = xy7 == xy8
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, 2] == [1, 2]")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, 2]), "Result should contain the values [1, 2]")

    def test_eq_different_units(self):
        """Test equal operator with different units."""
        with self.assertRaises(Exception):
            result = self.xy1 == self.xy6

    def test_ne_scalar_scalar_equal(self):
        """Test not equal operator with equal scalar values."""
        result = self.xy1 != self.xy2
        self.assertEqual(result.ydata().size, 0, "Result should be empty for equal values")

    def test_ne_scalar_scalar_different(self):
        """Test not equal operator with different scalar values."""
        # xy1 != xy3 (3 != 4) should be True (non-empty result)
        result = self.xy1 != self.xy3
        self.assertEqual(result.ydata().size, 1, "Result should have one element for 3 != 4")
        self.assertEqual(result.ydata()[0], 3, "Result should contain the value 3")

    def test_ne_array_scalar(self):
        """Test not equal operator with array and scalar."""
        # xy4 != xy1 ([1, -5] != 3) should be True for all elements
        result = self.xy4 != self.xy1
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, -5] != 3")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

    def test_ne_array_array(self):
        """Test not equal operator with two arrays."""
        # xy4 != xy5 ([1, -5] != [5, 6]) should be True for all elements
        result = self.xy4 != self.xy5
        self.assertEqual(result.ydata().size, 2, "Result should have two elements for [1, -5] != [5, 6]")
        self.assertTrue(numpy.array_equal(result.ydata(), [1, -5]), "Result should contain the values [1, -5]")

    def test_ne_different_units(self):
        """Test not equal operator with different units."""
        with self.assertRaises(Exception):
            result = self.xy1 != self.xy6


if __name__ == "__main__":
    unittest.main()
