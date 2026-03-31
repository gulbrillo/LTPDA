% TEST_HISTORY tests the method correctly adds history.
function res = test_history(varargin)
  
  utp = varargin{1};
  
  % Method name
  methodName = utp.methodName;
  
  % Method class
  methodClass = utp.className;  
  
  % Apply method
  out = feval(methodName, utp.testData, utp.configPlist);
  
  % Perform checks
  assert(isa(out.hist, 'history'), 'The result of method [%s/%s] should contain a history step', methodClass, methodName);

  % History object
  h = out.hist;
  hpl = h.plistUsed;
  
  assert(isempty(h.methodInfo.sets), 'The sets in the methodInfo of the most recent history step should be empty');
  assert(isempty(h.methodInfo.plists), 'The plists in the methodInfo of the most recent history step should be empty');
  
  assert(strcmp(methodName, h.methodInfo.mname), 'The last history step should be from method [%s]', methodName);
  assert(strcmp(methodClass, h.methodInfo.mclass), 'The last history step should be from method [%s]', methodName);
  
  % The values in the input plist should be the ones used, and therefore
  % should appear in the history plist.
  if ~isempty(utp.configPlist)
    for kk=1:numel(utp.configPlist.params)
      p = utp.configPlist.params(kk);
      valUsed = hpl.find(p.key);
      inputval = p.getVal;
      if isa(inputval, 'ltpda_uoh')
        inputval = inputval.hist;
        assert(isequal(valUsed, inputval, 'proctime', 'UUID', 'context'), 'The user input value of parameter ''%s'' is different to the value in the history plist', p.key);
      else
        assert(isequal(valUsed, inputval), 'The user input value of parameter ''%s'' is different to the value in the history plist', p.key);
      end
    end
  end
  
  % Return result message
  res = 'Performed history tests';
end
% END
