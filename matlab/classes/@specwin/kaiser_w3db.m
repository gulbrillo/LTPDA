function w3db = kaiser_w3db(alpha)

% KAISER_W3DB returns the 3dB bandwidth in bins of a kaiser window with
% parameter alpha.
% 
% Taken from C code of Gerhard Heinzel:
% 
%    Compute the 3dB bandwidth (W3db) [bins]
%    of Kaiser windows from the parameter alpha.
%    Best-fit polynomial was obtained from 180 data 
%    points between alpha=1 and alpha=9.95.
%    Maximum error is 0.006 bins.
% 

a0   = 0.757185;
a1   = 0.377847;
a2   = -0.0238342;
a3   = 0.00086012;
x    = alpha;
w3db = (((((a3 * x) + a2) * x) + a1) * x + a0);

% END
