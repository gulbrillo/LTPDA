
function test_isequal()
  
  %% This script test all parts of ltpda_obj/isequal
  
  vl = LTPDAprefs.verboseLevel();
  LTPDAprefs('Display', 'verboseLevel', -1);
  %% Check a ltpda_obj property with 'double'
  
  dNum1 = pi;
  dNum2 = pi*1e10;
  dNum3 = pi*1e100;
  dNum4 = pi*1e-10;
  dNum5 = pi*1e-100;
  dNum6 = 1;
  
  % Check empty array of double
  run_test([]);
  run_test(ones(1,0));
  % Check vector of double objects
  run_test([dNum1 dNum2 dNum3]);
  % Check matrix of double objects
  run_test([dNum1 dNum2 dNum3; dNum4 dNum5 dNum6]);
  % Check the negative case
  m1 = [dNum1 dNum2 dNum3; dNum4 dNum5 dNum6];
  m2 = [dNum1 dNum2 dNum4; dNum4 dNum5 dNum6];
  run_negative_test(m1, m2)
  
  %% Check a ltpda_obj property with 'integer'
  
  iNum1 = int64(0);
  iNum2 = int64(inf);
  iNum3 = int64(nan);
  iNum4 = int64(2^44+4);
  iNum5 = int64(5);
  iNum6 = int64(2.123);
  
  % Check empty array of integer
  run_test(int64([]));
  run_test(int64(ones(1,0)));
  % Check vector of integer objects
  run_test([iNum1 iNum2 iNum3]);
  % Check matrix of integer objects
  run_test([iNum1 iNum2 iNum3; iNum4 iNum5 iNum6]);
  % Check the negative case
  m1 = [iNum1 iNum2 iNum3; iNum4 iNum5 iNum6];
  m2 = [iNum1 iNum2 iNum4; iNum4 iNum5 iNum6];
  run_negative_test(m1, m2)
  
  %% Check a ltpda_obj property with 'boolean'
  
  bNum1 = true;
  bNum2 = false;
  
  % Check empty array of boolean
  run_test(true(0,0));
  run_test(true(0,1));
  % Check vector of boolean objects
  run_test([bNum1 bNum2 bNum2]);
  % Check matrix of boolean objects
  run_test([bNum1 bNum2 bNum2; bNum1 bNum1 bNum2]);
  % Check the negative case
  m1 = [bNum1 bNum2 bNum2; bNum1 bNum1 bNum2];
  m2 = [bNum1 bNum2 bNum2; bNum1 bNum2 bNum2];
  run_negative_test(m1, m2)
  
  %% Check a ltpda_obj property with 'complex' numbers
  
  cNum1 = complex(8);
  cNum2 = complex(8, 5);
  cNum3 = complex(0, 5);
  cNum4 = randn + randn*1i;
  cNum5 = complex(randn*1e123, randn*1e123);
  cNum6 = complex(randn*1e-23, randn*1e-23);
  
  % Check empty array of complex
  run_test(complex([]));
  run_test(complex(1, ones(1,0)));
  % Check vector of complex objects
  run_test(int64([cNum1 cNum2 cNum3]));
  % Check matrix of complex objects
  run_test([cNum1 cNum2 cNum3; cNum4 cNum5 cNum6]);
  % Check the negative case
  m1 = [cNum1 cNum2 cNum3; cNum4 cNum5 cNum6];
  m2 = [cNum1 cNum2 cNum4; cNum4 cNum5 cNum6];
  run_negative_test(m1, m2)
  
  %% Check a ltpda_obj property with 'symbolic' objects
  
  sym1 = sym('m*a');
  sym2 = sym(123);
  sym3 = sym('x', 'real');
  sym4 = sym(1/3, 'f');
  sym5 = sym('3*a+8');
  sym6 = sym(1/3, 'e');
  
  % Check empty array of symbolic objects
  run_test(sym([]));
  run_test(sym(ones(1,0)));
  % Check vector of symbolic objects
  run_test([sym1 sym2 sym3]);
  % Check matrix of symbolic objects
  run_test([sym1 sym2 sym3; sym4 sym5 sym6]);
  % Check the negative case
  m1 = [sym1 sym2 sym3; sym4 sym5 sym6];
  m2 = [sym1 sym2 sym4; sym4 sym5 sym6];
  run_negative_test(m1, m2)
  
  %% Check a ltpda_obj property with 'cell' objects
  
  complexCell = getCell();
  
  % Check empty array of cell objects
  run_test({});
  run_test(cell(0,1));
  % Check vector of cell objects
  run_test(complexCell);
  % Check matrix of cell objects
  run_test(reshape(complexCell(1:6), 3, 2));
  % Check the negative case
  m1 = getCell();
  m2 = getCell();
  m2{3} = 1;
  run_negative_test(m1, m2)
  
  %% Check a ltpda_obj property with 'struct' objects
  
  % Check empty array of struct objects
  run_test(struct([]));
  run_test(struct('a', {}, 'b', {}));
  % Check struct object
  run_test(getStruct);
  % Check vector of struct objects
  run_test([getStruct, getStruct, getStruct]);
  % Check matrix of struct objects
  run_test([getStruct, getStruct, getStruct; getStruct, getStruct, getStruct]);
  % Check the negative case
  m1 = getStruct();
  m2 = getStruct();
  m2.i = {'a', 2};
  run_negative_test(m1, m2)
  
  %% Check 'plist' objects with a different order of the param objects.
  
  param1 = param('a', 1);
  param2 = param('b', 2);
  param3 = param('c', 3);
  param4 = param('d', 4);
  param5 = param('e', 5);
  param6 = param('f', 6);
  
  pl1 = plist([param1, param2, param3, param4, param5, param6]);
  pl2 = plist([param6, param5, param4, param3, param2, param1]);
  
  fprintf('Checking PLISTs with a different order');
  cprintf('hyper', 'different order ');
  fprintf('of parameter objects\n');
  
  assert(isequal(pl1, pl2, getExceptionPlist()), 'The test for PLISTs with different order of the parameter objects failed.');
  
  %% Check a ltpda_obj property with 'plist' objects
  
  param1 = param;
  param2 = param('a', 1);
  param3 = param('b', 2);
  param4 = param('c', 3);
  param5 = param('d', 4);
  param6 = param('e', 5);
  
  pl1 = plist([param1, param3]);
  pl2 = plist([param4, param5, param6]);
  pl3 = plist([param2, param5]);
  pl4 = plist();
  pl5 = plist([param1 param2 param3 param4 param5]);
  pl6 = plist([param1 param2 param3 param4 param5 param6]);
  
  % Check empty array of plist objects
  run_test(plist.initObjectWithSize(0,0));
  run_test(plist.initObjectWithSize(0,1));
  % Check plist objects (The order of the parameter objects shouldn't matter)
  run_test(plist([param1 param2 param3 param4 param5 param6]), plist([param6 param5 param4 param3 param2 param1]));
  % Check vector of plist objects
  run_test([pl1 pl2 pl3]);
  % Check matrix of plist objects
  run_test([pl1 pl2 pl3; pl4 pl5 pl6]);
  % Check the negative case
  m1 = [pl1 pl2 pl3; pl4 pl5 pl6];
  m2 = [pl1 pl2 pl4; pl4 pl5 pl6];
  run_negative_test(m1, m2)
  
  %% Check that the value of a param object is a numeric
  run_param_test(magic(8))
  run_negative_param_test(magic(8), 1)
  
  %% Check that the value of a param object is a boolean
  run_param_test([true false true])
  run_negative_param_test([true false true], [true false false])
  
  %% Check that the value of a param object is a ltpda_obj
  run_param_test(ao(8), ao(8))
  run_negative_param_test(ao(8), ao(9))
  
  %% Check that the value of a param object is a struct
  s1 = struct('a', 1, 'b', ao(8));
  s2 = struct('a', 1, 'b', ao(8));
  s3 = struct('a', 1, 'b', 2);
  run_param_test(s1, s2)
  run_negative_param_test(s1, s3)
  
  %% Check that the value of a param object is a cell
  c1 = {'a', 1, 'b', ao(8)};
  c2 = {'a', 1, 'b', ao(8)};
  c3 = {'a', 1, 'b', 2};
  run_param_test(c1, c2)
  run_negative_param_test(c1, c3)
  
  %% Check that a param object have properties
  p1 = param('a', 1);
  p2 = param('a', 1);
  p1.setProperty('a', 1);
  p1.setProperty('b', ao(8));
  p2.setProperty('a', 1);
  p2.setProperty('b', ao(8));
  fprintf('Checking a parameter object with');
  cprintf('hyper', 'properties\n');
  assert(isequal(plist(p1), plist(p2), getExceptionPlist()), 'The test for parameter objects with properties failed.');
  assert(~isequal(plist(p1), plist(p2)), 'The negative test for parameter objects with properties failed.');
  
  p1 = param('a', 1);
  p2 = param('a', 1);
  p1.setProperty('a', 1);
  p1.setProperty('b', ao(8));
  p2.setProperty('a', 1);
  fprintf('Checking a parameter objects with not the same number of');
  cprintf('hyper', 'properties\n');
  assert(~isequal(plist(p1), plist(p2)), 'The negative test for parameter objects with properties failed.');
  
  p1 = param('a', 1);
  p2 = param('a', 1);
  p2.setProperty('a', 1);
  fprintf('Checking a parameter objects which one has and the other hasn''t ');
  cprintf('hyper', 'properties\n');
  assert(~isequal(plist(p1), plist(p2)), 'The negative test for parameter objects with properties failed.');
  
  p1 = param('a', 1);
  p2 = param('a', 1);
  p1.setProperty('a', 1);
  fprintf('Checking a parameter objects which one has and the other hasn''t ');
  cprintf('hyper', 'properties\n');
  assert(~isequal(plist(p1), plist(p2)), 'The negative test for parameter objects with properties failed.');
  
  %% Check a ltpda_obj property with 'plotinfo' objects
  warning('!!! Please add tests for ''plotinfo'' objects and check especially that plotinfo/isequal doesn''t check all properties.');
  
  %% Check a ltpda_obj property with 'unit' objects
  warning('!!! Please add tests for ''unit'' objects.');
  
  %% Check for a cell that the inside ltpda_obj is not equal
  c1 = {1, 'text', ao(8), [true false]};
  c2 = {1, 'text', ao(9), [true false]};
  run_negative_test(c1, c2)
  
  %% Check for a cell that the inside structure is not equal
  c1 = {1, 'text', struct('a', 1, 'b',  2), [true false]};
  c2 = {1, 'text', struct('a', 2, 'b',  2), [true false]};
  run_negative_test(c1, c2)
  
  %% Check for a cell that the inside cell is not equal
  c1 = {1, 'text', {1 2 'asd'}, [true false]};
  c2 = {1, 'text', {1 2 'dsa'}, [true false]};
  run_negative_test(c1, c2)
  
  %% Check for a cell that the inside numeric is not equal
  c1 = {1, 'text', [1 2 3; 4 5 6; 7 8 9], [true false]};
  c2 = {1, 'text', [1 2 3; 4 5 6; 5 8 9], [true false]};
  run_negative_test(c1, c2)
  
  %% Check for a cell that the inside numeric with a tolerance is not equal
  warning('!!! Please add a test with a tolerance');
  
  %% Check for a cell that the inside symbolic is not equal
  c1 = {1, 'text', sym('a'), [true false]};
  c2 = {1, 'text', sym('aa'), [true false]};
  run_negative_test(c1, c2)
  
  %% Check for a struct the number of fields
  c1 = {1 2 3 4 5};
  c2 = {1 2 3 4};
  run_negative_test(c1, c2)
  
  %% Check that one property is a struct and the other one not.
  c1 = {1 'text'};
  c2 = ones(3,2);
  run_negative_test(c1, c2)
  
  %% Check for a struct that a field with a different ltpda_obj is not equal
  s1 = struct('a', 'text', 'b', magic(8), 'check', ao(8), 'c', [true false]);
  s2 = struct('a', 'text', 'b', magic(8), 'check', ao(9), 'c', [true false]);
  run_negative_test(s1, s2)
  
  %% Check for a struct that a field with a different structure is not equal
  s1.check = struct('a', 1, 'b', 2);
  s2.check = struct('a', 1, 'b', 3);
  run_negative_test(s1, s2)
  
  %% Check for a struct that a field with a different cell is not equal
  s1.check = {'a', 1, 'b'};
  s2.check = {'a', 2, 'b'};
  run_negative_test(s1, s2)
  
  %% Check for a struct that a field with a different numeric is not equal
  s1.check = [1 2 3; 4 5 6; 7 8 9];
  s2.check = [1 2 3; 4 4 6; 7 8 9];
  run_negative_test(s1, s2)
  
  %% Check for a struct that a field with a different numeric with a tolerance is not equal
  warning('!!! Please add a test with a tolerance');
  
  %% Check for a struct that a field with a different symbolic is not equal
  s1.check = [sym('a') sym('aa') sym('aaa')];
  s2.check = [sym('a') sym('a') sym('aaa')];
  run_negative_test(s1, s2)
  
  %% Check for a struct the number of fields
  s1 = struct('a', 1, 'b', 2, 'c', 3);
  s2 = struct('a', 1, 'b', 2);
  run_negative_test(s1, s2)
  
  %% Check that one property is a struct and the other one not.
  s1 = struct('a', 1, 'b', 2, 'c', 3);
  s2 = {1, 'text'};
  run_negative_test(s1, s2)
  
  %% Check for different input objects
  fprintf('Checking command with different');
  cprintf('hyper', 'type of inputs\n');
  assert(~isequal(ao(8), pzmodel(), getExceptionPlist()), 'The negative test for different inputs failed because the objects are equal.');
  
  %% Check for different number of input objects
  fprintf('Checking command with different');
  cprintf('hyper', 'number of inputs\n');
  assert(~isequal([ao(1) ao(2) ao(3)], [ao(1) ao(2)], getExceptionPlist()), 'The negative test for different number of input objects failed because the objects are equal.');
  
  %% Check that isequal uses the tolerance
  warning('!!! Please add a test with a tolerance');
  
  %% Set the verbose Level back
  LTPDAprefs('Display', 'verboseLevel', vl);
  
end

function c = getCell()
  [dNum, iNum, bNum, cNum, sNum, str, strArray, emptyCell, ltpdaObj, simpleCell, simpleStruct] = getDataTypes();
  c = {dNum, iNum, bNum, cNum, sNum, str, strArray, emptyCell, ltpdaObj, simpleCell, simpleStruct};
end

function s = getStruct()
  [dNum, iNum, bNum, cNum, sNum, str, strArray, emptyCell, ltpdaObj, simpleCell, simpleStruct] = getDataTypes();
  s = struct('a', dNum, 'b', iNum, 'c', bNum, 'd', cNum, 'e', sNum, 'f', str, 'g', strArray, 'h', ltpdaObj, 'i', {simpleCell}, 'j', simpleStruct);
end

function [dNum, iNum, bNum, cNum, sNum, str, strArray, emptyCell, ltpdaObj, simpleCell, simpleStruct] = getDataTypes()
  
  % Remember the random stream of the first command so that the random
  % number are always the same.
  persistent stream;
  if isempty(stream)
    stream = RandStream.getGlobalStream();
    if strcmp(stream, 'legacy')
      error('The random stream is in a legacy mode. Please reset the RandStream');
    end
  end
  RandStream.setGlobalStream(RandStream(stream.Type, 'Seed', stream.Seed, 'NormalTransform', stream.NormalTransform));
  
  % define different data types
  dNum = randn(3,2);
  iNum = int64(10*randn(3,2));
  bNum = [false true false; true true false];
  cNum = randn(3,2) + randn(3,2)*1i;
  sNum = sym('A', [3 2]);
  
  str          = 'This is a test string';
  strArray     = char('This', 'is', 'a', 'array', 'of', 'strings');
  
  ltpdaObj = ao(magic(8));
  ltpdaObj.setName();
  ltpdaObj.setDescription('This is a description');
  
  emptyCell    = cell(0,1);
  simpleCell   = {'a', 1};
  simpleStruct = struct('a', 'string', 'b', 2);
end

function run_test(testObjs1, testObjs2)
  
  if nargin < 2
    if isa(testObjs1, 'ltpda_objs')
      testObjs2 = copy(testObjs1, 1);
    else
      testObjs2 = testObjs1;
    end
  end
  
  if isempty(testObjs1)
    log = sprintf('an empty [%dx%d]', size(testObjs1));
  elseif isvector(testObjs1)
    log = sprintf('a vector [%dx%d] of', size(testObjs1));
  else
    log = sprintf('a matrix [%dx%d] of', size(testObjs1));
  end
  clName = class(testObjs1);
  if ~isreal(testObjs1) && isnumeric(testObjs1)
    clName = sprintf('complex %s', clName);
  end
  
  fprintf('Checking a ltpda_obj property with %s', log);
  cprintf('hyper', '%s\n', clName);
  
  m1 = matrix();
  m2 = matrix();
  
  if isa(testObjs1, 'ltpda_obj')
    m1.objs = copy(testObjs1, 1);
    m2.objs = copy(testObjs2, 1);
  else
    m1.objs = testObjs1;
    m2.objs = testObjs2;
  end
  
  assert(isequal(m1, m2, getExceptionPlist()), 'The test with %s %s [%dx%d] failed.', log, clName, size(testObjs1));
end

function run_negative_test(testObjs1, testObjs2)
  
  if isempty(testObjs1)
    log = 'an empty';
  elseif isvector(testObjs1)
    log = 'a vector of';
  else
    log = 'a matrix of';
  end
  clName = class(testObjs1);
  if ~isreal(testObjs1) && isnumeric(testObjs1)
    clName = sprintf('complex %s', clName);
  end
  
  fprintf('Checking the negative test with');
  cprintf('hyper', '%s\n', clName);
  
  n1 = matrix();
  n2 = matrix();
  
  if ~isa(testObjs1, 'ltpda_obj')
    n1.objs = testObjs1;
    n2.objs = testObjs2;
  else
    n1.objs = copy(testObjs1, 1);
    n2.objs = copy(testObjs2, 1);
  end
  
  assert(~isequal(n1, n2, getExceptionPlist()), 'The negative test with %s %s [%dx%d] failed because the objects are equal.', log, class(testObjs1), size(testObjs1));
end

function run_param_test(val1, val2)
  
  if nargin < 2
    if isa(val1, 'ltpda_obj')
      val2 = copy(val1,1);
    else
      val2 = val1;
    end
  end
  
  p1 = param('a', val1);
  p2 = param('a', {2, {'first', val2, 'last'}, 1});
  clName = class(val1);
  
  fprintf('Checking a parameter object with a');
  cprintf('hyper', '%s\n', clName);
  
  assert(isequal(plist(p2), plist(p1), getExceptionPlist()), 'The test for a parameter object with a %s value failed.', clName);
  assert(isequal(plist(p1), plist(p2), getExceptionPlist()), 'The test for a parameter object with a %s value failed.', clName);
end

function run_negative_param_test(val1, val2)
  p1 = param('a', val1);
  p2 = param('a', {2, {'first', val2, 'last'}, 1});
  clName = class(val1);
  
  fprintf('Checking the negative test of a parameter object with a');
  cprintf('hyper', '%s\n', clName);
  
  assert(~isequal(plist(p2), plist(p1), getExceptionPlist()), 'The negative test for a parameter object with a %s value failed because the values are equal.', clName);
  assert(~isequal(plist(p1), plist(p2), getExceptionPlist()), 'The negative test for a parameter object with a %s value failed because the values are equal.', clName);
end

function plout = getExceptionPlist()
  persistent pl;
  if isempty(pl)
    pl = plist('Exceptions', {'methodInvars', 'proctime', 'UUID'});
  end
  plout = pl;
end



