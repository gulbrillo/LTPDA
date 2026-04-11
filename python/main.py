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

# This is a sample Python script.

# Press ⌃R to execute it or replace it with your code.
# Press Double ⇧ to search everywhere for classes, files, tool windows, actions, and settings.
import timeit

from pyda.tsdata import TSData
from pyda.ydata import YData
import pyda.dsp.spectral
import numpy

# Press the green button in the gutter to run the script.
if __name__ == "__main__":
    ts = TSData.randn(nsecs=1e5, fs=10.0, yunits="m")
    print(ts)

    y = YData(name="Hello")
    print(y)
    # Sxx.loglog()

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
