% SETZUNITS Set the property 'zunits'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'zunits'.
%
% CALL:              obj.setZunits('units');
%              obj = obj.setZunits('units'); create copy of the object
%
% INPUTS:      obj   - must be a single data3D object.
%              units - unit object or a valid string which can be transformed
%                      into a unit object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setZunits(varargin)

  obj = varargin{1};
  val = varargin{2};

  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);

  % set 'zunits'
  if isempty(val)
    zunits = unit();
  elseif ischar(val)
    zunits = unit(val);
  elseif iscell(val)
    zunits = val{1};
  else
    zunits = val;
  end

  obj.zaxis.setUnits(zunits);
  
  varargout{1} = obj;
end

