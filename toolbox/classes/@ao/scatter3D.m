% SCATTER3D Creates from the y-values of the input AOs a new AO with a xyz-data object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SCATTER3D Creates from the y-values of the input AOs a new
%              AO with a xyz-data object.
%
% CALL:        b = scatter3D(a1, a2, ..., pl)
%
% INPUTS:      aN   - input analysis objects
%              pl   - input parameter list
%
% OUTPUTS:     b    - output analysis object
%
% Possible actions:
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'scatter3D')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = scatter3D(varargin)
  
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
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % parameters
  yvals = pl.find('yvals');
  
  % Check the length of input AOs
  if any(diff(as.len))
    error('### The length of all input AOs must be the same.');
  end
  
  % Check if all AOs are analysis objects with time-series data
  allTsdata = false;
  if all(arrayfun(@(x) isa(x, 'tsdata'), [as.data]))
    allTsdata = true;
  end
  
  
  % deal with y values
  dy = [];
  yunits = [];
  if isempty(yvals)
    yvals = zeros(1, numel(as));
    for kk=1:numel(as)
      yvals(kk) = as(kk).x(1);
    end
  else
    if isa(yvals, 'ao')
      dy     = yvals.dy;
      yunits = yvals.yunits;
      yvals  = yvals.y;
    end
    
    if numel(yvals) ~= numel(as)
      error('The number of y-values (%d) does not match the number of input objects for the z-values (%d)', numel(yvals), numel(as));
    end
  end
  
  % form z data
  data = zeros(numel(as), as(1).len);
  dz   = zeros(numel(as), as(1).len);
  for kk=1:numel(as)
    data(kk,1:as(1).len) = as(kk).y';
    dz(kk,1:as(1).len) = as(kk).dy';
  end
  
  if allTsdata
    % for tsdata
    if pl.find_core('x shift')
      bs = ao(xyzdata(as(1).x - as(1).x(1), yvals, data));
    else
      bs = ao(xyzdata(as(1).x, yvals, data));
    end
  else
    % for fsdata or xydata
    bs = ao(xyzdata(as(1).x, 1:numel(as), data));
  end
  
  % deal with errors
  bs.data.setDx(as(1).dx);
  bs.data.setDy(dy);
  bs.data.setDz(dz);
  
  % set units
  bs.data.setXunits(as(1).xunits);
  bs.data.setYunits(yunits);
  bs.data.setZunits(as(1).yunits);
  
  % timespan
  bs.timespan = as(1).getAbsTimeRange;
  
  % Set Name, Description and History
  bs.name = sprintf('%s(%s%s)', mfilename(), sprintf('%s, ', ao_invars{1:end-1}), ao_invars{end});
  bs.description = sprintf('%s ', as.description);
  bs.addHistory(getInfo('None'), pl, ao_invars, [as.hist]);
  
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
  
  % x shift
  p = param({'x shift', 'Subtract or not the first x value'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % yvals
  p = param({'yvals', 'Specify the y values for the resulting xyzdata. If an AO is given, the yvalues will be used. Alternatively a numeric vector can be specified. If none are specified, the first x-value from each time-series will be used.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end

