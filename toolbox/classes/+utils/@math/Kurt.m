%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute the sample (bias-corrected) excess kurtosis. 
% 
% CALL 
% 
% p = Kurt(x);
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function k = Kurt(x)

n = numel(x);
mu4 = sum((x-mean(x)).^4)/n;
sig = sqrt(sum((x-mean(x)).^2)/n);
k = mu4/(sig)^4;

% Bias correction
k = (n-1)/(n-2)/(n-3)*((n+1)*k-3*(n-1));

end