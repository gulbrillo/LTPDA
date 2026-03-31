% Test the procinfo is [] by default.
function res = test_procinfo(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    obj = feval(utp.className);
    assert(isnumeric(obj.procinfo));
    assert(isempty(obj.procinfo));
    res = sprintf('%s has a valid procinfo', class(obj));
  end
    
end