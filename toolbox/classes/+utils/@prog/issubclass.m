function res = issubclass(classname, superclassname)
  
  res = checkIsSubclass(classname, superclassname, false);
  
end

function res = checkIsSubclass(classname, superclassname, res)
  
  m = meta.class.fromName(classname);
  if ~isempty(m)
    % check this level
    try
      % For matlab version from R2011a
      scl = m.SuperclassList;
    catch
      % For matlab version up to R2010b
      scl = [m.SuperClasses{:}];
    end
    
    for ll=1:numel(scl)
      
      if strcmp(scl(ll).Name, superclassname)
        res = true;
        return;
      end      
    end
    
    % check parents
    for ll=1:numel(scl)
      res = checkIsSubclass(scl(ll).Name, superclassname, res);
    end
    
  end
  
end
