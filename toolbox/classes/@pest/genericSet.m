% GENERICSET sets values to a pest property.
% 
% CALL: 
%       out = genericSet(args, paramName, in_names, callerIsMethod);
% 

function out = genericSet(varargin)
  
  pName          = varargin{end-2};
  in_names       = varargin{end-1};
  callerIsMethod = varargin{end};
  args = varargin(1:end-3);
  
  if callerIsMethod
    objs   = varargin{1};
    values = varargin(2:end-3);
  else
    
    % Collect all Objects
    [objs, objs_invars, rest] = utils.helper.collect_objects(args(:), '', in_names);
    [pls,  invars, values]    = utils.helper.collect_objects(rest(:), 'plist');
    
    %%% If pls contains only one plist with the single property-key then set
    %%% the property with a plist.
    if length(pls) == 1 && isa(pls, 'plist') && nparams(pls) == 1 && isparam_core(pls, pName)
      values{1} = find_core(pls, pName);
    end

    % Get minfo-object
    mi  = objs.getInfo(sprintf('set%s%s', upper(pName(1)), pName(2:end)));
    dpl = mi.plists;
    
    % Combine input plists and default PLIST
    pls = applyDefaults(dpl, pls);
    
  end % callerIsMethod
  
  % Decide on a deep copy or a modify
  objs = copy(objs, nargout);
  
  % Loop over AOs
  for j=1:numel(objs)
    objs(j).(pName) = values(:);
    if ~callerIsMethod
      plh = pls.pset(pName, objs(j).(pName));
      objs(j).addHistory(objs.getInfo(sprintf('set%s%s', upper(pName(1)), pName(2:end)), 'None'), plh, objs_invars(j), objs(j).hist);
    end
  end
  out = objs;
  
end

