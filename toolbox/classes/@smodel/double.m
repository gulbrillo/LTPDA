% DOUBLE Returns the numeric result of the model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Returns the numeric result of the model.
%
% CALL:        num = obj.double
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'double')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function d = double(varargin)
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod    
  else
    % Check if this is a call for parameters
    if utils.helper.isinfocall(varargin{:})
      d = getInfo(varargin{3});
      return
    end
  end
  
  mdl = varargin{1};
  
  % check the model is valid
  fld = check_model_fields(mdl);
  if ~isempty(fld)
    error(['### The field ' fld ' cannot be empty!']);
  end
  
  % Check 'params' and 'values' have the same length
  if numel(mdl.params) ~= numel(mdl.values)
    error('### The number of parameter names and parameter values must match');
  end
  
  % Check 'aliasNames' and 'aliasValues' have the same length
  if numel(mdl.aliasNames) ~= numel(mdl.aliasValues)
    error('### The number of aliase names and alias values must match');
  end
  
  % Assign locally values for any remaining parameters
  getVariables(mdl.params, mdl.values);
  
  % Assign locally alias names to alias values
  getVariables(mdl.aliasNames, mdl.aliasValues);
  
  % Recover the mapping factor from xvals and xvar
  trans = mdl.trans;
  
  if ~isempty(trans)
    warning('The usage of the ''trans'' option is deprecated and will be removed soon. Please use an alias instead!');
  end
  
  % I need to shape it as the xvar field
  oo = ones(size(mdl.xvar));
  if isempty(trans)
    scale = 1.0 * oo;
  else
    for kk = 1:numel(trans)
      scale(kk) = eval(trans{kk});
    end
    scale = scale .* oo;
  end
  
  % Set local values for the X vector
  for kk = 1:numel(mdl.xvar)
    if ~isempty(mdl.xvals)
      eval(sprintf('%s = scale(%d).*mdl.xvals{%d};', mdl.xvar{kk}, kk, kk));
    else
      eval(sprintf('%s = [];', mdl.xvar{kk}));
    end
  end
  
  % The actual evaluation
  d = eval(mdl.expr.s);
  
  % Support the case of a constant model
  if numel(d) == 1
    % Multiple X variables, choose the first
    d = d .* ones(size(mdl.xvals{1}));
  end
  
  if any(isnan(d))
    warning('!!! Data contain y values equal to NaN');
  end
  if any(isinf(d))
    warning('!!! Data contain y values equal to Inf');
  end

end

%--------------------------------------------------------------------------
% Check Model Fields are correct
%--------------------------------------------------------------------------
function fld = check_model_fields(mdl)
  
  fld = [];
  
  % Check 'expr'
  if isempty(mdl.expr) || isempty(mdl.expr.s)
    fld = 'expr';
    return
  end
  
  % Check 'xvar'
  if isempty(mdl.xvar)
    fld = 'xvar';
    return
  end
  
end

%--------------------------------------------------------------------------
% Assign Variables Values
%--------------------------------------------------------------------------
function getVariables(nms, vals)
  for kk = 1:numel(nms)
    assignin('caller', nms{kk}, vals{kk});
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
  pl = plist.EMPTY_PLIST;
end

