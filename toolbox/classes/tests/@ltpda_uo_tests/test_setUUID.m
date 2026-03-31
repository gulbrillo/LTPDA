% Test the setting the UUID works.
function res = test_setUUID(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    obj = feval(utp.className);
    uuid = '123';
    obj.setUUID(uuid);
    assert(ischar(obj.UUID));
    assert(strcmp(uuid, obj.UUID));
    res = sprintf('%s/setUUID works', class(obj));
  end
    
end