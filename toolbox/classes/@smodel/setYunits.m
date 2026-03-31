% SETYUNITS sets the 'yunits' property of the smodel object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETYUNITS sets the 'yunits' property of the smodel object.
%
% CALL:        objs.setYunits(val);
%              objs.setYunits(val1, val2);
%              objs.setYunits(plist('yunits', val));
%              objs = objs.setYunits(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:
%                 1. Single string e.g. 'Hz'
%                      Each smodel object in objs get this value.
%                 2. Single string in a cell-array e.g. {'Hz'}
%                      Each smodel object in objs get this value.
%                 3. cell-array with the same number of strings as in objs
%                    e.g. {'Hz', 'V', 's'} and 3 smodel object in objs
%                      Each smodel object in objs get its corresponding
%                      value from the cell-array
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'setYunits')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setYunits(varargin)
  
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
    
    % Collect all smodel objects
    [sm,  sm_invars, rest] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
    [pls, invars,    rest] = utils.helper.collect_objects(rest(:), 'plist');
    
    % Define property name
    pName = 'yunits';
    
    % Get values for the smodel objects
    [sm, values] = processSetterValues(sm, pls, rest, pName);
    
    % Combine input plists and default PLIST
    pls = applyDefaults(getDefaultPlist(), pls);
    
  end % callerIsMethod
  
  % Decide on a deep copy or a modify
  sm = copy(sm, nargout);
  
  % Loop over smodel objects
  for jj = 1:numel(sm)
    sm(jj).yunits = values{jj};
    if ~callerIsMethod
      plh = pls.pset(pName, values{jj});
      sm(jj).addHistory(getInfo('None'), plh, sm_invars(jj), sm(jj).hist);
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, sm);

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
  pl = plist({'yunits', 'The units for the Y variable.'}, paramValue.EMPTY_STRING);
end
