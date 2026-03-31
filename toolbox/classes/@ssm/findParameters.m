% findParameters returns parameter names matching the given pattern.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:  findParameters returns parameter names matching the given
%               pattern.
%
% CALL:
%                names = findParameters(sys, options)
%
% INPUTS:
%                sys     -   ssm objects
%                options -   plist of options
%
% OUTPUTS:
%           names - a cell-array of matches, one cell per input pattern.
%                   Each cell can contain a cell-array of matched parameter
%                   names.
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'findParameters')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = findParameters(varargin)
  
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
  [pl, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  % ... and from the plist
  patterns = find(pl, 'patterns');
  fieldName = find(pl, 'field');
  if ~iscell(patterns), patterns = {patterns}; end
  
  utils.helper.msg(utils.const.msg.PROC1, 'matching against:');
  for jj=1:numel(patterns)
    utils.helper.msg(utils.const.msg.PROC1, '       %s', patterns{jj});
  end
  
  % Loop over input systems
  parameters = plist.initObjectWithSize(numel(sys),1);
  for jj=1:numel(sys)
    % loop over patterns
    snames = {};
    switch lower(fieldName)
      case 'params'
        plparams = sys(jj).params;
      case 'numparams'
        plparams = sys(jj).numparams;
      otherwise
        error('The only possibilities for the option "field" are "params" and "numparams".')
    end
    
    for kk=1:numel(patterns)
      for ll=1:plparams.nparams
        res = regexp(plparams.params(ll).key, patterns{kk}, 'match');
        if ~isempty(res)
          snames = [snames plparams.params(ll).key]; %#ok<AGROW>
        end
      end
    end
    if ~isempty(snames)
      parameters(jj) = copy( plparams.subset(snames), 1);
    end
  end
  
  % Set outputs
  if nargout == numel(parameters)
    for ii=1:numel(parameters)
      varargout{ii} = parameters(ii);
    end
  else
    varargout{1} = parameters;
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
  
  % keys
  p = param({'patterns', 'patterns to search for in the plist.'},  paramValue.EMPTY_CELL );
  pl.append(p);
  % plist
  p = param({'field','Choose to look for in the field params or numparams.'},...
    {1, {'params', 'numparams'}, paramValue.SINGLE});
  pl.append(p);
  
end

