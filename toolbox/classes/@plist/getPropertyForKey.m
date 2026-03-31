% GETPROPERTY get a property from a specified parameter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETPROPERTY get a property from a specified parameter. If
%              the property name exists then it returns the value otherwise
%              an empty array ([]).
%
% CALL:        obj = obj.getProperty(key, propertyName);
%
% INPUTS:      key:          Key for the parameter
%              propertyName: Property name of the value
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function val = getPropertyForKey(obj, key, propertyName)

  if nargin ~= 3
    error('### This method works only with three inputs.');
  end
  
  val = [];
  for ii = 1:numel(obj.params)
    if any(strcmpi(obj.params(ii).key, key))
      val = obj.params(ii).getProperty(propertyName);
      break;
    end
  end
  
end
