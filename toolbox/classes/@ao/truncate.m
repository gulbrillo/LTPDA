% TRUNCATE Splits Analysis Objects over a common timespan
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Splits Analysis Objects over a common timespan
%
% CALL:        as = truncate(a1,a2,a3,...)
%              as = truncate(as)
%              as = as.truncate()
%
% INPUTS:      aN   - input analysis objects (tsdata)
%              as   - input analysis objects array (tsdata)
%
% OUTPUTS:     as  - a vector of timespan object, of which:
%                     The start time is the earliest one
%                     % The end time is the latest one
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'truncate')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = truncate(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  if ~callerIsMethod
    % Collect all AOs
    [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
    tsao = [];
    tsao_invars = {};
    for ll = 1:numel(as)
      if isa(as(ll).data, 'tsdata')
        tsao        = [tsao as(ll)];
        tsao_invars = [tsao_invars ao_invars(ll)];
      else
        warning('### truncate requires tsdata (time-series) inputs. Skipping AO %s. \nREMARK: The output doesn''t account for this AO', ao_invars{ll});
      end
    end
    inhists = [tsao(:).hist];
  else
    
    % Assume the input is a vector of timeseries AOs
    tsao = varargin{1};
  end
  
  ts_com = getCommonInterval(tsao);
  if ts_com.nsecs == 0
    warning('Could not find a common interval for this data set. Splitting will produce empty results!');
  end
  tsao = split(tsao, plist('timespan', ts_com));
  if any(diff(tsao.len))
    % In some obscure cases the objects could not the same length.
    % Make sure that they have the same length.
    minLen = min(tsao.len);
    tsao = split(tsao, plist('samples', [1 minLen]));
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, tsao);
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
  ii.setModifier(false);
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

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = buildplist()
  pl = plist();
    
end
