% PRINTFAILURESSTRING returns a string describing the test failures.
%

function res = printFailuresString(urp)
  res = sprintf('-------- Failures ----------\n\n');
  for kk=1:numel(urp.results)
    r = urp.results(kk);
    if ~r.passed
      res = [res sprintf('%s/%s - failed \n    - %s\n', r.testClass, r.testMethod, r.message)];
    end
  end  
  res = [res sprintf('\n\n----------------------------\n')];
end