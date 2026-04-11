function varargout = subsref(a, s)
  if numel(a) == 1 && numel(s) == 1 && strcmp(s.type, '()')
    varargout{1} = a.eval(s.subs{:});
  else
    % if we didn't return already, call the built-in MATLAB subsref
    % WARNING: this usage of varargout is essential. DO NOT CHANGE IT.
    [varargout{1:nargout}] = builtin('subsref', a, s);
  end
  
end