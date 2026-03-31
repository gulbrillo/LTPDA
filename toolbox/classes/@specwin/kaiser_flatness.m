function flatness = kaiser_flatness(alpha)

% KAISER_FLATNESS returns the flatness in dB of the central bin of a kaiser 
% window with parameter alpha.
% 
% Taken from C code of Gerhard Heinzel:
% 
%    Compute the flatness in the central bin [dB]
%    of Kaiser windows from the parameter alpha.
%    Best-fit polynomial was obtained from 180 data 
%    points between alpha=1 and alpha=9.95.
%    Maximum error is 0.013 dB.
% 

a0       = 0.141273;
a1       = 0.262425;
a2       = 0.00642551;
a3       = -0.000405621;
x        = alpha;
flatness =  -1. / (((((a3 * x) + a2) * x) + a1) * x + a0);

% END
