%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute cumulative F distribution function
% 
% CALL 
% 
% p = Fcdf(x,n1,n2);
% 
% 
% INPUT
% 
% - x, probability
% - n1, degree of freedom 1
% - n2, degree of freedom 2
% 
%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.6.
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = Fcdf(x,n1,n2)

x = n2./(n2+x.*n1);
p = betainc(x, n2/2, n1/2, 'upper');

% % Compute P when X > 0.
% k = find(x > 0 & isfinite(n1) & isfinite(n2));
% if any(k)
%   k1 = (n2(k) <= x(k).*n1(k));
%   % use A&S formula 26.6.2 to relate to incomplete beta function
%   % Also use 26.5.2 to avoid cancellation by subtracting from 1
%   if any(k1)
%     kk = k(k1);
%     xx = n2(kk)./(n2(kk)+x(kk).*n1(kk));
%     p(kk) = betainc(xx, n2(kk)/2, n1(kk)/2,'upper');
%   end
%   if any(~k1)
%     kk = k(~k1);
%     num = n1(kk).*x(kk);
%     xx = num ./ (num+n2(kk));
%     p(kk) = betainc(xx, n1(kk)/2, n2(kk)/2,'lower');
%   end
end
