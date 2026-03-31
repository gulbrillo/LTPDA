% PLOT the pest objects on the given axes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLOT the pest objects on the given axes.
%
% CALL:        plot(objs)
%              outputs = plot(objs)
%
% PLOT calls eval() on each pest object then calls ao/plot on
% the resulting AOs.
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'plot')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = plot(varargin)
  
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
  
  % Collect all pest objects
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  pi = bs.plotinfo;
  
  % eval pest
  rs = eval(bs);
  rs.setPlotAxes(pi.axes);
  
  % Plot the ao
  plot(rs);
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.internal, '', sets, pl);
  ii.setModifier(false);
  ii.setOutmin(0);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end

% END


