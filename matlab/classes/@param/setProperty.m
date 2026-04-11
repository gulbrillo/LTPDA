% SETPROPERTY set a property to a parameter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETPROPERTY set a property to a parameter. If the property
%              name exists then replace the value otherwise add this
%              property.
%
% CALL:        obj = obj.setProperty(propertyName, val);
%
% INPUTS:      propertyName: Property name of the paramValue object
%              value:        Value of the property
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = setProperty(obj, propertyName, value)
  
  if nargin ~= 3
    error('### This method works only with three inputs.');
  end
  
  if ~isempty(obj.val)
    obj = copy(obj, nargout);
    
    % if the value is not a paramValue, we need to promote it before
    % setting the property.
    if ~isa(obj.val, 'paramValue')
      obj.val = paramValue(1, {obj.val});
    end
    
    obj.val.setProperty(propertyName, value);
  else
    error('### There is no value set! Therefore it is not possible to set for this value a property.')
  end
  
end
