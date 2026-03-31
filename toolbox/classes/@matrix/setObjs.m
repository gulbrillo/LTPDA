% SETOBJS sets the 'objs' property of a matrix object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETOBJS sets the 'objs' property of a matrix object.
%
% CALL:        obj = setObjs(obj, val)
%              obj = obj.setObjs(plist('objs', ltpda_uoh-objects);
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'setObjs')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setObjs(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    objs   = varargin{1};
    rest = varargin(2:end);
    
  else
    %%% Check if this is a call for parameters
    if utils.helper.isinfocall(varargin{:})
      varargout{1} = getInfo(varargin{3});
      return
    end
    
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Collect all ltpdauoh objects
    [objs, objs_invars, rest] = utils.helper.collect_objects(varargin(:), '', in_names);
    [pls, ~, rest] = utils.helper.collect_objects(rest(:), 'plist');
    
    %%% If pls contains only one plist with the single key 'objs' then set the
    %%% property with a plist.
    if length(pls) == 1 && isa(pls, 'plist') && isparam_core(pls, 'objs')
      rest{1} = find_core(pls, 'objs');
      if isparam_core(pls, 'shape')
        rest{1} = reshape(rest{1}, pls.find_core('shape'));
      end
    end
    
    if numel(rest) ~= 1
      error('### Please specify a value for the inner objects, either in a plist or directly.');
    end
    
    %%% Combine plists
    pls = applyDefaults(getDefaultPlist(), pls);
    
  end % callerIsMethod
  
  % Decide on a deep copy or a modify
  objs = copy(objs, nargout);
  
  % Loop over all objects objects
  for j=1:numel(objs)
    objs(j).objs = rest{1};
    if ~callerIsMethod
      pls.pset('objs',  rest{1});
      pls.pset('shape', size(rest{1}));
      objs(j).addHistory(getInfo('None'), pls, objs_invars(j), objs(j).hist);
    end
  end
  
  % Set output
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist({'objs', 'The inner objects to set.'}, paramValue.EMPTY_DOUBLE);
end

