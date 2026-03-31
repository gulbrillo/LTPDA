% Test the name is 'None' by default.
function res = test_name(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    obj = feval(utp.className);
    assert(strcmpi(obj.name, ''));
    res = sprintf('%s has a valid name', class(obj));
  end
    
end