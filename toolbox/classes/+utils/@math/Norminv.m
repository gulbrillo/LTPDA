%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute inverse of the Normal cumulative distribution function
% 
% CALL 
% 
% x = Norminv(p,mu,sigma);
% 
% 
% INPUT
% 
% - p, probability
% - mu, distribution mean
% - sigma, distribution standard deviation
% 
%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.2.
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = Norminv(p,mu,sigma)

 xt = -sqrt(2).*erfcinv(2*p);
 x = sigma.*xt + mu;

end
