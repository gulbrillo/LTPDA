% JR2COV Calculates coefficients covariance matrix from Jacobian and Residuals.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION
% 
%     Calculates coefficients covariance matrix from Jacobian and
%     Residuals. The algorithm uses the QR factorization of J to perform
%     the calculation inv(J'J)*s wehre J is the Jacobian matrix and s is
%     the mean squared error.
% 
% CALL:
% 
%     covmat = jr2cov(J,resid)
% 
% INPUT:
% 
%     J - Jacobian of the function with respect to the given coefficients
%     resid - Fit residuals
%       
% 
% OUTPUT:
% 
%     covmat - covariance matrix of the fit coefficients
% 
% Note: Resid should be a column vector, Number of rows of J must be equal
% to the number of rows of Resid. The number of columns of J defines the
% number of corresponding fit parameters for which we want to calculate the
% covariance matrix
% Estimate covariance from J and residuals. Look at the nlparci.m function
% of the stats toolbox for further details
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function covmat = jr2cov(J,resid)
  
  missing = isnan(resid);
  if ~isempty(missing)
      resid(missing) = [];
  end
  
  n = length(resid);
  
  J(missing,:) = [];
  
  if size(J,1)~=n
    error('The number of rows of J does not match the number of rows of RESID.');
  end
  [n,p] = size(J);
  v = n-p; % degrees of freedom of the parameters estimation
  
  % Approximation when a column is zero vector
  temp = find(max(abs(J)) == 0);
  if ~isempty(temp)
    J(temp,:) = J(temp,:) + sqrt(eps(class(J)));
  end
  
  % Calculate covariance matrix
  [Q,R] = qr(J,0);
  Rinv = R\eye(size(R));
  
  mse = norm(resid)^2 / v; % mean square error
  covmat = mse * Rinv*Rinv';
  
end