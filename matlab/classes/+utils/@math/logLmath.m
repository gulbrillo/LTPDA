%
% 3D Matrices multiplication tool to be used in the log-likelihood
% and Fisher Matrix calculations
%
% INPUTS:   injections, measurements, Inverse CS matrix and
%           the responce of the model.
%
%
% OUTPUTS:  the log-likelihood value and the SNR.
%
% NK 2012
%

function [L snr] = logLmath(in, out, S, TF)

% Get the template
h = utils.math.mult(TF, in);

% Get logL(f)
Lf = utils.math.ctmult(out - h, utils.math.mult(S, out - h));

% L: Sum over frequencies
L = sum(real(Lf));

% Get H*s
hs = utils.math.ctmult(h,utils.math.mult(S, out));

% Get h^2
hh = utils.math.ctmult(h,utils.math.mult(S, h));

% SNR calculation
snr = sqrt(2)*real(sum(hs).^2/sum(hh));

end

% END
