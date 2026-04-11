% SETREADONLY sets the readonly flag of the param object and (if existing)
% the paramValue object.
function varargout = setReadonly(objs, val)
  
  objs = copy(objs, nargout);
  
  for kk=1:numel(objs)
    obj = objs(kk);
    if isa(obj.val, 'paramValue')
      setReadonly(obj.val, val);
    end
    obj.readonly = val;
  end
  
  varargout{1} = objs;
end