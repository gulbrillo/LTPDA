% SETPLOTFILLMARKER defines if the plot function fill the marker or not.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETPLOTFILLMARKER defines if the plot function fill the marker or not.
%
% If the object currently has no plotinfo object defined, a default one is
% created with the chosen style.
%
% CALL:            objs.setPlotFillmarker(flag);
%            out = objs.setPlotFillmarker(flag);
%
% INPUTS:
%                  objs - Any shape of ltpda_uoh objects
%                  flag - true/false
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'setPlotFillmarker')">Parameter Sets</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setPlotFillmarker(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Process inputs
  [objs, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ltpda_uoh', in_names);
  [pl,   pl_invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
  
  if numel(pl) == 0 && numel(rest) == 0
    error('Specify the flag "fillmarker".');
  end
  
  % Apply defaults.
  pl = applyDefaults(getDefaultPlist, pl);
  
  if ~isempty(rest)
    val = rest{1};
    pl.pset('fillmarker', val);
  else
    val = pl.find_core('fillmarker');
  end
  
  if isempty(val) || ~islogical(val)
    error('Specify the flag "fillmarker".');
  end
  
  % decide on a deep copy
  bs = copy(objs, nargout);
  
  for kk=1:numel(bs)
    
    obj = bs(kk);
    
    if isempty(obj.plotinfo)
      obj.plotinfo = plotinfo();
    end
    if isempty(obj.plotinfo.style)
      prefs = getappdata(0, 'LTPDApreferences');
      plotstyles = prefs.getPlotstylesPrefs;
      % get next default plot style
      obj.plotinfo.style = mpipeline.ltpdapreferences.PlotStyle(plotstyles.nextStyle());
    end
    
    % set style
    obj.plotinfo.style.setFillmarkers(java.lang.Boolean(val));
    
    % add history
    obj.addHistory(getInfo('None'), pl, ao_invars(kk), objs(kk).hist);
  end
  
  % set outputs
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
  pl = plist({'fillmarker', 'Flag.'}, {1, utils.plottools.allowedMarkers, paramValue.FALSE_TRUE});
end
