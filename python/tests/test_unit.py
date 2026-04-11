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
from operator import __add__

from pyda.utils.unit import Unit


class Test(unittest.TestCase):
    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_empty_constructor(self):
        obj = Unit()
        self.assertIsNotNone(obj, "the empty constructor didn't return an object")
        self.assertTrue(
            isinstance(obj, Unit), "the empty constructor should return a Unit"
        )

    def test_parse_eg1(self):
        us = "m^2"
        u = Unit(us)
        self.assertEqual(
            u.strs, ["m"], "The unit strings should contain a single element 'm'"
        )
        self.assertEqual(
            u.exps, [2], "The unit exponents should contain a single element [2]"
        )
        self.assertEqual(
            u.vals, [1], "The unit vals should contain a single element [1]"
        )

    def test_parse_eg2(self):
        us = "nN^2"
        u = Unit(us)
        self.assertEqual(
            u.strs, ["N"], "The unit strings should contain a single element 'N'"
        )
        self.assertEqual(
            u.exps, [2], "The unit exponents should contain a single element [2]"
        )
        self.assertEqual(
            u.vals, [1e-9], "The unit vals should contain a single element [1e-9]"
        )

    def test_parse_eg3(self):
        us = "m^2 / Hz"
        u = Unit(us)
        self.assertEqual(u.strs, ["m", "Hz"], "The unit strings are wrong")
        self.assertEqual(u.exps, [2, -1], "The unit exponents are wrong")
        self.assertEqual(u.vals, [1, 1], "The unit vals are wrong")

    def test_parse_eg4(self):
        us = "pF m^2 / Hz"
        u = Unit(us)
        self.assertEqual(u.strs, ["F", "m", "Hz"], "The unit strings are wrong")
        self.assertEqual(u.exps, [1, 2, -1], "The unit exponents are wrong")
        self.assertEqual(u.vals, [1e-12, 1, 1], "The unit vals are wrong")

    def test_parse_eg5(self):
        us = "pF m^2 / Hz / s"
        u = Unit(us)
        self.assertEqual(u.strs, ["F", "m", "Hz", "s"], "The unit strings are wrong")
        self.assertEqual(u.exps, [1, 2, -1, -1], "The unit exponents are wrong")
        self.assertEqual(u.vals, [1e-12, 1, 1, 1], "The unit vals are wrong")

    def test_parse_eg6(self):
        us = "1/N 1/s)"
        u = Unit(us)
        self.assertEqual(u.strs, ["N", "s"], "The unit strings are wrong")
        self.assertEqual(u.exps, [-1, -1], "The unit exponents are wrong")
        self.assertEqual(u.vals, [1, 1], "The unit vals are wrong")

    def test_parse_empty_unit(self):
        us = ""
        u = Unit(us)
        self.assertTrue(u.isEmpty(), "This should be an empty unit")

    def test_parse_all_supported_units(self):
        for us in Unit.supportedUnits():
            if len(us) > 0:
                for p in Unit.supportedPrefixes():
                    u = Unit(p + us)
                    v = Unit.valForPrefix(p)
                    self.assertEqual(
                        u.strs,
                        [us],
                        "The unit strings should contain a single element [%s]" % us,
                    )
                    self.assertEqual(
                        u.exps,
                        [1],
                        "The unit exponents should contain a single element [1]",
                    )
                    self.assertEqual(
                        u.vals,
                        [v],
                        "The unit vals should contain a single element [%g]" % v,
                    )

    def test_eq1(self):
        u1 = Unit("m")
        u2 = Unit("m")
        self.assertTrue(u1 == u2, "The two units should be equal")

    def test_eq2(self):
        u1 = Unit("m s^-2")
        u2 = Unit("m s^-2")
        self.assertTrue(u1 == u2, "The two units should be equal")

    def test_not_eq(self):
        u1 = Unit("m s^-2")
        u2 = Unit("m s^-1")
        self.assertFalse(u1 == u2, "The two units should not be equal")

    def test_char_eval(self):
        u1 = Unit("m s^-2")
        s = u1.char()
        u2 = Unit(s)
        self.assertTrue(u1 == u2, "The two units should be equal")

    def test_extract(self):
        u1 = Unit("m us^-2")
        u2 = u1.extract("m")
        u3 = u1.extract("s")
        self.assertEqual(
            u2.strs, ["m"], "The extracted unit should contain the correct string"
        )
        self.assertEqual(
            u2.exps, [1], "The extracted unit should contain the correct exponents"
        )
        self.assertEqual(
            u2.vals, [1], "The extracted unit should contain the correct vals"
        )
        self.assertEqual(
            u3.strs, ["s"], "The extracted unit should contain the correct string"
        )
        self.assertEqual(
            u3.exps, [-2], "The extracted unit should contain the correct exponents"
        )
        self.assertEqual(
            u3.vals, [1e-6], "The extracted unit should contain the correct vals"
        )

    def test_combine(self):
        u1 = Unit("m")
        u2 = Unit("s")
        u3 = u1.combine(u2)
        self.assertTrue(
            "m" in u3.strs and "s" in u3.strs,
            "The combined unit should contain both strings",
        )

    def test_explode(self):
        tests = ["m", "s", "N"]
        u1 = Unit("m s^-2 / N")
        us = u1.explode()
        self.assertTrue(len(us) == 3, "The exploded units should be length 3")
        for u in us:
            self.assertTrue(
                u.strs[0] in tests,
                "Each of the input units should appear in the output",
            )

    def test_simplify1(self):
        u = Unit("m^2 ms^2 kg^3 s^-2")
        us = u.simplify()
        target = Unit("mm^2 kg^3")
        self.assertEqual(
            us, target, "The simplified unit should match the expected target"
        )

    def test_simplify2(self):
        u = Unit("N/N")
        us = u.simplify()
        target = Unit("")
        self.assertEqual(
            us, target, "The simplified unit should match the expected target"
        )

    def test_not_eq(self):
        u1 = Unit("m")
        u2 = Unit("N")

        self.assertFalse(u1 == u2, "Units are not different")

    def test__eq1(self):
        u1 = Unit("m s^-2 kg")
        u2 = Unit("kg s^-2 m")
        print(u1)
        print(u2.simplify())
        self.assertTrue(u1 == u2, "Units are different")

    def test__eq2(self):
        # this fails because the common units are not collected together
        u1 = Unit("m s^-2 kg")
        u2 = Unit("kg s^-1 s^-1 m")
        print(u2.simplify())
        self.assertTrue(u1 == u2, "Units are different")

    def test_add_exception(self):
        u1 = Unit("s")
        u2 = Unit("m")

        self.assertRaisesRegex(Exception, ".*", __add__, u1, u2)

    def test_add1(self):
        u1 = Unit("s")
        u2 = Unit("s")

        u3 = u1 + u2

        self.assertEqual(u1, u3, "units should be equal")

    def test_mul1(self):
        u1 = Unit("s")
        u2 = Unit("s")
        u3 = u1 * u2
        print(u3.char())
        self.assertEqual(u3, Unit("s^2"), "units should be equal")

    def test_mul2(self):
        u1 = Unit("s")
        u2 = Unit("m")
        u3 = u1 * u2
        print(u3.char())
        self.assertEqual(u3, Unit("m s"), "units should be equal")

    def test_mul2(self):
        u1 = 1
        u2 = Unit("m")
        u3 = u2 * u1
        print(u3.char())
        self.assertEqual(u3, Unit("m"), "units should be equal")

    def test_mul2(self):
        u1 = Unit("1/m")
        u2 = Unit("m")
        u3 = u2 * u1
        print(u3.char())
        self.assertEqual(u3, Unit(), "units should be equal")

    def test_div1(self):
        u1 = Unit("m")
        u2 = Unit("m")
        u3 = u2 / u1
        print(u3.char())
        self.assertEqual(u3, Unit(), "units should be equal")

    def test_div2(self):
        u1 = Unit("m")
        u2 = Unit("s")
        u3 = u1 / u2
        print(u3.char())
        self.assertEqual(u3, Unit("m s^-1"), "units should be equal")

    def test_div3(self):
        u1 = Unit("m s")
        u2 = Unit("s")
        u3 = u1 / u2
        print(u3.char())
        self.assertEqual(u3, Unit("m"), "units should be equal")

    def test_pow1(self):
        u1 = Unit("m")
        u2 = u1**2
        print(u2)
        self.assertEqual(u2, Unit("m^2"), "units should be equal")

    def test_sqrt1(self):
        u1 = Unit("m^2")
        u2 = u1.sqrt()
        print(u2)
        self.assertEqual(u2, Unit("m"), "units should be equal")

    def test_val2prefix(self):
        p = Unit.prefixForVal(1e-3)
        print(p)

    def test_toLabel(self):
        u1 = Unit("mm / kg")
        s = u1.toLabel()
        print(s)

    def test_toSI(self):
        u1 = Unit("N / kg")
        s = u1.toSI()
        a = Unit("m s^-2")
        self.assertEqual(s, a)
        print(s)
