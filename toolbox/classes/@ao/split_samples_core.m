%
% Utility function to chop samples from a
% numerical vector.
%
function X = split_samples_core(X,lims)
  
  if lims(1) > length(X)
    idx = [];
  else
    idx = round(lims(1)):round(min(lims(2), length(X)));
  end
  
  X = X(idx);
  
end