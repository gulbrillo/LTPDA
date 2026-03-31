% Test the plotinfo is [] by default.
function res = test_plotinfo(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    obj = feval(utp.className);
    assert(isnumeric(obj.plotinfo));
    assert(isempty(obj.plotinfo));
    res = sprintf('%s has a valid plotinfo', class(obj));
  end
    
end