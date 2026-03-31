function make_test_ascii_file(name, Nsecs, fs)

% Make a test ascii file with the name 'name.txt' containing a time-series
% of random noise, N seconds long sampled at fs Hz.
% 
% >> make_test_ascii_file(name, Nsecs, fs)
% 
% M Hewitson 01-02-07
% 
% $Id$
% 

% create test data
t   = linspace(0, Nsecs-1/fs, Nsecs*fs);
x   = randn(1,Nsecs*fs) + 2*sin(2*pi*45.*t);
out = [t;x].';

% Save data as ascii file
filename = sprintf('%s.txt', name);
save(filename, 'out', '-ASCII', '-DOUBLE', '-TABS');
