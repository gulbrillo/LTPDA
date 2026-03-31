function obj = saveobj(obj)
    
  if ~isempty(obj.historyArray)
    % MATLAB does a double pass save, firs calculating the size, then doing
    % the save, but we only need to compress on the first pass. This only
    % happens with saving v7.0 files.
    return;
  end
  if isempty(obj.hist)
    % It is possible that LTPDA objects doesn't have any history. In this
    % case is it not possible to compress the history.
    return
  end
  
  % It is necessary to copy the objects before compressing the history.
  % Otherwise it modifies the object with a 'modifier' command. Checking
  % the output (nargout) will not help for detecting a modifier command
  % because the following code modifies the objects but it uses an output:
  %   a = ao.randn(10,10);
  %   s.data = a;
  %   save('my_struct.mat', 's')
  %   a.hist
  obj = copy(obj, 1);
  
  % compress the history
  hists = compressHistory(obj.hist);
  
  obj.hist = obj.hist.UUID;
  obj.historyArray = hists; 
end

% END