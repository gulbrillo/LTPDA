% function test_ltpda_lpsd_new()
% A test script for the AO implementation of lpsd.
% 
% M Hewitson 02-02-07
% 
% $Id$
% 

clear all;

%% Make test AOs

%% poles and zeros
p1 = pole(0.1, 2);
p2 = pole(0.5, 3);
p3 = pole(1);

z1 = zero(0.5, 30);
z2 = zero(1, 2);

gain =1; 
%% convert to get a and b coefficients
%pole zero model
pzm = pzmodel(gain, [p1 p2 p3], [z1 z2]);
% parameter list for ltpda_noisegen
pl = plist();
pl = append(pl, param('nsecs', 100000));
pl = append(pl, param('fs', 10));
pl = append(pl, param('pzmodel', pzm));
%% calling the noisegenerator
[a1, pl1, pl2]  = ltpda_noisegen(pl);
a1 = set(a1, 'yunits', 'V');

%% Make LPSD of each

% Window function
w = specwin('Kaiser', 10, 150);

% parameter list for lpsd
pl = plist();
pl = append(pl, param('Kdes', 100));
pl = append(pl, param('Kmin', 2));
pl = append(pl, param('Jdes', 1000));
pl = append(pl, param('Win', w));
pl = append(pl, param('Order', 1));

plm = plist('M-FILE ONLY', 1);

%% use old lpsd
tic
a4 = ltpda_lpsd(a1, pl, plm);
told = toc;


%% use new lpsd
tic
a5 = ltpda_lpsd(a1, pl);
tnew = toc;

sprintf('#### Old method: %f s', told)
sprintf('#### New method: %f s', tnew)

told/tnew

%% add and plot
iplot(a4, a5, plist('Legends', {'old','new'}))

iplot(a4./ a5, plist('YScales', 'lin'))

