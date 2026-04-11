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

from setuptools import setup

setup(
    name="pyda.py",
    version="1.0",
    packages=[
        "dsp",
        "utils",
        "utils.math",
        "utils.prog",
        "mixins",
        "exceptions",
    ],
    package_dir={"": "pyda"},
    url="",
    license="",
    author="hewitson",
    author_email="hewitson@aei.mpg.de",
    description="pyda setup script",
)
