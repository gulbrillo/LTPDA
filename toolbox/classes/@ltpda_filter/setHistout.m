% SETHISTOUT sets the 'histout' property of the filter object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETHISTOUT sets the 'histout' property of the filter object.
%
% CALL:        objs.setHistout(val);
%              objs.setHistout(val1, val2);
%              objs.setHistout(plist('histout', val));
%              objs = objs.setHistout(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:  numeric vector or an AO which y-values are taken for the Histout
%                 1. Single vector e.g.
%                      Each filter object in objs get this value.
%                 2. Single vector in a cell-array e.g. {[1 2 3]}
%                      Each filter object in objs get this value.
%                 3. cell-array with the same number of vectors as in objs
%                    e.g. {ao, [1 2 3], ao} and 3 filter object in objs
%                      Each filter object in objs get its corresponding
%                      value from the cell-array
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_filter', 'setHistout')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setHistout(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    sm     = varargin{1};
    values = varargin(2:end);
    
  else
    % Check if this is a call for parameters
    if utils.helper.isinfocall(varargin{:})
      varargout{1} = getInfo(varargin{3});
      return
    end
    
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Collect all filter objects
    [sm,  sm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ltpda_filter', in_names);
    [pls, invars,    rest] = utils.helper.collect_objects(rest(:), 'plist');
    
    % Define property name
    pName = 'histout';
    
    % Get values for the filter objects
    [sm values] = processSetterValues(sm, pls, rest, pName);
    
    % Combine input plists and default PLIST
    pls = applyDefaults(getDefaultPlist(), pls);
    
  end % callerIsMethod
  
  % Decide on a deep copy or a modify
  sm = copy(sm, nargout);
  
  % Loop over filter objects
  for j=1:numel(sm)
    sm(j).histout = values{j};
    if ~callerIsMethod
      plh = pls.pset(pName, values{j});
      sm(j).addHistory(getInfo('None'), plh, sm_invars(j), sm(j).hist);
    end
  end
  
  % Set output
  nObjs = numel(sm);
  if nargout == nObjs;
    % List of outputs
    for ii = 1:nObjs
      varargout{ii} = sm(ii);
    end
  else
    % Single output
    varargout{1} = sm;
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
  pl = plist({'histout', 'Output history of the filter.'}, paramValue.EMPTY_DOUBLE);
end
