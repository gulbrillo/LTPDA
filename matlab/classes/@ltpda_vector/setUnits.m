% SETUNITS Set the property 'units'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'units'.
%
% CALL:              obj.setUnits('units');
%              obj = obj.setUnits('units'); create copy of the object
%
% INPUTS:      obj   - must be a single ltpda_vector object.
%              units - unit object or a valid string which can be transformed
%                      into a unit object.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setUnits(varargin)

  obj = varargin{1};
  val = varargin{2};

  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);

  obj.units = val;

  varargout{1} = obj;
end

