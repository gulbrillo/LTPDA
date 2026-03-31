% MERGE the input timespan objects into one output timespan object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MERGE the input timespan objects into one output timespan
%              object. The start time of the output is the earlies of the
%              input start times and the end time of the output is the
%              latest of the input end times.
%
% CALL:        out = merge(ts1, ts2, ts3, ...)
%
% INPUTS:      tsXX  - Timespan object
%
% OUTPUTS:     out   - Timespan object
%
% <a href="matlab:utils.helper.displayMethodInfo('timespan', 'merge')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = merge(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  
  % Collect all AOs and last object as plist
  if callerIsMethod
    tsObjs = [varargin{:}];
  else
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    [tsObjs, ts_invars] = utils.helper.collect_objects(varargin(:), 'timespan', in_names);
    [upl, ~] = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  end
  
  % apply defaults
  pl = applyDefaults(getDefaultPlist, upl);

  % Collect all start and end times.
  allStartTimes = [tsObjs.startT];
  allEndTimes   = [tsObjs.endT];
  
  % Create new timespan object
  outObj = timespan(min([allStartTimes.utc_epoch_milli])/1e3, max([allEndTimes.utc_epoch_milli])/1e3);
  
  if isempty(pl.find('name'))
    outname = tsObjs(1).name;
    for jj=2:numel(tsObjs)
      outname = [outname ', ' tsObjs(jj).name];
    end
    pl.pset('name', outname);
  end
  
  if ~callerIsMethod
    % create new output history
    outObj.addHistory(getInfo('None'), plist(), ts_invars, [tsObjs.hist]);
  end
  
  % Set object properties from the plist
  outObj.setObjectProperties(pl);
  
  % Set output
  varargout{1} = outObj;
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
  
  pl = copy(timespan.getInfo('timespan', 'default').plists);
  
end

