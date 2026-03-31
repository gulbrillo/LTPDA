% getGeneralInterval Estimates the maximum interval spun by a group of Analysis Objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Estimates the maximum interval spun by a group of Analysis Objects
%
% CALL:        ts = getGeneralInterval(a1,a2,a3,...)
%              ts = getGeneralInterval(as)
%              ts = as.getGeneralInterval()
%
% INPUTS:      aN   - input analysis objects (tsdata)
%              as   - input analysis objects array (tsdata)
%
% OUTPUTS:     ts  - a timespan object, of which:
%                     The start time is the earliest one
%                     % The end time is the latest one
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'getGeneralInterval')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getGeneralInterval(varargin)
  
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
        warning('### getGeneralInterval requires tsdata (time-series) inputs. Skipping AO %s. \nREMARK: The output doesn''t account for this AO', ao_invars{ll});
      end
    end
    inhists = [tsao(:).hist];
  else
    
    % Assume the input is a vector of timeseries AOs
    tsao = varargin{1};
  end
  
  for jj = 1:numel(tsao)
    t  = tsao(jj).x;
    t0 = tsao(jj).t0;
    
    tstart(jj)  = t0 + t(1);
    tstop(jj)   = t0 + t(end);
  end
  
  % The reference time for starting is the most frequent one
  reference = mode(tstart);
  
  % The start time is the earliest one
  start     = min(tstart);
  
  % The end time is the latest one
  stop      = max(tstop);
  
  out = timespan(start, stop);
  out.procinfo = plist('reference', reference);
  
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
