% SETERRORSFROMPLIST sets the errors from the plist based on the error
% fields. Performs checks and handles the single value case being expanded
% to match the full vector.
% 
% Usage:   data.setErrorsFromPlist(pl)
% 
function setErrorsFromPlist(varargin)

  if nargin ~= 2 || ~isa(varargin{2}, 'plist')
    error('setErrorsFromPlist requires an input plist');
  end
  
  % Inputs
  data = varargin{1};
  pl   = varargin{2};
  
  % Call super to do y
  setErrorsFromPlist@ltpda_data(data, pl);
  
  % Here we only look for 'dx'
  dx = pl.find_core('dx');
  
  % Check the length
  if numel(dx) > 1 && numel(dx) ~= numel(data.x)
    error('The error values for dx should be either a single value or a vector of length(x)');
  end
  
  % Expand a single value
  if numel(dx) == 1
    dx = dx*ones(size(data.x));
  end
  
  % Set to the data
  data.setDx(dx);  

end
% END