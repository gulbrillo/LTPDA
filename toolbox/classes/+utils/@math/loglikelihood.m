% LOGLIKELIHOOD.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute log-likelihood
%
% The math formula for the default log-likelihood function.
%
% INPUTS:   in         - Inputs
%           out        - Outputs
%           noise      - Inverse cross-spectrum matrix.
%           H          - The evaluated model TF in the desired xn.
%
% OUTPUTS:  loglk, snr - A 1x2 vector containing the log-likelihood
%                       value and the SNR calculated.
%
% NK 2012
%
function [L snr Lf] = loglikelihood(in, out, S, TF)
  
  % Get the template
  h = utils.math.mult(TF, in);
  
  % Get logL(f)
  Lf = real(utils.math.ctmult(out - h, utils.math.mult(S, out - h)));
  
  % L: Sum over frequencies
  L = sum(Lf);
  
  % Get H*s
  hs = utils.math.ctmult(h,utils.math.mult(S, out));
  
  % Get h^2
  hh = utils.math.ctmult(h,utils.math.mult(S, h));
  
  % SNR calculation
  snr = sqrt(2)*real(sum(hs).^2/sum(hh));
  
end

% END

