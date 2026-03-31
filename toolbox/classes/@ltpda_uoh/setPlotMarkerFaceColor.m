% SETPLOTMARKERFACECOLOR sets the color of a the object's marker face.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETPLOTMARKERFACECOLOR sets the color of a the object's marker face.
%
% If the object currently has no plotinfo object defined, a default one is
% created with the chosen style.
%
% CALL:            objs.setPlotMarkerFaceColor(color);
%            out = objs.setPlotMarkerFaceColor(color);
%
% INPUTS:
%                  objs  - Any shape of ltpda_uoh objects
%                  color - A MATLAB color string or RGB array.
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'setPlotMarkerFaceColor')">Parameter Sets</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setPlotMarkerFaceColor(varargin)
  
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
    error('Specify a color.');
  end
  
  % Apply defaults.
  pl = applyDefaults(getDefaultPlist, pl);
  
  if ~isempty(rest)
    val = rest{1};
    pl.pset('color', val);
  else
    val = pl.find_core('color');
  end
  
  if isempty(val)
    error('Specify a color.');
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
    
    obj.plotinfo.style.setMarkerFaceColor(utils.prog.mcolor2jcolor(val));
    obj.plotinfo.style.setFillmarkers(java.lang.Boolean(true));
    
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
  pl = plist({'color', 'The color to set.'}, paramValue.EMPTY_DOUBLE);
end
