% ADDOBJECTS adds the given objects to the collection.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ADDOBJECTS adds the given objects to the collection.
%
% CALL:        col = addObjects(col, obj1, obj2, ...)
%              col = addObjects(col, 'name1', obj1, 'name2', obj2, ...)
%              obj = obj.addObjects(plist('objs', objects));
%              obj = obj.addObjects(plist('objs', objects, 'names', names));
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'addObjects')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = addObjects(varargin)
  
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
  
  % Collect the first input
  col = varargin{1};
  col_invars = inputname(1);
  if isempty(col_invars)
    col_invars = '';
  end
  
  % collect the other inputs
  rest = varargin(2:end);
  
  % Identify the objects which should go into the collection.
  [inobjs, plConfig] = collection.identifyInsideObjs(rest{:});
  
  % Decide on a deep copy or a modify
  col = copy(col, nargout);
  
  % Loop over all collection objects objects
  histories = [];
  inplists  = [];
  
  % Add new inside objects.
  newNames = plConfig.find_core('names');
  allNames = [col.names newNames];
  % Make sure that we don't have any duplicates
  allNames = utils.helper.createUniqueNames(allNames);
  % Make sure that also the history PLIST have the unique names of the NEWNAMES
  plConfig.pset('names', allNames(end-numel(newNames)+1:end));
  
  col.objs  = [col.objs, inobjs];
  col.names = allNames;
  
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
  
  % Add history from the collection and all the input variables
  col.addHistory(getInfo('None'), plh, {col_invars}, [col.hist histories]);  
  
  % Set output
  if nargout == numel(col)
    % List of outputs
    for ii = 1:numel(col)
      varargout{ii} = col(ii);
    end
  else
    % Single output
    varargout{1} = col;
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
  pl = plist();
  
  p = param({'objs', 'The inside objects to set.<br>Please use a cell array if the objects are not from the same type.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'names', 'The fieldnames to assign to the inside objects.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
end

