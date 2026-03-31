%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute R matrix
% 
% CALL 
% 
% Get R
% R = Rcovmat(x)
% 
% INPUT
% 
% - x data series


function R = Rcovmat(x)

  % willing to work with rows
  if size(x,1)>size(x,2)
    x = x.';
  end
  % subtract the mean
  x = x - mean(x);
  
  nx = size(x,2);
  
  x = fliplr(x);
    
  % init trim matrix
  R = zeros(nx,nx);
  % fillin the trim matrix
  for ii=1:nx
    R(ii,ii:nx) = x(1:nx-ii+1);
  end
  




end