% GETDEFAULTVALUE Returns the default value of a class property.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Returns the default value of a class property if any default
%              value is defined.
%
% CALL:        dv = getDefaultValue(obj, prop);
%
% INPUTS:      obj:  LTPDA object or a class string
%              prop: Property name of the class
%
% OUTPUTS:     dv:   Default value of the property.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dv = getDefaultValue(obj, prop)
  
  % Get the default value of the property from the meta data
  if ischar(obj)
    m = meta.class.fromName('smodel');
  elseif isa(obj, 'ltpda_obj')
    m = metaclass(obj);
  else
    error('### Unknown input. Please use: getDefaultValue(obj, prop)');
  end
  
  p = [m.Properties{:}];
  idx = strcmp({p(:).Name}, prop) & [p.HasDefault];
  
  if any(idx)
    dv = p(idx).DefaultValue;
  else
    error('### Can not find any default value for the [%s] property of the [%s] class', prop, m.Name);
  end

end
