function obj = wrapperEval(obj, methodName, varargin)
  
  % loop over inner objects
  for kk = 1:numel(obj.objs)
    o = obj.objs(kk);
    if ismethod(o, methodName)
      obj.objs(kk) = feval(methodName, o, varargin{:});
    else
      warning('The %dth object does not have a %s method. Skipping it!', kk, methodName);
    end
  end
  
end
