%
% Core function for the 5 point differentiation of a time series.
%
function z = diff5p_core(x, y, dx)
  
  z          = zeros(size(y));
  z(1)       = (y(2)-y(1)) ./ (dx(1));
  z(2)       = (y(3)-y(1))./(dx(2)+dx(1));
  z(3:end-2) = (-y(5:end) + 8.*y(4:end-1) - 8.*y(2:end-3) + y(1:end-4)) ./ (3.*(x(5:end)-x(1:end-4)));
  z(end-1)   = 2*z(end-2)-z(end-3);
  z(end)     = 2*z(end-1)-z(end-2);
  
end