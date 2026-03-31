% Test each constructor works
function res = test_constructor(varargin)
  
  utp = varargin{1};
  
  % empty
  v = ltpda_vector();
  assert(isempty(v.data), 'data field is not empty');
  assert(isempty(v.ddata), 'ddata field is not empty');
  assert(strcmp(v.name, 'Value'), 'default name should be [Value]');
  
  % data
  d = 1:10;
  v = ltpda_vector(d);
  assert(length(v.data) == length(d), 'data has the wrong length');
  assert(size(v.data, 1) == 1, 'data has the wrong shape');
  
  % data, ddata
  d  = 1:10;
  dd = 1;
  v = ltpda_vector(d, dd);
  assert(length(v.data) == length(d), 'data has the wrong length');
  assert(size(v.data, 1) == 1, 'data has the wrong shape');
  assert(length(v.ddata) == length(d), 'ddata has the wrong length');
  
  % data, ddata
  d  = 1:10;
  dd = 1:10;
  v = ltpda_vector(d, dd);
  assert(length(v.data) == length(d), 'data has the wrong length');
  assert(size(v.data, 1) == 1, 'data has the wrong shape');
  assert(length(v.ddata) == length(v.data), 'ddata has the wrong length');
  
  % data, ddata, units
  u = 'm';
  d  = 1:10;
  dd = 1:10;
  v = ltpda_vector(d, dd, u);
  assert(strcmp(char(v.units), '[m]'), 'Units are wrong');
  
  % data, ddata, units
  u = unit('m');
  d  = 1:10;
  dd = 1:10;
  v = ltpda_vector(d, dd, u);
  assert(strcmp(char(v.units), '[m]'), 'Units are wrong');
  
  % data, ddata, units, name
  u = unit('m');
  d  = 1:10;
  dd = 1:10;
  name = 'myVector';
  v = ltpda_vector(d, dd, u, name);
  assert(strcmp(v.name, name), 'name is wrong');
  
  res = 'all constructors work';
  
end