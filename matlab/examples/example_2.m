% A test script for the AO implementation.
%
% M Hewitson 08-02-07
%
% $Id$
%
function example_2()
  
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 100;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'randn(size(t))');
  
  a1 = ao(pl);
  a2 = ao(pl);
  a3 = ao(pl);
  a4 = ao(pl);
  a5 = ao(pl);
  
  % Subtract two data
  a6 = a5 - a4;
  a6.setName;
  
  % Make LPSD of each
  
  % Window function
  w = specwin('Kaiser', 1000, 250);
  
  % parameter list for lpsd
  pl = plist('Kdes', 100, 'Lmin', 10, 'Jdes', 1000, 'Win', w);
  
  % use lpsd
  a7  = lpsd(a1, pl); a7.setName;
  a8  = lpsd(a2, pl); a8.setName;
  a9  = lpsd(a3, pl); a9.setName;
  a10 = lpsd(a6, pl); a10.setName;
  
  % some manipulation and plot
  a11 = a7+a8;
  a12 = a9.*a10;
  a13 = a11./a12;
  a14 = sqrt(a13);
  a15 = a14.^3 ./ a13;
  
  iplot(a15)
  
  save(a15, 'a15.xml');
  
  % Reproduce from history
  
  a_out = rebuild(a15);
  
  % the last object is always a1
  iplot(a_out)
  
  close all
end
