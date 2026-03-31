function res = isprop_core(objs, field)
    
  res = zeros(size(objs));

  if any(strcmp(field, properties(objs)))
    res = ones(size(objs));
  else
    zeros(size(objs));
  end

end
