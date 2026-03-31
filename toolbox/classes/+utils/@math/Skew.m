%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute the sample (bias-corrected) skewness. 
% 
% CALL 
% 
% p = Skew(x);
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = Skew(x)

n = numel(x);
mu3 = sum((x-mean(x)).^3)/n;
sig = sqrt(sum((x-mean(x)).^2)/n);
s = mu3/(sig)^3;

% Bias correction
s = sqrt(n*(n-1))/(n-2)*s;

end