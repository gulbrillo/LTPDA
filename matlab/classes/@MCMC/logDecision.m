% LOGDECISION: Compute the logarithm of the MH acceptance ratio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      
% Description: Compute the MH acceptance ratio given the 
%              log-likelihood, beta and prior values.
%
%
%        CALL: answer = logDecision(L1, L2, betta)
%
%              answer = TRUE_FALSE value.
%
% NK 2012
%
function [logRatio, answer, post] = logDecision(L1, L2, beta, proposalpdf, priors, issymmetric)

  % Compute posterior
  post(1) = L1 + priors(1);
  post(2) = priors(2) + L2;
  
  % Calculate log-likelihood ratio
  if issymmetric
    
    logRatio = beta*(post(2) - post(1));
    
  else
    
    q = logq(xn, xo, cvar, proposalpdf);
    
    logRatio = beta*(post(2) - post(1) + q(2) - q(1));
    
  end

  % Compute the acceptance ration
  Ratio = exp(logRatio);
  
  % Decide if the proposed point is accepted or not. 
  if rand(1) < Ratio
    
    answer = true;
    
  else
    
    answer = false;
    
  end

end

% 
% Compute proposal density.
%
% Return a 1x2 array of the proposals densities as q(x|x0) and q(x0|x) 
%
function q = logq(X,mean,cov,proposal)

  q(1) = log(proposal(X,mean,cov));
  
  if (q(1) == -Inf || q(1) == Inf); q(1) = 0; end
  
  q(2) = log(proposal(mean,X,cov));
  
  if (q(2) == -Inf || q(2) == Inf); q(2) = 0; end

end

% END