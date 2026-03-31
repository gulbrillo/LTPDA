% STPDF  Probability density function for Student's T distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%   Y = STPDF(X,SIGMA,N) returns the pdf of Student's T distribution 
%   with V degrees of freedom, at the values in X.
%
%   X       - data
%   SIGMA   - Covariance or Correlation Matrix 
%   N       - degrees of freedom 
%
%   Karnesis N. 30-4-2012
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = stpdf(X, Sigma, N)

% Get size of data.
[n,d] = size(X);

% Covariance matrix to correlation matrix
s = sqrt(diag(Sigma));
if (any(s~=1))
    Sigma = Sigma ./ (s * s');
end

% Make sure C is a valid covariance matrix
R = chol(Sigma); 

N = N(:);

XX = X / R;
logSqrtDetC = sum(log(diag(R)));

Numer = -((N+d)/2) .* log(1+sum(XX.^2, 2)./N);
Denom = logSqrtDetC + (d/2)*log(N*pi);
y = exp(gammaln((N+d)/2) - gammaln(N/2) + Numer - Denom);