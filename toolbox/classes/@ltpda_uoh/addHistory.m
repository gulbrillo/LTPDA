% ADDHISTORY Add a history-object to the ltpda_uo object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Add a history-object to the ltpda_uoh object.
%
% CALL:        obj = addHistory(obj, minfo, h_pl, var_name, inhists, ...);
%              obj = addHistory(obj, minfo, h_pl, var_name, ismodifier, inhists, ...);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = addHistory(varargin)

  persistent lastProcTime;
  
  
  % The object to add history to
  obj = varargin{1};

  %%% Decide on a deep copy or a modify
  obj = copy(obj, nargout);
  
  % Copy the history plist because we may modify it below
  if isa(varargin{3}, 'plist')
    pl = copy(varargin{3},1);
  else
    pl = varargin{3};
  end

  %%% Add history to all objects
  for ii = 1:numel(obj)
    
    if ~isempty(pl)
      pl.prepareForHistory();      
    end
    
    % Remove the 'sets' and the corresponding 'plists' from the minfo
    % object. They are not important for the history step.
    varargin{2}.clearSets();
    
    % handle processing time
    t0 = time();
    proctime = t0.utc_epoch_milli;
    
    if isempty(lastProcTime)
      lastProcTime = proctime;
    else
      if proctime == lastProcTime
        proctime = proctime+1;
      end
      lastProcTime = proctime;
    end
    
    % set UUID
    uuid = char(java.util.UUID.randomUUID);
    obj(ii).UUID = uuid;
    
    h = history(proctime, varargin{2}, pl, varargin{4}, uuid, varargin{5:end});
    h.setObjectClass(class(obj(ii)));
    
    % store context
    stack = dbstack('-completenames');
    names = {stack.name};
    
    % filter out some exceptions
    idx   = strcmp(names, 'LTPDAPipeline.runStep');
    stack = stack(~idx);    
    names = {stack.name};
    
    % try to get a package or class
    for kk=1:numel(stack)
      tks = regexp(stack(kk).file, ['\+(\w*)' filesep], 'tokens');
      if ~isempty(tks)
        names{kk} = [tks{1}{1} '.' names{kk}];
      end
      tks = regexp(stack(kk).file, ['\@(\w*)' filesep], 'tokens');
      if ~isempty(tks)
        name = names{kk};
        parts = regexp(name, '\.', 'split');
        names{kk} = [tks{1}{1} '.' parts{end}];
      end
    end
    
    % set context
    h.setContext(names);
    
    % set history
    obj(ii).setHist(h);    
    
  end

  %%% Prepare output
  varargout{1} = obj;
end
