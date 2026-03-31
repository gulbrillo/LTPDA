%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute inverse of the Chi square cumulative distribution function
% 
% CALL 
% 
% x = Chi2inv(p,v);
% 
% 
% INPUT
% 
% - p, probability or significance level
% - v, degrees of freedom of the distribution
% 
% Example: If you want the 95% confidence interval for a chi2 variable you
% should call
% 
% x = utils.math.Chi2inv([0.05/2 1-0.05/2],v)
% 
%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.4.
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x = Chi2inv(p,v)

a = v/2;
b = 2;
% Call the gamma inverse function. 
% x = gaminv(p,v/2,2); % uses statistic toolbox
q = gammaincinv(p,a,'lower');
x = q.*b;


end