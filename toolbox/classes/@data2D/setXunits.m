% SETXUNITS Set the property 'xunits'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'xunits'.
%
% CALL:              obj.setXunits('units');
%              obj = obj.setXunits('units'); create copy of the object
%
% INPUTS:      obj   - must be a single data2D object.
%              units - unit object or a valid string which can be transformed
%                      into a unit object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setXunits(varargin)

  obj = varargin{1};
  val = varargin{2};

  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);

  % set 'xunits'
  if isempty(val)
    xunits = unit();
  elseif ischar(val)
    xunits = unit(val);
  elseif iscell(val)
    xunits = val{1};
  else
    xunits = val;
  end

  obj.xaxis.setUnits(xunits);
  
  varargout{1} = obj;
end

