% Test the setting the name works.
function res = test_setName(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    obj = feval(utp.className);
    name = 'a nice name';
    obj.setName(name);
    assert(ischar(obj.name));
    assert(strcmp(name, obj.name));
    res = sprintf('%s/setName works', class(obj));
  end
    
end