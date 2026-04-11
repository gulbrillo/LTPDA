% GETPROPERTIES return all properties from a parameter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETPROPERTIES return all properties from a parameter.
%
% CALL:        s = obj.getProperties();
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function val = getProperties(obj)

  if nargin ~= 1 && numel(obj) ~= 1
    error('### This method works only with one param object.');
  end
  
  if ~isa(obj.val, 'paramValue')
    val = struct([]); % This is the default value of an empty paramValue object
    return
  end
  
  val = obj.val.property;
  
end
