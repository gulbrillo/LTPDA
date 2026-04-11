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


class WrongDataTypeException(Exception):
    """
    A class defining an exception for a wrongly input data type.
    """

    def __init__(self, message):
        """
        This class takes a single argument which is the message for this exception.

          e = WrongDataTypeException(message)

        """
        self.message = message

    def __str__(self):
        return repr(self.message)


class InvalidOperatorException(Exception):
    """
    A class defining an exception for attempted use of an invalid operator.
    """

    def __init__(self, message):
        """
        This class takes a single argument which is the message for this exception.

          e = InvalidOperatorException(message)

        """
        self.message = message

    def __str__(self):
        return repr(self.message)
