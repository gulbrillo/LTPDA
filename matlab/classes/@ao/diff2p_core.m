%
% Core function for the 2 point differentiation of a time series.
%
function [newX, z] = diff2p_core(x, y)
  
  dx     = diff(x);
  dy     = diff(y);
  z      = dy./dx;
  
  newX   = (x(1:end-1)+x(2:end))/2;
  
end