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

from fractions import Fraction

from itertools import zip_longest, compress
import numbers

import math
import numpy
from numpy import *
from pyda.utils.math import rat

import copy
import re

from pyda.exceptions.typeexceptions import WrongDataTypeException
from pyda.exceptions.typeexceptions import InvalidOperatorException
from pyda.exceptions.rangeexceptions import WrongSizeException
from pyda.exceptions.rangeexceptions import IndexOutOfRangeException


class Unit:
    """
    This class encapsulates scientific units.

    unit objects support simplification, conversion to SI, as well as standard operations
    like multiplication and division.

    """

    # ----------------------------------------------------
    # Constructor
    # ----------------------------------------------------

    def __init__(self, *args):
        """
        Construct unit objects using the following possible constructors.

        EXAMPLES:

               u = unit('m');            - Create a simple unit
               u = unit('m^3');          - With an exponent
               u = unit('m^1/2');
               u = unit('m^1.5');
               u = unit('pm^2');         - With a prefix
               u = unit('m s^-2 kg');    - Multiple units
               u = unit('m/s');          - Units with division
               u = unit('m^.5 / s^2');

               # construct via lists of unit strings, exponents and prefix values
               u = unit([strs], [exps], [vals]);


        """

        # call superclass

        # process arguments
        nargs = len(args)

        # defaults
        self.__strs = []
        self.__exps = []
        self.__vals = []

        if nargs == 0:
            pass
        elif nargs == 1:
            if not isinstance(args[0], type("")):
                raise WrongDataTypeException(
                    "The first argument to Unit() should be a string"
                )

            # split input by whitespace
            ustrs, uexps, uvals = Unit.parseUnitExpression(args[0])

            # set properties
            self.strs = ustrs
            self.exps = uexps
            self.vals = uvals

        elif nargs == 3:
            self.strs = args[0]
            self.exps = args[1]
            self.vals = args[2]
        else:
            raise IndexOutOfRangeException(
                "The Unit constructor supports 0 or 1 argument"
            )

    # ----------------------------------------------------
    # Operators
    # ----------------------------------------------------

    def __truediv__(self, other):
        v1 = self
        v2 = other

        exps = [x * -1 for x in v2.exps]

        if isinstance(v1, numbers.Number):
            v1 = Unit()

        if isinstance(v2, numbers.Number):
            v2 = Unit()

        if not v1.strs: # this means we are just returning 1/input2
            # copy the input and change exps
            v = v2.deepcopy()
            v.exps = exps
            return v

        if not v2.strs:
            # just return a copy of the first input
            return v1.deepcopy()

        v = Unit()

        v.strs = v1.strs + v2.strs
        v.exps = v1.exps + exps
        v.vals = v1.vals + v2.vals

        return v.simplify()

    def __pow__(self, power, modulo=None):
        v = self.deepcopy()
        v.exps = [x * power for x in v.exps]
        return v

    def sqrt(self):
        v = self.deepcopy()
        v.exps = [x * 0.5 for x in v.exps]
        return v

    def __sub__(self, other):
        raise Exception("not implemented")
        pass

    def __add__(self, other):
        if self == other:
            return self
        else:
            raise Exception(
                "Units of different kinds cannot be added "
                + self.char()
                + " | "
                + other.char()
            )

    def __mul__(self, other):

        v1 = self
        v2 = other

        if isinstance(v1, numbers.Number):
            v1 = Unit()

        if isinstance(v2, numbers.Number):
            v2 = Unit()

        if not v1.strs:
            return v2

        if not v2.strs:
            return v1

        v = Unit()
        v.strs = v1.strs + v2.strs
        v.exps = v1.exps + v2.exps
        v.vals = v1.vals + v2.vals

        return v.simplify()

    def toSI(self, exceptions=[]):

        if not self.strs:
            return self.deepcopy()

        scale = 0
        conversion_fact = 0

        # process the units and exponents
        v = Unit()
        kk = 0
        for ustr in self.strs:
            s, conv_f = Unit._siForUnit(ustr, exceptions)
            conversion_fact = conversion_fact + self.exps[kk] * numpy.log10(conv_f)
            s = Unit(s)
            nexps = numpy.array(s.exps) * self.exps[kk]
            s.exps = nexps.tolist()
            scale = scale + (self.vals[kk] * (self.exps[kk]))
            v = v * s
            kk += 1

        v = v.simplify()
        scale = 10 ** (double(scale) + conversion_fact)

        # if scale != 1:
        #     raise Exception(f"We cannot scale the input units {self.char()}. Please gather the scale factor [%d] in a "
        #                     f"second "
        #                    'output',
        #        char(vi), scale);
        # end

        return v

    def factor(self):

        u = self
        numi = [x > 0 for x in u.exps]
        deni = [x < 0 for x in u.exps]

        den = Unit()
        if any(deni):
            den.strs = [u.strs[i] for i in numpy.where(deni)[0]]
            den.exps = [abs(u.exps[i]) for i in numpy.where(deni)[0]]
            den.vals = [u.vals[i] for i in numpy.where(deni)[0]]

        num = Unit()
        if any(numi):
            num.strs = [u.strs[i] for i in numpy.where(numi)[0]]
            num.exps = [u.exps[i] for i in numpy.where(numi)[0]]
            num.vals = [u.vals[i] for i in numpy.where(numi)[0]]

        return (num, den)

    def toLabel(self):

        u = self
        num, den = u.factor()

        numstr = num.formatUnit()
        denstr = den.formatUnit()

        if not denstr:
            str = "$\\left[" + numstr + " \\right]$"
        else:
            if not numstr:
                str = "$\\left[1/" + denstr + " \\right]$"
            else:
                str = "$\\left[\\frac{" + numstr + "}{" + denstr + "} \\right]$"

        return str

    def formatUnit(self):

        u = self
        s = ""
        kk = 0
        for st in u.strs:
            prefix = Unit.prefixForVal(u.vals[kk])

            if u.exps[kk] == 0.5:
                s = s + "\\,{\\sqrt{\\mathrm{" + prefix + u.strs[kk] + "}}}"
            elif u.exps[kk] == 1:
                s = s + "\\,{\\mathrm{" + prefix + u.strs[kk] + "}}"
            elif u.exps[kk] > 0:
                [n, d] = rat(u.exps[kk])

                if d == 1:
                    s = (
                        s
                        + "\\,{\\mathrm{"
                        + prefix
                        + u.strs[kk]
                        + "}}^{"
                        + str(n)
                        + "}"
                    )
                else:
                    s = (
                        s
                        + "\\,{\\mathrm{"
                        + prefix
                        + u.strs[kk]
                        + "}}^{"
                        + str(n)
                        + "/"
                        + str(d)
                        + "}"
                    )

            kk += 1
        return s

    # ----------------------------------------------------
    # Public Class Methods
    # ----------------------------------------------------

    @classmethod
    def _siForUnit(cls, u, exceptions):

        # output == input in default case
        s = u
        scale_factor = 1
        if s in exceptions:
            return s, scale_factor

        e = 1.60217648740e-19  # Elementary charge
        Na = 6.02214129e23
        # Avogadro's number

        if u == "rad":
            s = "m m^-1"
        elif u == "sr":
            s = "m^2 m^-2"
        elif u == "Hz":
            s = "s^-1"
        elif u == "N":
            s = "m s^-2 kg"
        elif u == "Pa":
            s = "m^-1 kg s^-2"
        elif u == "J":
            s = "m^2 kg s^-2"
        elif u == "W":
            s = "m^2 kg s^-3"
        elif u == "C":
            s = "A s"
        elif u == "V":
            s = "m^2 kg s^-3 A^-1"
        elif u == "F":
            s = "m^-2 kg^-1 s^4 A^2"
        elif u == "Ohm":
            s = "m^2 kg s^-3 A^-2"
        elif u == "S":
            s = "m^-2 kg^-1 s^3 A^2"
        elif u == "Wb":
            s = "m^2 kg s^-2 A^-1"
        elif u == "T":
            s = "s^-2 A^-1 kg"
        elif u == "H":
            s = "m^2 kg s^-2 A^-2"
        elif u == "degC":
            s = "K"
        elif u == "Bq":
            s = "s^-1"
        elif u == "eV":
            s = "m^2 kg s^-2"
            scale_factor = e
        elif u == "e":
            s = "C"
            scale_factor = e
        elif u == "bar":
            s = "m^-1 kg s^-2"
            scale_factor = 1e5
        elif u == "l" or u == "L":
            s = "m^3"
            scale_factor = 1e-3
        elif u == "amu":
            s = "kg"
            scale_factor = 1000 / Na
        elif u == "ly":
            s = "m"
            scale_factor = 9460730472580800
        elif u == "au" or u == "AU":
            s = "m"
            scale_factor = 149597870700
        elif u == "pc":
            s = "m"
            scale_factor = 3.0856776e16
        elif u == "deg":
            s = "m m^-1"
            scale_factor = numpy.pi / 180
        elif u == "sccm":
            s = "m^3 s^-1"
            scale_factor = 1e-6 / 60
        elif u == "Count":
            s = ""
            scale_factor = 1
        elif u == "min":
            s = "s"
            scale_factor = 60
        elif u == "h":
            s = "s"
            scale_factor = 3600
        elif u == "d" or u == "D":
            s = "s"
            scale_factor = 86400
        elif u == "cycles":
            s = "m m^-1"
            scale_factor = 2 * numpy.pi

        return s, scale_factor

    @classmethod
    def supportedUnits(cls):
        return (
            "",
            "m",
            "kg",
            "s",
            "A",
            "K",
            "mol",
            "cd",
            "rad",
            "deg",
            "sr",
            "Hz",
            "N",
            "Pa",
            "J",
            "W",
            "C",
            "V",
            "F",
            "Ohm",
            "S",
            "Wb",
            "T",
            "H",
            "degC",
            "Count",
            "arb",
            "Index",
        )

    @classmethod
    def supportedPrefixes(cls):
        return (
            "y",
            "z",
            "a",
            "f",
            "p",
            "n",
            "u",
            "m",
            "c",
            "d",
            "",
            "da",
            "h",
            "k",
            "M",
            "G",
            "T",
            "P",
            "E",
            "Z",
            "Y",
        )

    @classmethod
    def supportedPrefixValues(cls):
        return (
            1e-24,
            1e-21,
            1e-18,
            1e-15,
            1e-12,
            1e-9,
            1e-6,
            1e-3,
            1e-2,
            1e-1,
            1,
            10,
            100,
            1000,
            1e6,
            1e9,
            1e12,
            1e15,
            1e18,
            1e21,
            1e24,
        )

    @classmethod
    def valForPrefix(cls, prefix):
        """
        Returns the value associated with the specified prefix. If the prefix is
        not one of the recognized prefixes, then None is returned.

        Example:
                    val = valForPrefix("n") # returns 1e-9

        """
        prefixes = Unit.supportedPrefixes()
        vals = Unit.supportedPrefixValues()
        try:
            idx = prefixes.index(prefix)
            return vals[idx]
        except:
            return None

    # ----------------------------------------------------
    # Private Class Methods
    # ----------------------------------------------------

    @classmethod
    def prefixForVal(cls, val):
        """
        Returns the prefix associated with the specified value. If the value is not
        one of the recognized prefix values, then None is returned.

        Example:
                    prefix = prefixForVal(1e-12) # returns 'n'

        """
        prefixes = Unit.supportedPrefixes()
        vals = Unit.supportedPrefixValues()
        try:
            idx = vals.index(val)
            return prefixes[idx]
        except:
            return None

    @classmethod
    def parseUnitExpression(cls, expression):
        """
        Parse a unit expression into a tuple of unit strings, exponents and values.

        """
        # print "Parsing expression [" + expression + "]"
        ustrs = []
        uexps = []
        uvals = []
        # Handle the output of char(unit)
        ustr = expression.replace("[", " ").replace("]", " ").strip()
        # split on whitespace or operator
        expr_unit = "([1a-zA-Z]+)"
        expr_frac = "([+-]?[0-9]*(\.[0-9]+)?(/-?[0-9]+)?)"
        expr = " *" + expr_unit + "(\^(\(" + expr_frac + "\)|" + expr_frac + "))* *"
        e = re.compile(expr)
        ops = re.split(expr, ustr)  # strtrim(regexp(ustr, expr, 'split'));
        ops = ops[0 :: e.groups + 1]

        # go over each match
        itr = re.finditer(expr, ustr)  # strtrim(regexp(ustr, expr, 'match'));
        idx = 0
        for match in itr:
            tk = match.group(0)
            op = ops[idx]

            if tk == "1":
                pass
            else:
                u2str, u2exp, u2val = Unit.parseUnitString(tk)

                if op == "" or op == "*":
                    ustrs.append(u2str)
                    uexps.append(u2exp)
                    uvals.append(u2val)
                elif op == "/":
                    ustrs.append(u2str)
                    uexps.append(-u2exp)
                    uvals.append(u2val)
                else:
                    raise InvalidOperatorException(
                        "The unit expression contains an unsupported operator ["
                        + op
                        + "]"
                    )

            idx += 1

        return ustrs, uexps, uvals

    @classmethod
    def parseUnitString(cls, term):
        """
        Parse a single unit string into its component string, exponent and value.

        Returns a tuple.
        Example:

                ustr, exp, val = parseUnitString('mm^2')

                ustr == 'm'
                exp  == 2
                val  == 1e-3

        """
        # print "Parsing " + term
        # get exponent (everything after a ^)
        parts = re.split("\^", term.strip())
        if len(parts) == 2:
            exp = Fraction(parts[1].replace("(", "").replace(")", ""))
        else:
            exp = 1

        # check for prefix (first character)
        us = parts[0]
        if (
            len(us) > 1
            and us[0] in Unit.supportedPrefixes()
            and us[1:] in Unit.supportedUnits()
        ):
            val = Unit.valForPrefix(us[0])
            ustr = us[1:]
        elif (
            len(us) > 2
            and us[0:2] in Unit.supportedPrefixes()
            and us[2:] in Unit.supportedUnits()
        ):
            val = Unit.valForPrefix(us[0:2])
            ustr = us[2:]
        else:
            val = 1
            ustr = us

        return ustr, float(exp), float(val)

    # ----------------------------------------------------
    # Methods
    # ----------------------------------------------------

    def simplify(self, *exceptions):
        """
        Simplify the unit as much as possible. The original unit is left untouched and the
        method returns the simplified unit.

        Example:
                    us = u.simplify()
        """

        # setup
        supportedExps = r_[-24:-2:3, -2:3:1, 3:25:3]
        remain_val = 1

        # get a list of unique unit strings in this unit which are
        # not in the exceptions list
        strs = []
        [strs.append(s) for s in self.strs if s not in exceptions and s not in strs]

        # loop over these unique unit strings
        units = []
        for us in strs:
            # sum all exponents for units with this string
            matches = [i for (i, val) in enumerate(self.__strs) if val == us]
            vals = array([self.__vals[i] for i in matches])
            exps = array([self.__exps[i] for i in matches])
            exp = sum(exps)
            if exp == 0:
                # the unit is cancelled but we need to keep the prefixes
                lvals = [math.log10(val) for val in vals]
                remain_val *= pow(10, sum(lvals * exps))
                continue

            vlog10 = numpy.vectorize(math.log10)
            n, d = rat(sum(vlog10(vals) * exps / exp))

            if d != 1 or n not in supportedExps:
                # The value is not a supported prefix -> Don't simplify
                continue

            vals = eval("1e" + str(n))
            exps = exp

            newUnit = Unit([us], [exps], [vals])
            units.append(newUnit)

        # if we have no units left, return an empty unit
        if len(units) == 0:
            return Unit()

        # combine the simplified units now
        uout = units[0].combine(*units[1:])

        if remain_val != 1 and len(uout.vals) >= 1:
            # It might be that the units are canceled out but not the prefixes
            # For example: 'mm m^-1 Hz'
            # Add in this case the prefix to the remaining unit
            # Result: 'mHz'

            v = uout.vals[0]
            e = uout.exps[0]
            n, d = rat((math.log10(v) * e + math.log10(remain_val)) / e)
            uout.vals[0] = eval("1e" + str(n))

            # try to simplify again
            uout.simplify(*exceptions)

        else:
            # do nothing
            pass

        # combine the units from the exception list
        for s in exceptions:
            uout.combine(self.extract(s))

        return uout

    def extract(self, us):
        """
        Extracts the first occurrence of the specified unit from the compound unit.
        """

        for s, e, v in zip_longest(self.__strs, self.__exps, self.__vals):
            if s == us:
                return Unit([s], [e], [v])

        return Unit()

    def combine(self, *us):
        """
        Combine units together (mulitply).

        """

        if len(us) == 0:
            return self

        uout = self.deepcopy()
        for u in us:
            uout.__strs.append(*u.strs)
            uout.__exps.append(*u.exps)
            uout.__vals.append(*u.vals)

        return uout

    def explode(self):
        """
        Returns a list of unit objects, one for each of the elemental units in the unit.
        """
        l = []
        for s, e, v in zip_longest(self.__strs, self.__exps, self.__vals):
            u = Unit([s], [e], [v])
            l.append(u)

        return l

    def isEmpty(self):
        """
        Returns true if this is an empty unit
        """
        return len(self.__strs) == 0

    def display(self):
        "Prints a string representation of this Unit to the terminal."
        print(self.char())

    def char(self):
        """
        Returns a character representation of the unit. Equivalent to using repr().
        The returned string can be evaluated by the Unit constructor.

        Example:

                u1 = Unit('m s^-1')
                u2 = Unit(u1.char())

                u1 == u2

        """
        return repr(self)

    def deepcopy(self):
        "Returns a deep copy of the MethodInfo object"
        return copy.deepcopy(self)

    # ----------------------------------------------------
    # Overrides
    # ----------------------------------------------------

    def __deepcopy__(self, memo):
        return Unit(self.strs, self.exps, self.vals)

    def __eq__(self, utest):
        """
        Returns true if the units have the same strings, exponents and values.
        The order of the individual units doesn't matter.
        """

        unitsA = self.simplify().explode()
        unitsB = utest.simplify().explode()

        if len(unitsA) != len(unitsB):
            return False

        for ua in unitsA:
            matched = False
            for ub in unitsB:
                if ua.strs == ub.strs and ua.exps == ub.exps and ua.vals == ub.vals:
                    matched = True

            if not matched:
                return False

        return True

    def __repr__(self):
        """
        Returns an evaluable string representation of a unit.
        """
        if len(self.strs) == 0:
            return "[]"

        # print "Generating rep for " + str(self)
        sout = ""
        for kk in range(len(self.strs)):
            s = self.__strs[kk]
            e = self.__exps[kk]
            v = self.__vals[kk]
            if e != 0:
                prefix = Unit.prefixForVal(v)
                n, d = rat(e)
                if d == 1:
                    if e != 1:
                        sout += "[" + prefix + s + "^(" + "%g" % e + ")]"
                    else:
                        sout += "[" + prefix + s + "]"

                else:
                    sout += "[" + prefix + s + "^(" + str(n) + "/" + str(d) + ")]"

            else:
                sout += "[]"

        return sout

    def __str__(self):
        s = "-------- Unit ---------\n"
        s += "strs: " + str(self.strs) + "\n"
        s += "exps: " + str(self.exps) + "\n"
        s += "vals: " + str(self.vals) + "\n"
        s += "\n-----------------------------"
        return s

    # ----------------------------------------------------
    # properties
    # ----------------------------------------------------

    # strs
    @property
    def strs(self):
        return self.__strs

    @strs.setter
    def strs(self, strs):
        if not isinstance(strs, type([])):
            raise WrongDataTypeException(
                "The strs parameter must be a list of strings."
            )

        for s in strs:
            if not isinstance(s, type("")):
                raise WrongDataTypeException("Each item in the list must be a string.")

        if len(strs) != len(self.__exps) and len(self.__exps) > 0:
            raise WrongSizeException(
                "The number of elements in the string list should match the number of elements in the exps list"
            )

        self.__strs = strs

    # exps
    @property
    def exps(self):
        return self.__exps

    @exps.setter
    def exps(self, exps):
        if not isinstance(exps, type([])):
            raise WrongDataTypeException(
                "The exps parameter must be a list of numbers."
            )

        for e in exps:
            if not isinstance(e, (int, float)):
                raise WrongDataTypeException(
                    "Each item in the list must be a real number."
                )

        if len(exps) != len(self.__strs) and len(self.__strs) > 0:
            raise WrongSizeException(
                "The number of elements in the exponent list ("
                + str(len(exps))
                + ") should match the number of elements in the strs list ("
                + str(len(self.__strs))
                + ")"
            )

            # make sure all values are float
        exps = [float(val) for val in exps]
        self.__exps = exps

    # vals
    @property
    def vals(self):
        return self.__vals

    @vals.setter
    def vals(self, vals):
        if not isinstance(vals, type([])):
            raise WrongDataTypeException(
                "The vals parameter must be a list of numbers."
            )

        for e in vals:
            if not isinstance(e, (int, float)):
                raise WrongDataTypeException("Each item in the list must be a number.")

        if len(vals) != len(self.__strs) and len(self.__strs) > 0:
            raise WrongSizeException(
                "The number of elements in the vals list should match the number of elements in the strs list"
            )

        self.__vals = vals
