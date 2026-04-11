% APPLYMETHOD applys the given method to the input 3D data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: APPLYMETHOD applys the given method to the input 3D data.
%
% CALL:        d = applymethod(d, pl)
%
% INPUTS:      d      - a 3D data object (xyzdata)
%              pl     - a plist of configuration options
%
% PARAMETERS:
%
%       'method' - the method to apply to the data
%       'axis'   - which axis vector to apply the method to. Possible values
%                  are: 'X', 'Y', 'Z', 'XYZ' [default: 'Z']
%       'option' - any additional option to pass to the method.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pl = applymethod(ds, pl, method, getDefaultPlist, varargin)
  
  % Get function handles
  dxFcn = {};
  for jj = 1:numel(varargin)
    if isa(varargin{jj}, 'function_handle')
      dxFcn = varargin{jj};
    end
    if iscell(varargin{jj})
      list = varargin{jj};
      if ~isempty(list) && isa(list{1}, 'function_handle')
        dxFcn = list{1};
      end
    end
  end
  
  pl = applyDefaults(getDefaultPlist('3D'), pl);

  % Get the axis we are dealing with
  axis = find_core(pl, 'axis');
  % Get the dimension to operate along
  dim = find_core(pl, 'dim');
  % Get any additional option
  opt = find_core(pl, 'option');

  % Loop over data objects
  for jj=1:numel(ds)
    switch lower(axis)
      case 'x'
        ds(jj).setX(apply(ds(jj).getX, method, dim, opt));
      case 'y'
        ds(jj).setY(apply(ds(jj).getY, method, dim, opt));
      case 'z'
        ds(jj).setZ(apply(ds(jj).getZ, method, dim, opt));
      case 'xyz'
        ds(jj).setX(apply(ds(jj).getX, method, dim, opt));
        ds(jj).setY(apply(ds(jj).getY, method, dim, opt));
        ds(jj).setZ(apply(ds(jj).getZ, method, dim, opt));
      otherwise
        error('### Unknown axis to operate on.');
    end
  end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------
% Apply method to the vector v
%-----------------------------------------------
function v = apply(v, method, dim, opt)
  if ~isempty(dim) && ~isempty(opt)
    % User supplied a dimension and an option
    v = feval(method, v, dim, opt);
  elseif ~isempty(dim)
    % User supplied only a dimension
    v = feval(method, v, dim);
  elseif ~isempty(opt)
    % User supplied only an option
    v = feval(method, v, opt);
  else
    % User supplied only a method
    v = feval(method, v);
  end
end

