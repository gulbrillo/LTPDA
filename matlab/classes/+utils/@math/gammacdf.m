%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute Gamma cumulative distribution function
% 
% CALL 
% 
% p = gammacdf(x,A,B);
% 
% 
% INPUT
% 
% - x, data. (e.g. The x axis of an empirical cdf made with utils.math.ecdf).
% - A, distribution parameter. It is a constant.
% - B, distribution parameter. It is a constant.
%
% NOTE: In the case of whitened welch's psd A = Ns and B = 1/Ns where Ns is
% the number of averages
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = gammacdf(x,A,B)

idx = x>=0;

p = zeros(size(x));

p(idx) = gammainc(x(idx)./B,A);


end