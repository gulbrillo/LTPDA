% Test the copy() method works.
function res = test_copy(varargin)
  
  utp = varargin{1};
  
  % get test data
  data = utp.getTestData;
  if ~isempty(data)
    % shallow copy
    c = copy(data, 0);
    assert(isequal(c, data));
    % deep copy
    c = copy(data, 1);
    % The deep copy should not be the same object. At least the UUID
    % changes.
%     assert(c~=data);
    % Check with the appropriate exceptions
%     LTPDAprefs('Display', 'verboseLevel', 2);
    assert(isequal(c, data, utp.configPlist));
%     LTPDAprefs('Display', 'verboseLevel', -1);
  end
  
  res = sprintf('%s/copy seems to work', class(data));
end
