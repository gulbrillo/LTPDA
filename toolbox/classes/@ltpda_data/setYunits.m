% SETYUNITS Set the property 'yunits'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'yunits'.
%
% CALL:              obj.setYunits('units');
%              obj = obj.setYunits('units'); create copy of the object
%
% INPUTS:      obj   - must be a single ltpda_data (cdata, data2D, data3D) object.
%              units - unit object or a valid string which can be transformed
%                      into a unit object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setYunits(varargin)

  obj = varargin{1};
  val = varargin{2};

  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);

  % set value
  obj.yaxis.setUnits(val);
  
  varargout{1} = obj;
end

