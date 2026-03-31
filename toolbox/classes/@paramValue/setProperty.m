% SETPROPERTY set a property to a paramValue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETPROPERTY set a property to a paramValue. If the property
%              name exists then replace the value otherwise add this
%              property.
%
% CALL:        obj = obj.setProperty(propertyName, value);
%
% INPUTS:      propertyName: Property name of the paramValue object
%              value:        Value of the property
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = setProperty(obj, propertyName, value)
  
  if nargin ~= 3
    error('### This method works only with three inputs.');
  end
  
  obj = copy(obj, nargout);

  if isempty(obj.property)
    % ATTENTION: It is necessary for the STRUCT method to use a different
    %            command if the value is a cell.
    if iscell(value)
      obj.property = struct(propertyName, {value});
    else
      obj.property = struct(propertyName, value);
    end
  else
    obj.property.(propertyName) = value;
  end
  
end
