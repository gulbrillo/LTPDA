%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute Normal cumulative distribution function
% 
% CALL 
% 
% p = Normcdf(x,mu,sigma);
% 
% 
% INPUT
% 
% - x, data
% - mu, distribution mean
% - sigma, distribution standard deviation
% 
%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.2.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = Normcdf(x,mu,sigma)

z = (x-mu)./sigma;
p = 0.5*erfc(-z./sqrt(2));


end
