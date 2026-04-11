%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute Chi square cumulative distribution function
% 
% CALL 
% 
% p = Chi2cdf(x,v);
% 
% 
% INPUT
% 
% - x, data
% - v, degrees of freedom of the distribution
% 
%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.4.
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function p = Chi2cdf(x,v)

% Call the gamma distribution function. 
p = gammainc(x./2,v/2);


end