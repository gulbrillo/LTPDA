% SETEXPR sets the 'expr' property of the smodel object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETEXPR sets the 'expr' property of the smodel object.
%
% CALL:        objs.setExpr(val);
%              objs.setExpr(plist('expr', val));
%              objs.setExpr(plist('expression', val));
%              objs = objs.setExpr(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:  Can be any of the following types:
%                     - string e.g. 'x1'
%                     - msym object e.g. msym('x.^2')
%                     - plist with the key 'expression' or 'expr' e.g. plist('expr', {'x1', 'x2'})
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'setExpr')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setExpr(varargin)
  
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
    pls                    = utils.helper.collect_objects(rest(:), 'plist');
    
    % Combine input plists and default PLIST
    pls = applyDefaults(getDefaultPlist(), pls);
    
    % Get values for the smodel objects
    values = processValues({}, rest);
    
  end % callerIsMethod
  
  % Decide on a deep copy or a modify
  sm = copy(sm, nargout);
  
  % Loop over smodel objects
  for jj = 1:numel(sm)
    sm(jj).expr = values{jj};
    if ~callerIsMethod
      plh = pls.pset('expr', values{jj});
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
% Process Input Values
%--------------------------------------------------------------------------

function values = processValues(values, rest)
  if ~isempty(rest)
    switch class(rest)
      case 'cell'
        for ii = 1:numel(rest);
          values = processValues(values, rest{ii});
        end
      case {'char', 'msym'}
        values = [values {rest}];
      case 'plist'
        if length(rest) == 1 && isa(rest, 'plist') && (isparam_core(rest, 'expr') || isparam_core(rest, 'expression'))
          vals = mfind(rest, 'expression', 'expr');
          values = processValues(values, vals);
        end
      otherwise
    end
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
  
  pl = plist({'expr', 'Specify the expression to be set.'}, paramValue.EMPTY_STRING);
  pl.addAlternativeKeys('expr', 'expression');
  
end
