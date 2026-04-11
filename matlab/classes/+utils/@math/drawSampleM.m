%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Draw a sample from a Gaussian Mixture distribution based of 3 Gaussians
%  and on the same covariance matrix.
%
%    M           - mean of central Gaussian
%    SIGMA       - Covariance or Correlation Matrix 
%    D           - 2xdim(m) with the mean vector of the remaining
%                  Gaussians.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function z = drawSampleM(m,Sigma,d)

S = cat(3,Sigma,Sigma,Sigma);

mu = m;
mu(2,:) = m + d(1,:);
mu(3,:) = m + d(2,:);

% use statistical toolbox, it will be removed in the future
obj = gmdistribution(mu,S,[0.5 0.25 0.25]);
z = random(obj,1);
end


