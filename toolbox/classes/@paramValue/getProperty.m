% GETPROPERTY get a property to a paramValue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETPROPERTY get a property to a paramValue. If the property
%              name exists then it returns the value otherwise an empty
%              array ([]).
%
% CALL:        obj = obj.getProperty(propertyName);
%
% INPUTS:      propertyName: Property name of the paramValue object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function val = getProperty(obj, propertyName)
  
  if nargin ~= 2
    error('### This method works only with two inputs.');
  end
  
  if isfield(obj.property, propertyName)
    val = obj.property.(propertyName);
  else
    val = [];
  end
  
end
