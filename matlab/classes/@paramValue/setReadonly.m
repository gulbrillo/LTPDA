% SETREADONLY sets the readonly flag of the paramValue object.
function varargout = setReadonly(obj, val)
  
  obj = copy(obj, nargout);
  obj.readonly = val;
  varargout{1} = obj;
  
end