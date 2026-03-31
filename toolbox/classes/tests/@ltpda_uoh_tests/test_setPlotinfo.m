% Test the setting the plotinfo works.
function res = test_setPlotinfo(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    obj = feval(utp.className);
    pinfo = plotinfo(plist('color', 'r'));
    obj.setPlotinfo(pinfo);
    % the plotinfo should get copied and as such should not be the same
    % object as the one we input
    
    % so, change the plot color. If the plotinfo objects are still the same
    % handle, then they will both change.
    obj.setPlotColor('b');
    
    assert(~eq(obj.plotinfo, pinfo));
    res = sprintf('%s/setPlotinfo works', class(obj));
  end
    
end
