% Test the setting the description works.
function res = test_setDescription(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    obj = feval(utp.className);
    desc = 'a nice description';
    obj.setDescription(desc);
    assert(ischar(obj.description));
    assert(strcmp(desc, obj.description));
    res = sprintf('%s/setDescription works', class(obj));
  end
    
end