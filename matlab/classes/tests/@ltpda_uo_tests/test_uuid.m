% Test the UUID is a non-empty string.
function res = test_uuid(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    obj = feval(utp.className);
    assert(ischar(obj.UUID));
    assert(~isempty(obj.UUID));
    res = sprintf('%s has a valid UUID', class(obj));
  end
    
end