% PRINTRUNTIMESTRING returns a string listing the run time of the tests.
%

function res = printRuntimeString(varargin)
  
  urp = varargin{1};
  if nargin>1
    limit = varargin{2};
  else
    limit = inf;
  end
  
  % build array of runtimes
  runtimes = zeros(1,numel(urp.results));
  for kk=1:numel(urp.results)
    r = urp.results(kk);
    runtimes(kk) = r.runtime;
  end
  
  % sort array
  [y,idx] = sort(runtimes,'descend');
  results = urp.results(idx);
  
  res = sprintf('-------- Runtime ----------\n\n');
  for kk=1:numel(results)
    r = results(kk);
    res = [res sprintf('%0.3f s - %s/%s\n', r.runtime, r.testClass, r.testMethod)];
    if kk>limit
      break
    end
  end  
  res = [res sprintf('\n\n----------------------------\n')];
end