%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute F distribution function
% 
% CALL 
% 
% p = Fpdf(x,n1,n2);
% 
% 
% INPUT
% 
% - x, F values
% - n1, degree of freedom 1
% - n2, degree of freedom 2
% 
%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.6.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function p = Fpdf(x,n1,n2)

B = beta(n1/2,n2/2);
N = n1/n2;

p = 1/B*N^(n1/2).*x.^(n1/2-1).*(1+N.*x).^(-(n1+n2)/2);
% p = n1^(n1/2)*n2^(n2/2).*x.^(n1/2-1)./B./(n1.*x+n2).^((n1+n2)/2);

end
