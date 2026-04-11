%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute inverse of the cumulative F distribution function
% 
% CALL 
% 
% x = Finv(p,n1,n2);
% 
% 
% INPUT
% 
% - p, probability
% - n1, degree of freedom 1
% - n2, degree of freedom 2
% 
% References:
%   [1] William H. Press, Saul A. Teukolsky, William T. Vetterling, Brian
%   P. Flannery, NUMERICAL RECIPES, Cambridge University Press, 2007
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = Finv(p,n1,n2)

u = betaincinv(p,n1/2,n2/2);
x = n2.*u./(n1.*(1-u));

end


