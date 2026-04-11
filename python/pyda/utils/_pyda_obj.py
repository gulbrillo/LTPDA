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


import uuid


class _pyda_obj:
    def __init__(self, name: str = "PYDAObject", description: str = ""):
        self._id = uuid.uuid4()  # ensure we have a new UUID
        self._name = name
        self._description = description
        self._marker = None
        self._linestyle = None
        self._color = None
        self._linewidth = None

    @property
    def id(self):
        return self._id

    @id.setter
    def id(self, val=None):
        self._id = val

    @id.deleter
    def id(self):
        del self._id

    @property
    def name(self):
        return self._name

    @name.setter
    def name(self, val=None):
        self._name = val

    @name.deleter
    def name(self):
        del self._name

    @property
    def description(self):
        return self._description

    @description.setter
    def description(self, val=None):
        self._description = val

    @description.deleter
    def description(self):
        del self._description

    def __str__(self):
        """

        :return:
        """
        s = "-------- YData ---------\n"
        s += "  name: " + self._name + "\n"
        s += "  uuid: " + str(self.id) + "\n"
        s += "  desc: " + str(self.description) + "\n"

        s += "\n-----------------------------"
        return s
