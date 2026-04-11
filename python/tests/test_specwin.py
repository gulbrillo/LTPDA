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

from pyda.utils.specwin import Specwin


class Test(unittest.TestCase):
    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_empty_constructor(self):
        obj = Specwin()
        self.assertIsNotNone(obj, "the empty constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, Specwin), "the empty constructor should return a specwin"
        )

    def test_build_all_windows(self):
        wins = Specwin.supportedWindows()
        for w in wins:
            s = Specwin(w, 100)
            vals = s.win()
            self.assertTrue(
                len(vals) == 100,
                "The window %s should be 100 samples long, not %s"
                % (w, str(len(vals))),
            )
            self.assertEqual(
                w.lower(), s.name.lower(), "The window name should be %s" % w.lower()
            )
