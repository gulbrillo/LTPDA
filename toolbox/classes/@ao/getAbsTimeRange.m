% GETABSTIMERANGE returns a timespan object which span the absolute time range of an AO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETABSTIMERANGE returns a timespan object which span the
%              absolute time range of an AO.
%
% CALL:        ts = getAbsTimeRange(a1,a2,a3,...)
%              ts = as.getAbsTimeRange()
%
% INPUTS:      aN   - input analysis objects
%
% OUTPUTS:     ts   - timespan objects
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'getAbsTimeRange')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getAbsTimeRange(varargin)
  
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
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  allts = [];
  for ii=1:numel(as)
    a = as(ii);
    x = a.x;
    
    % Check if we have a time-series AO otherwise skip the AO
    if ~isa(a.data, 'tsdata')
      warning('!!! The AO [%s] is not a time-series AO. Skip this AO.', ao_invars{ii})
      continue
    end
    
    % Compute staet and ent time of the timespan object.
    startTime = time(a.t0.double+x(1));
    endTime   = time(a.t0.double+x(end) + 1/a.fs);
    
    % Build timespan object and add history
    ts = timespan(startTime, endTime);
    ts.setName(a.name);
    ts.addHistory(getInfo('None'), plist(), ao_invars(ii), [a.hist]);
    
    allts = [allts ts];
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, allts);
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
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
  
  % General plist for Welch-based, linearly spaced spectral estimators
  pl = plist();
  
end

