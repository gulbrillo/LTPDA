% DECISION: Compute the MH acceptance ratio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Description: Compute the MH acceptance ratio given the
%              log-likelihood, beta and prior values.
%
%
%        CALL: answer = Decision(L1, L2, betta)
%
%              answer = TRUE_FALSE value.
%
% NK 2012
%
function [Ratio, answer, post] = decision(L1, L2, beta, proposalpdf, priors, issymmetric)
  
  % Compute posterior
  post(1) = L1 * priors(1);
  post(2) = priors(2) * L2;
  
  % Calculate log-likelihood ratio
  if issymmetric
    
    Ratio = (post(2) / post(1))^(beta);
    
  else
    
    q = pd(xn, xo, cvar, proposalpdf);
    
    Ratio = ((post(2) * q(1)) / (post(1) * q(2)))^(beta);
    
  end
  
  % Decide if the proposed point is accepted or not.
  if (rand(1) < min([1 Ratio]) && L1 ~= inf && L2 ~= inf)
    
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
function q = pd(X,mean,cov,proposal)

  q(1) = proposal(X,mean,cov);
  
  if (q(1) == -Inf || q(1) == Inf); q(1) = 1; end
  
  q(2) = proposal(mean,X,cov);
  
  if (q(2) == -Inf || q(2) == Inf); q(2) = 1; end

end
% END