% Test the display() method returns a non-empty string.
function res = test_display(varargin)
  
  utp = varargin{1};
  
  % get test data
  data = utp.getTestData;
  for kk=1:numel(data)
    d = data(kk);
    txt = disp(d);
    assert(iscell(txt));
    assert(~isempty(txt));
  end
  res = sprintf('%s/char seems to work', class(data));
  
end