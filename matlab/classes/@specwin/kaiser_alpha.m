function alpha = kaiser_alpha(req_psll)

% KAISER_ALPHA returns the alpha parameter that gives the required input
% PSLL.
% 
% Taken from C code of Gerhard Heinzel:
% 
%    Compute the parameter alpha of Kaiser windows
%    from the required PSLL [dB]. Best-fit polynomial
%    was obtained from 180 data points between alpha=1
%    and alpha=9.95. Maximum error is 0.05 
%    Maximum error for PSLL > 30 dB is 0.02
% 


a0 = -0.0821377;
a1 = 4.71469;
a2 = -0.493285;
a3 = 0.0889732;

x = req_psll / 100;
alpha = (((((a3 * x) + a2) * x) + a1) * x + a0);


% END
