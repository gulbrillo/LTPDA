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
  
  % Here we only look for 'dy'
  dy = pl.find_core('dy');
  
  % Check the length
  if numel(dy) > 1 && numel(dy) ~= numel(data.y)
    error('The error values for dy should be either a single value or a vector of length(y)');
  end
  
  % Expand a single value
  if numel(dy) == 1
    dy = dy*ones(size(data.y));
  end
  
  % Set to the data
  data.setDy(dy);
  

end
% END