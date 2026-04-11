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
  
  % Call super to do x and y
  setErrorsFromPlist@data2D(data, pl);
  
  % Here we only look for 'dz'
  dz = pl.find_core('dz');
  
  % Check the size
  if numel(dz) > 1 && numel(dz) ~= numel(data.getZ)
    dz_size = size(dz);
    z_size = size(data.getZ);
    if dz_size(1) ~= z_size(1) || dz_size(2) ~= z_size(2)
      error('The error values for dz should be either a single value or a matrix of size(z)');
    end
  end
  
  % Expand a single value
  if numel(dz) == 1
    dz = dz*ones(size(data.getZ));
  end
  
  % Set to the data
  data.setDz(dz);  

end
% END