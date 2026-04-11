% GETPROPERTY get a property from a parameter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETPROPERTY get a property from a parameter. If the property
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
  
  if ~isa(obj.val, 'paramValue')
    val = [];
    return
  end
  
  if ~isempty(obj.val)
    if isfield(obj.val.property, propertyName)
      val = obj.val.property.(propertyName);
    else
      val = [];
    end
  else
    val = [];
  end
  
end
