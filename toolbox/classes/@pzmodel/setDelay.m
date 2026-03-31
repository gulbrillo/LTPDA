% SETDELAY sets the 'delay' property of the pzmodel object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETDELAY sets the 'delay' property of the pzmodel object.
%
% CALL:        objs.setDelay(val);
%              objs.setDelay(val1, val2);
%              objs.setDelay(plist('delay', val));
%              objs = objs.setDelay(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:  numeric value in seconds
%                 1. Single vector e.g. 9
%                      Each pzmodel object in objs get this value.
%                 2. Single vector in a cell-array e.g. {7}
%                      Each pzmodel object in objs get this value.
%                 3. cell-array with the same number of vectors as in objs
%                    e.g. {12, 2, 5} and 3 pzmodel object in objs
%                      Each pzmodel object in objs get its corresponding
%                      value from the cell-array
%
% <a href="matlab:utils.helper.displayMethodInfo('pzmodel', 'setDelay')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setDelay(varargin)
  
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
    
    % Collect all pzmodel objects
    [sm,  sm_invars, rest] = utils.helper.collect_objects(varargin(:), 'pzmodel', in_names);
    [pls, invars,    rest] = utils.helper.collect_objects(rest(:), 'plist');
    
    % Define property name
    pName = 'delay';
    
    % Get values for the pzmodel objects
    [sm, values] = processSetterValues(sm, pls, rest, pName);
    
    % Combine input plists and default PLIST
    pls = applyDefaults(getDefaultPlist(), pls);
    
  end % callerIsMethod
  
  % Decide on a deep copy or a modify
  sm = copy(sm, nargout);
  
  % Loop over pzmodel objects
  for j=1:numel(sm)
    sm(j).delay = values{j};
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
  pl = plist({'delay', 'The delay to set [s].'}, paramValue.DOUBLE_VALUE(0));
end
