% Test the char() method returns a non-empty string.
function res = test_char(varargin)
  
  utp = varargin{1};
  
  % get test data
  data = utp.getTestData;
  if ~isempty(data)
    for kk=1:numel(data)
      d = data(kk);
      txt = char(d);
      assert(ischar(txt));
      assert(~isempty(txt));
    end
  end
  
  res = sprintf('%s/char seems to work', class(data));
end