% Test the string method works.
function res = test_string(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    obj = feval(utp.className);
    str = string(obj);
    sobj = eval(str);
    % check that eval(str) creates the same type of object
    assert(isa(sobj, utp.className));    
    res = sprintf('%s/string works', class(obj));
  end
    
end