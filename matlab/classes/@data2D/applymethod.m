% APPLYMETHOD applys the given method to the input 2D data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: APPLYMETHOD applys the given method to the input 2D data.
%
% CALL:        pl = applymethod(d, pl)
%              pl = applymethod(d, pl, fcns)
%
% INPUTS:      d      - a 2D data object (tsdata, fsdata, xydata)
%              pl     - a plist of configuration options
%              fcns   - function handle(s) for the evaluation of the uncertainty
%                       (alone or in a cell array)
%
% PARAMETERS:
%
%       'method' - the method to apply to the data
%       'axis'   - which axis vector to apply the method to. Possible values
%                  are: 'X', 'Y', 'XY' [default: 'Y']
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
  
  pl = applyDefaults(getDefaultPlist('2D'), pl);
  
  % Get the axis we are dealing with
  axis = find_core(pl, 'axis');
  % Get any additional option
  opt = find_core(pl, 'option');
  
  % Act on the data object
  switch lower(axis)
    case 'x'
      if ~isempty(ds.dx) && ~isempty(dxFcn)
        ds.setDx(feval(dxFcn, ds.getX, ds.getDx));
      else
        ds.setDx([]);
      end
      ds.setX(apply(ds.getX, method, opt));
    case 'y'
      if ~isempty(ds.dy) && ~isempty(dxFcn)
        ds.setDy(feval(dxFcn, ds.getY, ds.getDy));
      else
        ds.setDy([]);
      end
      ds.setY(apply(ds.getY, method, opt));
      
    case 'xy'
      if ~isempty(ds.getDx) && ~isempty(dxFcn)
        ds.setDx(feval(dxFcn, ds.getX, ds.getDx));
      else
        ds.setDx([]);
      end
      if ~isempty(ds.getDy) && ~isempty(dxFcn)
        ds.setDy(feval(dxFcn, ds.getY, ds.getDy));
      else
        ds.setDy([]);
      end
      ds.setX(apply(ds.getX, method, opt));
      ds.setY(apply(ds.getY, method, opt));
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
function v = apply(v, method, opt)
  if ~isempty(opt)
    % User supplied only an option
    v = feval(method, v, opt);
  else
    % User supplied only a method
    v = feval(method, v);
  end
end

