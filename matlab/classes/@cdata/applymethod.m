% APPLYMETHOD applys the given method to the input cdata.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: APPLYMETHOD applys the given method to the input cdata.
%
% CALL:        pl = applymethod(d, pl)
%              pl = applymethod(d, pl, fcns)
%
% INPUTS:      d      - a cdata object
%              pl     - a plist of configuration options
%              fcns   - function handle(s) for the evaluation of the uncertainty
%                       (alone or in a cell array)
%
% PARAMETERS:
%
%       'method' - the method to apply to the data
%       'dim'    - the dimension of the chosen vector to apply the method
%                  to. This is necessary for functions like mean() when
%                  applied to matrices held in cdata objects. [default: []]
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

  pl = applyDefaults(getDefaultPlist('1D'), pl);
  
  % Get the axis we are dealing with
  axis = find_core(pl, 'axis');
  % Get the dimension to operate along
  dim = find_core(pl, 'dim');
  % Get any additional option
  opt = find_core(pl, 'option');
  
  % Act on data object
  switch lower(axis)
    case 'y'
      if ~isempty(ds.yaxis.ddata) && ~isempty(dxFcn)
        ds.setDy(feval(dxFcn, ds.yaxis.data, ds.yaxis.ddata));
      else
        ds.setDy([]);
      end
      ds.setY(apply(ds.yaxis.data, method, dim, opt));
    otherwise
      error('### Unsupported axis ''%s'' to operate on.', axis);
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

