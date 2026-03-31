% getCommonInterval Estimates the common interval spun by a group of Analysis Objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Estimates the common interval spun by a group of Analysis Objects
%
% CALL:        ts = getCommonInterval(a1,a2,a3,...)
%              ts = getCommonInterval(as)
%              ts = as.getCommonInterval()
%
% INPUTS:      aN   - input analysis objects (tsdata)
%              as   - input analysis objects array (tsdata)
%
% OUTPUTS:     ts  - a timespan object, of which:
%                     The start time is the earliest one
%                     % The end time is the latest one
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'getCommonInterval')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getCommonInterval(varargin)
  
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
    data = [];
    tsao_invars = {};
    for ll = 1:numel(as)
      if isa(as(ll).data, 'tsdata')
        data        = [data as(ll)];
        tsao_invars = [tsao_invars ao_invars(ll)];
      else
        warning('### getCommonInterval requires tsdata (time-series) inputs. Skipping AO %s. \nREMARK: The output doesn''t account for this AO', ao_invars{ll});
      end
    end
    inhists = [data(:).hist];
  else
    
    % Assume the input is a vector of timeseries AOs
    data = varargin{1};
  end
  
  firstT0 = data(1).t0;
  start = -Inf;
  stop  = Inf;
  for jj = 1:numel(data)
    t = data(jj).data.getX;
    dt0 = double(data(jj).data.t0 - firstT0);
    % Find max start time
    dstart = dt0 + t(1);
    if dstart > start
      start = dstart;
    end
    
    % Find min stop time
    dstop = dt0 + t(end) + 1/data(jj).fs;
    if dstop < stop
      stop = dstop;
    end
  end
  
  start = start + firstT0;
  stop  = stop + firstT0;
  
  if start <= stop
    out = timespan(start, stop);
  else
    warning('Could not find a common interval for this data set.');
    out = timespan();
  end
  
  if ~callerIsMethod
    % Set name
    out.name = sprintf('%s(%s)', mfilename, tsao_invars{jj});
    % Add history
    out.addHistory(getInfo, pl, [tsao_invars(:)], inhists);
  end
      
  % Set output
  varargout = utils.helper.setoutputs(nargout, out);
  
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

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end
