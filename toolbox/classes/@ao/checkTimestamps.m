% CHECKTIMESTAMPS performs a check on the timestamps of the input AOs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHECKTIMESTAMPS performs a check on the timestamps of the input AOs.
%
% The method produces new AOs which contain the difference of the x-values
% (timestamps) in the y field. The method produces a plot of this and
% returns the plotted AO.
% 
% CALL:        ao = checkTimestamps(ao, pl)
%
% PARAMETERS:
%
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'checkTimestamps')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = checkTimestamps(varargin)
  
  %%% Check if this is a call for parameters
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
  [as, ao_invars,rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pls,  invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
  
  %%% Combine plists
  pl = applyDefaults(getDefaultPlist, pls);
  
  % Always copy the input
  bs = copy(as, 1);
  
  % Loop over AOs
  for jj = 1:numel(bs)
    
    if ~isa(bs(jj).data, 'tsdata')
      warning('Skipping object [%s] -- it is not a timeseries', bs(jj).name);
      continue;
    end
    
    % convert to cdata
    xdata = bs(jj).convert(plist('action', 'to tsdata', 'xaxis', 'x', 'yaxis', 'x'));
    
    dx = diff(xdata, plist('method', 'diff'));
    dx.setPlotLineStyle('none');
    dx.setPlotMarker('.');
    dx.setPlotMarkersize(20);
    
    % plot
    hfig = iplot(dx, plist('yscales', {'all', 'log'}));
    title(strrep(sprintf('Timestamp diffs of %s', bs(jj).name), '_', '\_'));
    set(hfig, 'Name', sprintf('Timestamp diffs of %s', bs(jj).name));
    
    % store for output
    bs(jj) = dx;
    
    % set name
    bs(jj).setName(sprintf('checkTimestamps(%s)', bs(jj).name));
    
    % Set history
    bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
    
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

  pl = plist();
  
end

