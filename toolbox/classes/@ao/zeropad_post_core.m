%
% Core function to zeropad a numerical vector
%
function y = zeropad_post_core(x, N)
  
  [~, c] = size(x);
  
  if c == 1
    y = [x; zeros(N, 1)];
  else
    y = [x zeros(N, 1)];
  end
end