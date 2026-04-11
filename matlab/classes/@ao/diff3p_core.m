%
% Core function for the 3 point differentiation of a time series.
%
function z = diff3p_core(y, d, dim)

if nargin < 3, dim = 1; end

if dim == 2, y = transpose(y); end
  
  if numel(d) == 1
    dx = d*ones(size(y,1)-1,size(y,2));
  else
    dx = d;
  end
  
  z          = zeros(size(y));
  z(2:end-1,:) = (y(3:end,:)-y(1:end-2,:)) ./ (dx(2:end,:)+dx(1:end-1,:));
  z(1,:)       = (y(2,:)-y(1,:)) ./ (dx(1,:));
  z(end,:)     = 2*z(end-1,:)-z(end-2,:);
  
  if dim == 2, z = transpose(z); end
end