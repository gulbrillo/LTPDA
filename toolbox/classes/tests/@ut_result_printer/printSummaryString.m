% PRINTSUMMARYSTRING returns a string summarising the tests.
%

function res = printSummaryString(urp)
  
  res = '';
  
  % Summary
  res = [res sprintf('------------------------------------\n')];
  res = [res sprintf('Total # tests:  %d\n', urp.nresults)];
  res = [res sprintf('Tests failed: %d\n', urp.nresults - urp.npassed)];
  res = [res sprintf('------------------------------------\n')];
end