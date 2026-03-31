% SETXUNITS sets the 'xunits' property of the smodel object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETXUNITS sets the 'xunits' property of the smodel object.
%
% CALL:        objs.setXunits(val);
%              objs.setXunits(plist('xunits', val));
%              objs = objs.setXunits(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:  Can be one of the following types:
%                     - unit-string
%                     - unit-object
%                     - plist with the key 'xunits'
%                     - cell with the types above
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'setXunits')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setXunits(varargin)
  
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
    pls                   = utils.helper.collect_objects(rest(:), 'plist');
    
    % Get values for the smodel objects
    values = processValues([], rest);
    
    % Combine input plists and default PLIST
    pls = applyDefaults(getDefaultPlist(), pls);
    
  end % callerIsMethod
  
  % Decide on a deep copy or a modify
  sm = copy(sm, nargout);
  
  % Loop over smodel objects
  for jj = 1:numel(sm)
    sm(jj).xunits = values;
    if ~callerIsMethod
      plh = pls.pset('xunits', values);
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
% Process Values
%--------------------------------------------------------------------------
function values = processValues(values, rest)
    
  switch class(rest)
    case 'char'
      values = [values unit(rest)];
    case 'unit'
      values = [values reshape(rest, 1, [])];
    case 'cell'
      for ii = 1:numel(rest)
        values = processValues(values, rest{ii});
      end
    case 'plist'
      if length(rest) == 1 && isa(rest, 'plist') && isparam_core(rest, 'xunits')
        vals = find_core(rest, 'xunits');
        values = processValues(values, vals);
      end
    otherwise
      error('LTPDA:err:UnsupportedClass', 'Unsupported container ''%s'' for the [Xunits] property', class(rest));
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
  pl = plist({'xunits', 'The units for the X variable.'}, paramValue.EMPTY_STRING);
end
