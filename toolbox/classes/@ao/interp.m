% INTERP interpolate the values in the input AO(s) at new values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: INTERP interpolate the values in the input AO(s) at new values
%              specified by the input parameter list.
%
% CALL:        b = interp(a, pl)
%
% INPUTS:      a  - input array of AOs
%              pl - parameter list with the keys 'vertices' and 'method'
%
% OUTPUTS:     b  - output array of AOs
%
% REMARKs:    1) Matrix cdata objects are not supported.
%             2) If a time-series object is interpolated, the sample rate
%             is adjusted to the best fit of the new data.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'interp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = interp(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % Get parameters
  vertices = find_core(pl, 'vertices');
  if isa(vertices, 'ao') && isa(vertices.data, 'tsdata') 
    vertices_t0 = double(vertices.t0);
    vertices = vertices.x;
  elseif isa(vertices, 'ao') && isa(vertices.data, 'xydata')
    vertices = vertices.x;
    vertices_t0 = [];
  elseif ischar(vertices)
    vertices = eval(vertices);
    vertices_t0 = [];
  else
    vertices_t0 = [];
  end
  
  imethod = lower(find_core(pl, 'method'));
  
  utils.helper.msg(msg.PROC1, 'using %s interpolation', imethod);
  
  %-----------------------
  % Loop over input AOs
  for jj = 1:numel(bs)
    %----------------------------
    % Interpolate this vector
    if ~isa(bs(jj).data, 'cdata')
      x = bs(jj).x;
      y = bs(jj).y;
      dy = bs(jj).dy;
      dx = bs(jj).dx;
      bs(jj).data.setDx([]);
      bs(jj).data.setDy([]);      
      
      % get interpolation method
      method = methodForType(class(y), imethod);
      
      if isa(bs(jj).data, 'tsdata') && ~isempty(vertices_t0)
        vertices = vertices + vertices_t0 - double(as(jj).t0);
      end
      
      % for tsdata, fsdata and xydata objects
      bs(jj).data.setXY(vertices, interpValues(x, y, vertices, method));
      if ~isempty(dy) && numel(dy) > 1
        bs(jj).data.setDy(interpValues(x, dy, vertices, method));
      end
      if ~isempty(dx) && numel(dx) > 1
        warning('!!! The error of the x-axis are interpolated to the new vertices');
        bs(jj).data.setDx(interpValues(x, dx, vertices, method));
      end
      if isprop(bs(jj).data, 'enbw')
        if ~isempty(bs(jj).data.enbw) && numel(bs(jj).data.enbw) > 1
          bs(jj).data.setEnbw(interpValues(x, bs(jj).data.enbw, vertices, method));
        end
      end
    else
      dy = bs(jj).dy;
      bs(jj).data.setDy([]);      
      
      % get interpolation method
      method = methodForType(class(bs(jj).data.y), imethod);
      
      % for cdata object
      bs(jj).data.setY(interpValues([], bs(jj).data.y,vertices, method));
      if ~isempty(dy) && numel(dy) > 1
        bs(jj).data.setDy(interpValues([], dy, vertices, method));
      end
    end
    
    % Adjust sample rate for tsdata
    if isa(bs(jj).data, 'tsdata')
      utils.helper.msg(msg.PROC1, 'adjusting sample rate of new data to best fit');
      [fs, toffset, evenly] = tsdata.fitfs(bs(jj).data);
      utils.helper.msg(msg.PROC2, 'got new sample rate of %g Hz', fs);
      utils.helper.msg(msg.PROC2, 'got new toffset %g', toffset);
      % collapse data, if possible.
      bs(jj).data.collapseX;
    end
    
    if ~callerIsMethod
      % set name
      bs(jj).name = sprintf('%s(%s)', method, ao_invars{jj});
      % Add history
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end

function method = methodForType(dtype, imethod)
  
  if strcmpi(imethod, 'auto')
    switch dtype
      case 'double'
        method = 'spline';
      case 'single'
        method = 'spline';
      otherwise
        method = 'nearest';
    end
  else
    method = imethod;
  end
  
end

function newY = interpValues(x, y, v, method)
  
  % cache the data type
  dtype = class(y);
  
  % cast to double (interp1 supports only double and single) then cast back
  % the result to the original data type
  if isempty(x)
    newY = cast(interp1(double(y), double(v), method, 'extrap'), dtype);
  else
    newY = cast(interp1(double(x), double(y), double(v), method, 'extrap'), dtype);
  end
end


%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  pl = plist();
  
  % Vertices
  p = param({'vertices', 'A new set of vertices to interpolate on. If ''vertices'' is an AO then ao/interp uses the x values from that AO. If this is a char, then it must evaluate (via eval) to an array of vertices.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Method
  p = param({'method', ['Specify the interpolation method. Choose between:<br>', ...
     '<ul><li>auto  - use a method according to the data type. Spline for double/single, nearest for all other types.</li>' ...
     '<ul><li>nearest  - nearest neighbor interpolation </li>' ...
     '<li>linear   - linear interpolation </li>' ...
     '<li>spline   - piecewise cubic spline interpolation (SPLINE)  </li>' ...
     '<li>pchip    - shape-preserving piecewise cubic interpolation </li>' ...
     '<li>v5cubic  - the cubic interpolation from MATLAB 5, which does not extrapolate and uses ''spline'' if X is not equally spaced. </li></ul>' ...
     ]}, ...
   {1, {'auto', 'nearest', 'linear', 'spline', 'pchip', 'v5cubic'}, paramValue.SINGLE});
  pl.append(p);
  
end
