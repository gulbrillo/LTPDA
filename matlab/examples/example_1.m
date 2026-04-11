% EXAMPLE_1 A test script for the AO implementation.
%
% M Hewitson 08-02-07
%
% $Id$
%

function example_1()
  
  
  % Make test AOs
  
  nsecs = 1000;
  fs    = 10;
  
  pl = plist();
  pl.append('nsecs', nsecs);
  pl.append('fs', fs);
  pl.append('tsfcn', 'randn(size(t))');
  
  a1 = ao(pl);
  a2 = ao(pl);
  a3 = ao(pl);
  a4 = ao(pl);
  
  % Make LPSD of each
  
  % parameter list for lpsd
  pl = plist();
  pl.append('Kdes', 100);
  pl.append('Jdes', 1000);
  pl.append('Order', 1);
  
  % use lpsd
  a5 = lpsd(a1, pl); a5.setName;
  a6 = lpsd(a2, pl); a6.setName;
  a7 = lpsd(a3, pl);
  a8 = lpsd(a4, pl);
  
  % add and plot
  a9  = a5+a6;
  a9.setName;
  
  iplot(a9, a5)
  
  % Some further operations
  a10 = a9.*a7;
  a11 = a10.*a8;
  
  iplot(a11)
  
  save(a11, 'example1.xml')
  
  % Reproduce from history
  a_out = rebuild(a11);
  
  iplot(a_out)
  
  close all
end
