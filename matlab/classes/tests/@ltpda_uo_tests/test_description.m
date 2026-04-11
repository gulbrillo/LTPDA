% Test the description is '' by default.
function res = test_description(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    obj = feval(utp.className);
    assert(ischar(obj.description));
    assert(isempty(obj.description));
    res = sprintf('%s has a valid description', class(obj));
  end
    
end