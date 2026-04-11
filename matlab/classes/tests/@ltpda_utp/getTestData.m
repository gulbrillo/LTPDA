% GETTESTDATA returns the testData array or an empty object of the correct
% class if testData is empty.
function data = getTestData(utp)
  if isempty(utp.testData)
    data = feval(utp.className);
  else
    data = utp.testData;
  end
end