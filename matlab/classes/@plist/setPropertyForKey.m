% SETPROPERTY set a property from a specified parameter to a given value.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: set a property from a specified parameter to a given value.
%              If the property name exists then replace the value otherwise
%              add this property.
%
% CALL:        obj = obj.getProperty(key, propertyName, value);
%
% INPUTS:      key:          Key for the parameter
%              propertyName: Property name of the value
%              value:        Value for the property
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = setPropertyForKey(obj, key, propertyName, val)
  
  % Check inputs
  if nargin ~= 4
    error('### This method works only with four inputs.');
  end
  if numel(obj) ~= 1 || ~isa(obj, 'plist')
    error('### The first input must be a single PLIST object.');
  end
  
  %%% decide whether we modify the first plist, or create a new one.
  obj = copy(obj, nargout);
  
  % Check which parameter match to 'key'
  matches = matchKey_core(obj, key);
  
  if sum(matches) == 1
    obj.params(matches).setProperty(propertyName, val);
  elseif sum(matches) == 0
    warning('LTPDA:plist:setPropertyForKey', '!!! Can not find the ''%s'' key in the PLIST.', key);
  else
    error('### Found the key ''%s'' more than once in the plist. But this shouldn''t happen.', key);
  end
  
end
