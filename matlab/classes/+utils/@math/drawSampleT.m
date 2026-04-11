% DRAWSAMPLET  Draw a sample from the Student's t distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%   Y = drawSampleT(MU,SIGMA,N) samples from Student's t distribution
%
%   MU          - mean
%   SIGMA       - Covariance or Correlation Matrix 
%   N           - degrees of freedom
%
%   Karnesis N. 30-4-2012
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sample = drawSampleT(mu, Sigma, N)

% Covariance matrix to correlation matrix
s = sqrt(diag(Sigma));
if (any(s~=1))
    Sigma = Sigma ./ (s * s');
end

% Make sure C is a valid covariance matrix
R = chol(Sigma); 
dim = length(mu);
N = N(:);

sample = randn(1, size(R,1)) * R;
x = sqrt(gamrnd(N./2, 2, 1, 1) ./ N);
sample = mu + sample ./ x(:,ones(dim,1));