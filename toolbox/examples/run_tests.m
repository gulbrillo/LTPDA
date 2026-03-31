% Run many tests
%
% M Hewitson 27-04-07
%
%
clear all;


VERSION = '$Id$';

% load list of tests
test_list;

%% Run these tests

nt = 1:length(test_struct);

tstart = now;
results = [];
k = 1;
for n=nt
  ctest = test_struct(n).name;
  % try to run the test only if the file exists
  if exist(ctest, 'file') == 2
    
    disp(' ');
    disp(' ');
    disp('=================================');
    disp('===');
    disp(sprintf('=== Running: %s', ctest));
    disp('===');
    disp('=================================');
    disp(' ');
    disp(' ');
    
    try
      tic
      eval(ctest)
      results(k).test     = ctest;
      results(k).result   = 'pass';
      results(k).duration = toc;
    catch
      l_error = lasterror;
      results(k).test     = ctest;
      results(k).result   = ['fail    Error message: ' strrep(l_error.message, char(10), '  ')];
      results(k).duration = toc;
    end
    close all
  else
    results(k).test     = ctest;
    results(k).result   = 'fail: test file not found';
    results(k).duration = 0;
  end
  k = k + 1;
end
tend = now;

%% Post processing

npassed = 0;
for j=1:length(results)
  r = results(j);
  if strcmp(r.result, 'pass')
    npassed = npassed + 1;
  end
end

%% Write report

% get max test name
maxstr = 0;
for t=1:length(test_struct)
  ctest = test_struct(t).name;
  if length(ctest) > maxstr
    maxstr = length(ctest);
  end
end


v = ver('ltpda');

pth = utils.prog.get_curr_m_file_path(mfilename);

filename = [pth 'test_run_' strrep(strrep(datestr(now), ' ', '_'), ':', '_') '_' computer '.log'];

fd = fopen(filename, 'w+');

fprintf(fd, '%% Test run \n');
fprintf(fd, '%%  \n');
fprintf(fd, '%% Started  %s\n', strrep(datestr(tstart), ' ', '_'));
fprintf(fd, '%% Finished %s\n', strrep(datestr(tend), ' ', '_'));
fprintf(fd, '%%  \n');
fprintf(fd, '%%  \n');
fprintf(fd, '%% writen by %s / %s \n', mfilename, VERSION);
fprintf(fd, '%%  \n');
fprintf(fd, '%%  %d tests run\n', length(test_struct));
fprintf(fd, '%%  %d tests passed\n', npassed);
fprintf(fd, '%%  %d tests failed\n', length(test_struct)-npassed);
fprintf(fd, '%% \n');
fprintf(fd, '%% Tests run on %s with version %s of LTPDA\n', computer, v.Version);
fprintf(fd, '%% \n');
fprintf(fd, '%% \n');
fprintf(fd, '%% Test No  | Test | Execution time [s] | pass/fail \n');
fprintf(fd, '\n');
fprintf(fd, '\n');

for j=1:length(results)
  r = results(j);
  fprintf(fd, '%03d   %s   %06.2f   %s\n', j, utils.prog.strpad(r.test, maxstr), r.duration, r.result);
end


fprintf(fd, '\n');
fprintf(fd, '\n');
fprintf(fd, '%% END \n');

fclose(fd);
edit(filename);

% END