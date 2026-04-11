%
% Utility function to chop samples from a 
% numerical vector.
%
function fs = chop(fs,limits)
  
  fs = fs(limits(1):limits(end));
  
end