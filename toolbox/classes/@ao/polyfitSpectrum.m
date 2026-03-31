% POLYFITSPECTRUM does a polynomial fit to the log of the input spectrum.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: POLYFITSPECTRUM does a polynomial fit to the log of the
%              input spectrum.
% 
% The method returns the fitted model spectrum as an fsdata AO, evaluated
% at the frequencies specified. In the procinfo of the output objects
% contains the fit as a pest object.
%
% CALL:        bs = polyfitSpectrum(a1,a2,a3,...,pl)
%              bs = polyfitSpectrum(as,pl)
%              bs = polyfitSpectrum.psd(pl)
%
% INPUTS:      aN   - input fsdata analysis objects
%              as   - input fsdata analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     bs   - array of analysis objects, one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'polyfitSpectrum')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = polyfitSpectrum(varargin)
  
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
    if isa(varargin{end}, 'plist')
      as = [varargin{1:end-1}];
      pl = varargin{end};
    else
      as = varargin{:};
      pl = [];
    end
    ao_invars = cell(size(as));
  else
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
    pl                    = utils.helper.collect_objects(rest(:), 'plist', in_names);
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Apply defaults to plist
  usepl = applyDefaults(getDefaultPlist, pl);
  
  % get parameters
  ffit    = usepl.find_core('ffit');
  fout    = usepl.find_core('fout');
  orders  = usepl.find_core('orders');
  doPlots = usepl.find_core('plot fits');
  regularizecoeff =  usepl.find_core('regularizecoeff');% coefficient for regularization
  
  % come checks
  if isempty(orders)
    error('Please specify the orders of the polynomial that should be fit to the input spectra.');
  end
  
  
  % loop over inputs
  out = [];
  for kk=1:numel(bs)
    
    if isempty(ffit)
      ffit = [-inf inf]; % get full range
    end
    
    % split the input spectrum
    S_target = split(bs(kk), plist('frequencies', ffit));
    
    % take log on both axes
    S_log = log10(S_target, plist('axis', 'xy'));
    
    if ~isempty(regularizecoeff)
      
      S_log = S_log + regularizecoeff;
      
    end
    
    % fit a model to the log of the spectrum
    mdl = polynomfit(S_log, plist('orders', orders));
    
    % evaluate the model at the requested frequencies
    if isempty(fout)
      fout = S_target;
    else
      switch class(fout)
        case 'ao'
        case 'double'
          % We need to put the data into the x field of an ao
          fout = ao(fout, fout);
        otherwise
          error('Unsupported class %s for the frequency. Please use a 2D ao or double', class(fout));
      end
    end
    sModLog = eval(mdl, plist(...
      'xdata', log10(fout, plist('axis', 'xy')), ...
      'type', 'fsdata', ...
      'yunits', S_target.yunits, ...
      'xfield', 'x'));
    
    % go back to linear x, y
    sMod = 10.^sModLog;
    sMod.setX(10.^(sMod.x));
    sMod.setYunits(S_target.yunits);
    
    if doPlots
      Splot = copy(sMod);
      Splot.setPlotLinewidth(2);
      Splot.setPlotColor('k');
      Splot.setPlotLineStyle('--');
      Splot.setName('Fit');      
      iplot(S_target.find('x>0'), Splot.find('x>0'))      
    end
    
    % name for this object
    sMod.setName(sprintf('%s(%s)', mfilename, ao_invars{kk}));
    
    % Collect the filters into procinfo
    sMod.procinfo = plist('fit', mdl);
    
    % add history
    sMod.addHistory(getInfo('None'), usepl, ao_invars(kk), bs(kk).hist);
    
    % cache output
    out = [out sMod];
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
  
  pl = plist();

  % FFIT
  p = param({'FFIT',['The frequency range on which to split the input data for fitting in the form [f1 f2]. If empty, the full input spectrum will be fit.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % FOUT
  p = param({'FOUT',['The frequency range on which to evaluate the fit. If empty, the full range of the input spectrum will be used.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % ORDERS
  p = param({'ORDERS',['The orders of polynomial to fit to the spectrum.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % plot
  p = param({'plot fits',['Set to true to produce plots of the fits.']}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % regularize data in order to have a statistically consistent model
  p = param({'regularizecoeff', 'Regularization coefficient. Leave it empty if you do not want to do regularization.'}, ...
    paramValue.EMPTY_DOUBLE);
  pl.append(p);
    
end

