% GETJACOBIAN Calculate Jacobian of a given model function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION
% 
%     Calculate Jacobian of a given model function for the given set of
%     coefficients. Jacobian is approximated with finite difference method.
% 
% CALL:
% 
%     J = getjacobian(coeff,model,X)
% 
% INPUT:
% 
%     J - fit coefficients
%     model - model function
%     X - x vactor (abscissa)
%       
% 
% OUTPUT:
% 
%     J - Jacobian
% 
% Note: Look at nlinfit.m of the stats toolbox. Model should be a matlab
% function calculating Model values as a function of X and of coefficients
% NOTE: The function prefer to work with column objects. Therefore it is
% good practise to directly input coeff and X as column objects
%
%   Examples:
%
%      Use @ to specify MODELFUN:
%         load reaction;
%         J = getjacobian(coeff,@mymodel,X);
%
%      where MYMODEL is a MATLAB function such as:
%         function yhat = mymodel(beta, X)
%         yhat = (beta(1)*X(:,2) - X(:,3)/beta(5)) ./ ...
%                        (1+beta(2)*X(:,1)+beta(3)*X(:,2)+beta(4)*X(:,3));
%      or
% 
%         mymodel = @(beta,X)(beta(1).*X(:,1)+beta(2).*X(:,2)+...)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function J = getjacobian(coeff,model,X)
  % checking size, willing to work with columns
  [a,b] = size(coeff);
  if a<b
    coeff = coeff.';
  end
  [a,b] = size(X);
  if a<b
    X = X.';
  end
  
  % finite difference relative step
  fdiffstep = eps^(1/3);
  % evaluate model on the input coefficients
  yfit = model(coeff,X);
  % check for NaNs
  nans = isnan(yfit(:));
  
  % initialization
  p = numel(coeff);
  delta = zeros(size(coeff));
  J = zeros(numel(yfit),p);
  for k = 1:p
    if (coeff(k) == 0)
      nb = sqrt(norm(coeff));
      delta(k) = fdiffstep * (nb + (nb==0));
    else
      delta(k) = fdiffstep*coeff(k);
    end
    yplus = model(coeff+delta,X);
    dy = yplus(:) - yfit(:);
    dy(nans) = [];
    J(:,k) = dy/delta(k);
    delta(k) = 0;
  end
end