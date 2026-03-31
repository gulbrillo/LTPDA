% SETOBJS sets the 'objs' property of a collection object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETOBJS sets the 'objs' property of a collection object.
%
% CALL:        obj = setObjs(obj, val)
%              obj = obj.setObjs(plist('objs', ltpda_uoh-objects);
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'setObjs')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setObjs(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check if this is a call from a class method
  if utils.helper.callerIsMethod
    
    % Internal call: Only one object + don't look for a plist
    varargin{1} = copy(varargin{1}, nargout);
    
    for ii = 1:numel(varargin{1})
      varargin{1}(ii).objs = varargin{2};
    end
    varargout{1} = varargin{1};
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all collection objects
  [colls, colls_invars, rest] = utils.helper.collect_objects(varargin(:), 'collection', in_names);
  
  % Identify the objects which should go into the collection.
  [inobjs, plConfig] = collection.identifyInsideObjs(rest{:});
  
  % Remove the 'names' because identifyInsideObjs always makes some default
  % names, but setObjs doesn't support setting names.
  plConfig.remove('names');
  
  % Apply defaults
  plConfig = applyDefaults(getDefaultPlist(), plConfig);
    
  % Decide on a deep copy or a modify
  colls = copy(colls, nargout);
  
  % Loop over all objects objects
  for jj=1:numel(colls)
    
    histories = [];
    inplists  = [];
    colls(jj).objs = inobjs;
    
    % The history of the objects with history will go into the history of
    % the collection and the inside PLISTs must go into the plistUsed
    % because they doesn't have history.
    for rr=1:numel(inobjs)
      if isa(inobjs{rr}, 'ltpda_uoh')
        histories = [histories inobjs{rr}.hist];
      else
        inplists = [inplists inobjs{rr}];
      end
    end
    
    if ~isempty(inplists)
      plh = plConfig.combine(plist('objs', {inplists}));
    else
      plh = plConfig;
    end

    % reset field names
    names = {};
    for kk=1:numel(colls(jj).objs)
      names{kk} = sprintf('obj%d', kk);
    end
    colls(jj).names = names;
    
    % Add history from the collection and all the input variables
    colls(jj).addHistory(getInfo('None'), plh, colls_invars(jj), [colls(jj).hist histories]);
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, colls);
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

