% INTERSECT overloads the intersect operator for Analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: INTERSECT overloads the intersect operator for Analysis
%              objects.
%
% CALL:        out = intersect(a1, a2);
%
% EXAMPLE:     This example shows only the x-values:
%
%              a1: |-----------|    |--------------------|
%              a2: |-------------------------------------|
%
%              The output have the x-values of a1 and the y-values of a2
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'intersect')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = intersect (varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist');
  
  % Check input arguments number
  if length(as) < 2
    error ('### Incorrect inputs. This method needs at least two input AOs.');
  end
  
  if nargout == 0
    error('### Intersect cannot be used as a modifier. Please give an output variable.');
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Combine input PLIST with default PLIST
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % get options
  axis = pl.find_core('axis');
  tol  = pl.find_core('tol');
  
  % Get data object
  out  = [];
  mask = bs(1);
  
  for ii = 2:numel(bs)
    a = bs(ii);
    
    % Choos always the data type of the second input
    dout = copy(a.data.initObjectWithSize(1,1), 1);
    
    % Calculate and set values
    if isa(dout, 'cdata')
      if any(find(axis == 'y'))
        [y, idx] = localIntersect(mask.data.getY, a.data.getY, tol);
        dout.setY(y);
        setDataValues(dout, a, idx);
      else
        x1 = localGetAbsoluteX(mask);
        x2 = localGetAbsoluteX(a);
        [y, idx] = localIntersect(x1, x2, tol);
        dout.setY(y);
        setDataValues(dout, a, idx);
      end
    else
      if strcmpi(axis, 'y')
        [y, idx] = localIntersect(mask.data.getY, a.data.getY, tol);
        x = localGetAbsoluteX(a);
        dout.setX(x(idx));
        dout.setY(y);
        setDataValues(dout, a, idx);
      elseif strcmpi(axis, 'x')
        x1 = localGetAbsoluteX(mask);
        x2 = localGetAbsoluteX(a);
        
        [x, idx] = localIntersect(x1, x2, tol);
        dout.setX(x);
        dout.setY(a.y(idx));
        setDataValues(dout, a, idx);
      else
        error('### This axis is not allowed [%s]. Please use one of the following inputs ''x'' or ''y''');
      end
    end
    
    % collapse dout if possible
    if isa(dout, 'tsdata')
      dout.collapseX();
    end
    
    % Set name
    a.name = sprintf('%s(%s, %s)', mfilename, ao_invars{1}, ao_invars{ii});
    % Set data object
    a.data = dout;
    % Set history
    a.addHistory(getInfo('None'), pl, ao_invars([1 ii]), [mask.hist a.hist]);
    
    out = [out a];
  end
  
  % Set output
  if nargout == 1
    varargout{1} = out;
  end
end

%--------------------------------------------------------------------------
% Set all necessary values to the data object
%--------------------------------------------------------------------------
function setDataValues(dout, a, idx)
  
  setErrors(dout, a, idx);
  setUnits(dout, a);
  
  % Set special values for the fsdata
  if isa(dout, 'fsdata')
    dout.setNavs(a.data.navs);
    dout.setEnbw(a.data.enbw);
    dout.setT0(a.data.t0);
    dout.setFs(a.data.fs);
  end
end

%--------------------------------------------------------------------------
% Set the units for the intersection
%--------------------------------------------------------------------------
function setUnits(dout, a)
  dout.setYunits(a.yunits);
  if ~isa(dout, 'cdata')
    dout.setXunits(a.xunits);
  end
end

%--------------------------------------------------------------------------
% Set the error(s) for the intersection
%--------------------------------------------------------------------------
function setErrors(dout, a, idx)
  % Calculate dy
  if ~isempty(a.dy)
    if numel(a.dy) == 1
      dout.setDy(a.dy);
    else
      dout.setDy(a.dy(idx));
    end
  end
  
  % Calculate dx
  if ~isa(dout, 'cdata') && ~isempty(a.dx)
    if numel(a.dx) == 1
      dout.setDx(a.dx);
    else
      dout.setDx(a.dx(idx));
    end
  end
end

%--------------------------------------------------------------------------
% Calculates the intersection of a and b with a tolerance
%--------------------------------------------------------------------------
function x = localGetAbsoluteX(a)
  if isa(a.data, 'tsdata')
    x = a.data.getX + a.data.t0.utc_epoch_milli/1e3;
  else
    x = a.data.getX;
  end
end

%--------------------------------------------------------------------------
% Calculates the intersection of a and b with a tolerance
%--------------------------------------------------------------------------
function [out, idxB] = localIntersect(a,b,tol)
  if isempty(tol)
    [out, idxA, idxB] = intersect(a, b);
  else
    error('### Please code me up.');
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
  ii.setModifier(false);
  ii.setArgsmin(2);
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

function out = buildplist()
  out = plist();
  
  % AXIS
  p = param({'axis', 'The axis on which to apply the method.'}, {1, {'x', 'y'}, paramValue.SINGLE});
  out.append(p);
  
  % TOL
  p = param({'tol', 'Tolerance for the intersect method.'}, paramValue.EMPTY_DOUBLE);
  out.append(p);
  
end

