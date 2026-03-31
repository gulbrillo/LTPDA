%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Draw a sample from an adaptive distribution based on the covariance
% matrix depending on nacc
%
% See Roberts, Rosenthal 'Examples of Adaptive MCMC' 
%
function [z, newSigma] = drawAdaptiveSample(mu, Sigma, b)

  % get parameter space dimension
  dim = length(mu);

  % Calculate new covariance
  newSigma = ((2.38)^2)/dim.*Sigma + b.*(diag(ones(size(mu))));
  z        = MCMC.drawSample(mu, newSigma);

end

% END