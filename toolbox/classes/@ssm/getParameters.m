% getParameters returns parameter values for the given names.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:  getParameters returns parameter values for the given
%               names.
%
% CALL:
%                vals = getParameters(sys, options)
%
% INPUTS:
%                sys     -   ssm objects
%                options -   plist of options:
%
% OUTPUTS:
%                vals - an array of values, 1 value for each of the specified
%                       names found in the model. For multiple input models, the
%                       output values will be a cell-array of numeric vectors,
%                       one cell per input system.
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'getParameters')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = getParameters(varargin)
  
  %% starting initial checks
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin, in_names{ii} = inputname(ii); end
  
  % Collect all SSMs and options
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl,  pl_invars,  rest] = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  %% processing input
  paramNames = pl.find('names');
  if ischar(paramNames)
    paramNames = {paramNames};
  elseif ~iscellstr(paramNames)
    error('param names be a cellstr')
  end
  
  utils.helper.msg(utils.const.msg.PROC1, 'looking for:');
  for jj=1:numel(paramNames)
    utils.helper.msg(utils.const.msg.PROC1, '       %s', paramNames{jj});
  end
  
  %% Loop over systems
  vals = cell(numel(sys),1);
  for jj=1:numel(sys)
    % loop over param names
    svals = [];
    for kk=1:numel(paramNames)
      svals = find(sys(jj).params, paramNames{kk});
    end
    vals{jj} = svals;
  end
  
  if nargout == numel(vals)
    varargout{:} = vals{:};
  else
    varargout{1} = vals;
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
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  pl = plist();
  
  p = param({'names', 'A cell-array of parameter names to get the values of.'}, {} );
  pl.append(p);
  
end

