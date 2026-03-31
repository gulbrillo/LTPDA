% OP Add a operation around the model expression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: OP Add a operation around the model expression
%
% CALL:        obj = obj.op('sin');
%              obj = obj.op(plist('operator', 'sin'));
%
% INPUTS:      obj - one ltpda model.
%              pl  - to set the name with a plist specify only one plist with
%                    only one key-word 'operator'.
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'op')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = op(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if ~callerIsMethod
    %%% Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    [objs, obj_invars, rest] = utils.helper.collect_objects(varargin(:), '', in_names);
    [pls,  invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
        
    %%% Combine plists    
    pls = applyDefaults(getDefaultPlist(), pls);
    
    % Search for the user input operator 
    op = find_core(pls, 'operator');    
    if ~isempty(rest)
      op = rest{1};
      pls.pset('operator', op);
    end
    
    if isempty(op)
      error('### Please specify one operator-string, either in a plist or directly.');
    end
  else
      % Simple call, in the form op(mdls, operator)
      objs = varargin{1};
      op   = varargin{2};
  end
  
  %%% Set the 'values'
  for ii = 1:numel(objs)
    
    %%% decide whether we modify the input smodel object, or create a new one.
    objs(ii) = copy(objs(ii), nargout);
    
    %%% set the value
    objs(ii).expr.s = [op '(' objs(ii).expr.s ')'];
    if ~callerIsMethod
      objs(ii).name   = [op '(' objs(ii).name ')'];
      objs(ii).addHistory(getInfo('None'), pls, obj_invars(ii), objs(ii).hist);
    end
  end
  
  %%% Set output
  if nargout == numel(objs)
    % List of outputs
    for ii = 1:numel(objs)
      varargout{ii} = objs(ii);
    end
  else
    % Single output
    varargout{1} = objs;
  end
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  
  pl = plist();
  
  % Operator
  p = param({'Operator', 'The operator to apply.'}, paramValue.EMPTY_STRING);
  pl.append(p);
end

