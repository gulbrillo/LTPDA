%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Draw a sample from a normal distribution based on the covariance matrix
%
% If the covariance matrix is singular, an error is thrown.
%
function z = drawSample(mu,Sigma)
  
  % Put in a row vector always
  if iscolumn(mu)
    mu = transpose(mu);
  end
  
  % Get parameter space dimension
  dim = length(mu);
  
  % Get the chol
  R = chol(Sigma);
  
  % Draw sample
  z = mu + randn(1,dim)*R;
  
end

% END