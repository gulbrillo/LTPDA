% TEST_AO_CONSOLIDATE tests the consolidate method of the AO class.
%
% M Hueller 16-01-12
%
%

function test_ao_consolidate
  
  % 1)    Testing case with only one AO
  % 2)    Testing case with more than one AO
  % 2.1)  Testing data with complete overlap
  % 2.2)  Testing data with partial overlap
  
  %% 2.1)  Testing data with complete overlap
  
  %% 2.1.1) Data with no gaps
  % Prepare test data
  myx = 0.1:0.1:100;
  myy = randn(length(myx), 1);
  a1 = ao(plist('xvals', myx, 'yvals', myy, 'fs', 10, 'type', 'tsdata'));
  a1.setName;
  
  isHigh = ao(plist('xvals', a1.x+10, 'yvals', double(a1.y > 0.1), 'fs', a1.fs, 'type', 'tsdata'));
  isHigh.setName;
  
  at = (1 - isHigh).*a1;
  
  pl = plist('times', [10.1 30.5]);
  
  oldaos = [a1, isHigh, at];
  newaos = split(oldaos, pl);
  
  iplot(oldaos)
  iplot(newaos)
  
  % Consolidate the data
  testcons = consolidate(oldaos);
  
  %%  2.1.2) Data with gaps
  % Prepare test data, 10.1 Hz, with missing data here and there
  myx = [1000:1/10.1:1010 1010.3:1/10.1:1080.7 1080.9:1/10.1:1100];
  myy = randn(length(myx), 1);
  a1 = ao(plist('xvals', myx, 'yvals', myy, 'type', 'tsdata'));
  a1.setName;
  
  % Consolidate these data at 10 Hz
  cnpl = plist('fs', 10, ...
    'fixfs_method', 'time', ...
    'interp_method', 'linear');
  b1 = a1.consolidate(cnpl);
  
  % Check the x-axis content
  TOL = 1e-12;
  assert(max(abs(b1.x - (1000 + [0:0.1:99.9]'))) < TOL)
  
  %% Test data
  
  ao1 = ao(plist('type', 'tsdata', ...
    'yvals', sin([0:0.2:100]), ...
    'fs', 0.5, ...
    't0', 10));
  ao2 = ao(plist('type', 'tsdata', ...
    'yvals', sin([0:0.2:100]), ...
    'fs', 0.4, ...
    't0', 12));
  
  c = consolidate(ao1, ao2);
  
  assert(c(1).x(1) - c(1).toffset == 0);
  assert(c(2).x(1) - c(2).toffset == 0);
  assert(c(1).nsecs == c(2).nsecs);
  assert(double(c(1).t0) == 10);
  assert(double(c(2).t0) == 10);
  assert(c(1).fs == 0.5);
  assert(c(2).fs == 0.5);
  
  close all
end



