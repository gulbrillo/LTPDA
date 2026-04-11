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

import numpy
import numbers
import pyda
from pyda.utils._pyda_obj import _pyda_obj


class YDataOperators:
    """
    A mixin class that provides comparison operators for YData objects.
    """

    # Helper method for comparison operators
    def _compare(self, other, op_name, op_func):
        """
        Helper method for comparison operators.

        :param other: The other YData object to compare with
        :param op_name: The name of the operator (e.g., ">", "<")
        :param op_func: The function to apply to the yaxis objects
        :return: A new YData object with the comparison result
        """
        if isinstance(other, pyda.ydata.YData):
            # check they have the same yunits
            u1 = self.yunits()
            u2 = other.yunits()
            if u1 != u2:
                print(self)
                raise Exception(
                    "Units of object 1 " + u1.char() + " not equal to object 2 " + u2.char()
                )

            out = self.deepcopy()
            out.yaxis = op_func(self.yaxis, other.yaxis)
            out.name = "(" + self.name + " " + op_name + " " + other.name + ")"
            return out
        else:
            raise Exception("Cannot compare YData with " + str(type(other)))

    # override >
    def __gt__(self, other):
        """
        Override the greater than operator to compare two YData objects.
        Return a new YData object with the values that pass the > test.

        if self is a scalar, then compare with the other object and return a subset of the other object
        if other is a scalar, then compare with the self object and return a subset of the self object
        if both are arrays, then return a new YData object with the values that pass the < test.

        :param other: The other YData object to compare with
        :return:
        """
        return self._compare(other, ">", lambda x, y: x > y)

    # override <
    def __lt__(self, other):
        """
        Override the less than operator to compare two YData objects.
        Return a new YData object with the values that pass the < test.

        if self is a scalar, then compare with the other object and return a subset of the other object
        if other is a scalar, then compare with the self object and return a subset of the self object
        if both are arrays, then return a new YData object with the values that pass the < test.

        :param other: The other YData object to compare with
        :return:
        """
        return self._compare(other, "<", lambda x, y: x < y)

    # override >=
    def __ge__(self, other):
        """
        Override the greater than or equal operator to compare two YData objects.
        Return a new YData object with the values that pass the >= test.

        if self is a scalar, then compare with the other object and return a subset of the other object
        if other is a scalar, then compare with the self object and return a subset of the self object
        if both are arrays, then return a new YData object with the values that pass the >= test.

        :param other: The other YData object to compare with
        :return:
        """
        return self._compare(other, ">=", lambda x, y: x >= y)

    # override <=
    def __le__(self, other):
        """
        Override the less than or equal operator to compare two YData objects.
        Return a new YData object with the values that pass the <= test.

        if self is a scalar, then compare with the other object and return a subset of the other object
        if other is a scalar, then compare with the self object and return a subset of the self object
        if both are arrays, then return a new YData object with the values that pass the <= test.

        :param other: The other YData object to compare with
        :return:
        """
        return self._compare(other, "<=", lambda x, y: x <= y)

    # override ==
    def __eq__(self, other):
        """
        Override the equal operator to compare two YData objects.
        Return a new YData object with the values that pass the == test.

        if self is a scalar, then compare with the other object and return a subset of the other object
        if other is a scalar, then compare with the self object and return a subset of the self object
        if both are arrays, then return a new YData object with the values that pass the == test.

        :param other: The other YData object to compare with
        :return:
        """
        return self._compare(other, "==", lambda x, y: x == y)

    # override !=
    def __ne__(self, other):
        """
        Override the not equal operator to compare two YData objects.
        Return a new YData object with the values that pass the != test.

        if self is a scalar, then compare with the other object and return a subset of the other object
        if other is a scalar, then compare with the self object and return a subset of the self object
        if both are arrays, then return a new YData object with the values that pass the != test.

        :param other: The other YData object to compare with
        :return:
        """
        return self._compare(other, "!=", lambda x, y: x != y)
