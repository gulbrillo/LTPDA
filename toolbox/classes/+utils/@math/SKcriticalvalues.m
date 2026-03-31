%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute critical values of the Smirnov - Kolmogorov distribution
% 
% CALL 
% 
% [F,X] = SKcriticalvalues(Y);
% 
% 
% INPUT
% 
% - Y, a data series
% 
% References:
%   [1] Leslie H. Miller, Table of Percentage Points of Kolmogorov
%   Statistics, Journal of the American Statistical Association,
%   Vol. 51, No. 273 (Mar., 1956), pp. 111-121
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cVal = SKcriticalvalues(n1,n2,alph)

if isempty(n2)
  n = n1; % test against theoretical distribution
else
  n = n1*n2/(n1+n2); % test of two empirical distributions
end
A = 0.09037*(-log10(alph)).^1.5 + 0.01515*log10(alph).^2 - 0.08467*alph - 0.11143;
asympt =  sqrt(-0.5*log(alph)./n); % Smirnov asymptothic formula
cVal  =  asympt - 0.16693./n - A./n.^1.5;
end

