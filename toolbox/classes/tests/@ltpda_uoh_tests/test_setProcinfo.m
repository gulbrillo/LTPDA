% Test the setting the procinfo works.
function res = test_setProcinfo(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    obj = feval(utp.className);
    pinfo = plist('test', 123);
    obj.setProcinfo(pinfo);
    pinfo.setDefaultForParam('test', 231);
    % the procinfo should get copied and as such should not be the same
    % plist as the one we input
    assert(~isequal(obj.procinfo, pinfo));
    res = sprintf('%s/setProcinfo works', class(obj));
  end
    
end
