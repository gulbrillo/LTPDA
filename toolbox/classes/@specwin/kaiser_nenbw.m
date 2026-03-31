function nenbw = kaiser_nenbw(alpha)

% KAISER_NENBW returns the normalized noise-equivalent bandwidth for a
% kaiser window with parameter alpha.
% 
% Take from C code of Gerhard Heinzel:
% 
%    Compute the 'normalized noise-equivalent bandwidth'
%    (NENBW) [bins] of Kaiser windows from the parameter alpha.
%    Best-fit polynomial was obtained from 180 data 
%    points between alpha=1 and alpha=9.95.
%    Maximum error is 0.007 bins 
%    NOTE that NENBW can be computed precisely 
%    from the actual time-domain window values
% 

a0    = 0.768049;
a1    = 0.411986;
a2    = -0.0264817;
a3    = 0.000962211;
x     = alpha;
nenbw =  (((((a3 * x) + a2) * x) + a1) * x + a0);

% END
