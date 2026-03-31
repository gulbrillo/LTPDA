% TEST_GETINFO tests getting the method info from the method.
function res = test_getInfo(varargin)
  
  utp = varargin{1};
  
  % Method name
  methodName = utp.methodName;
  
  % Method class
  methodClass = utp.className;
  
  % Get method info
  ii = feval([methodClass '.getInfo'], methodName);
  
  % Perform checks
  assert(isa(ii, 'minfo'), 'getInfo should return an minfo object');
  assert(strcmp(ii.mname, methodName), 'The minfo object should have the method name %s', methodName);
  assert(strcmp(ii.mclass, methodClass), 'The minfo object should have the method class %s', methodClass);
  assert(strcmp(ii.mpackage, utp.module), 'The minfo object should have the module %s', utp.module);
  assert(~isempty(ii.mversion), 'The minfo should not have an empty mversion string');
  assert(numel(ii.sets) == numel(ii.plists), 'The minfo should have the same number of sets as plists');
  
  % Return result message
  res = 'Performed getInfo tests';
end
% END
