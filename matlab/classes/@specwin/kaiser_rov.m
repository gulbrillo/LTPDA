function rov = kaiser_rov(alpha)

% KAISER_ROV returns the recommended overlap for a Kaiser window with
% parameter alpha.
% 
% Taken from C code of Gerhard Heinzel:
% 
%    Compute the 'recommended overlap' (ROV) [%] of Kaiser windows
%    from the parameter alpha. Best-fit polynomial
%    was obtained from 180 data points between alpha=1
%    and alpha=9.95. Maximum error is 1.5%, mainly due
%    to insufficient precision in the data points
% 


a0  = 0.0061076;
a1  = 0.00912223;
a2  = -0.000925946;
a3  = 4.42204e-05;
x   = alpha;
rov =  100 - 1 / (((((a3 * x) + a2) * x) + a1) * x + a0);

% END
