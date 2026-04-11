%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute Gamma probability density function
% 
% CALL 
% 
% p = gammapdf(x,A,B);
% 
% 
% INPUT
% 
% - x, data. (e.g. The x axis of an histogram).
% - A, distribution parameter. It is a constant.
% - B, distribution parameter. It is a constant.
%
% NOTE: In the case of whitened welch's psd A = Ns and B = 1/Ns where Ns is
% the number of averages
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = gammapdf(x,A,B)

idx = x>=0;

p = zeros(size(x));

p(idx) = ((x(idx).^(A-1)).*exp(-x(idx)./B))./((B.^A).*gamma(A));


end