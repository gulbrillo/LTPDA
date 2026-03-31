% validateSpectrumMod statistically validate a model for a psd.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: validateSpectrumMod provide a statistical validation of a
% model for the expected value of a spectrum. The test is based on
% Kolmogorov-Smirnov test and a graphical version of the test is provided
% in the form of a cdf plot.
% For the Kolmogorov-Smirnov test null hypothesis is that the data are a
% realization of a random variable that is distributed according to the
% given probability distribution (Gamma).
%
% CALL:         [ksout,fig1h,fig2h] = validateSpectrumMod(data,model,pl)
%
% INPUTS:      data  - a psd.
%              model - the model for the expected value of the psd. It can
%              be an AO or a mfh model.
%              pl - parameter list
%
% OUTPUTS:
%               ksout - Kolmogorov-Smirnov test result.
%                       It is cdata AO containing the results of the test: 
%                         true  if the null hypothesis is rejected
%                         at the given significance level.
%                         false if the null hypothesis is not rejected
%                         at the given significance level.
%               fig1h - cdfplot figure handle.
%               fig2h - histogram figure handle.
%
%
% Note: Gamma function assumption for the spectrum is strictly true only with
%     Gaussian distributed noise (time series). In case the noise in time
%     domain is non-Gaussian the Gamma is an approximation based on the
%     norilizing properties of the fft. Even if noise series is
%     non-Gaussian, real and imaginary part of the fft tend to a Gaussian
%     because are the result of the sum of many terms.
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'validateSpectrumMod')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = validateSpectrumMod(varargin)
  
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
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [fmod, mfh_invars] = utils.helper.collect_objects(varargin(:), 'mfh', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  if nargout == 0
    error('### validateSpectrumMod cannot be used as a modifier. Please give an output variable.');
  end
  
  % check inputs
  if isempty(fmod)
    fmhmod = false;
  else
    fmhmod = true;
  end
  
  if ~fmhmod
    % check two inputs aos are of the same size
    if numel(as)<2
      error('validateSpectrumMod require a psd and a model as input.');
    else
      if numel(as(1).y)~=numel(as(2).y)
        error('Two inputs aos must be of the same size.')
      end
    end
  end
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
    
  %%%%% Extract necessary parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  conf = find_core(pl, 'confidence'); % confidence level for KS test
  if conf>1
    conf = conf./100;
  end
  
  downsamplespectrum = find_core(pl, 'downsamplespectrum');% decide to skip some bins of the spectrum in order to have independent samples
  downsamplebins = find_core(pl, 'downsamplebins');% number of bins to skip
  
  %%%%% Build normalized spectrum %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if fmhmod
    wS = as(1)./fmod(as(1).x);
    
    inhists = [as.hist fmod.hist];
  else
    wS = as(1)./as(2);
    
    inhists = [as.hist];
  end
  
  %%%%% Downsample if required
  if downsamplespectrum
    [f,y] = utils.math.downsampleSpectrum(wS.x,wS.y,downsamplebins);
    wSd = copy(wS,1);
    wSd.setDx([]);
    wSd.setDy([]);
    wSd.setX(f);
    wSd.setY(y);
  else
    wSd = wS;
  end
  
  % get history back
  wSd.addHistory(getInfo('None'), pl, ao_invars, inhists);
  wSd.setName('Normalized Spectrum');
  
  % get number of averages
  navs = as(1).data.navs;
  
  %%%%% Run KS test %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  A = navs;
  B = 1/navs;
  
  plks = plist(...
    'TESTDISTRIBUTION', 'GAMMA', ...
    'ALPHA', 1-conf, ...
    'SHAPE', A, ...
    'SCALE', B);
  
  ksout = kstest(wSd,plks);
  
%   [H, KSstatistic, criticalValue] =...
%     utils.math.kstest(wSd, 'gamma', 1-conf, [A,B]);
  
  % set description
  ksout.setDescription(['False: null hypothesis is not rejected -> model and data are compatible. '...
    'True: null hypothesis is rejected -> model and data are not compatible.']);
  %%%%% CDF Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  plcdf = plist(...
    'TESTDISTRIBUTION', 'GAMMA', ...
    'CONFLEVEL', conf, ...
    'SHAPE', A, ...
    'SCALE', B);
  
  cdfplot(wSd,plcdf);
  cdfploth = gcf;
  
  %%%%% Histogram %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  histsize = numel(wSd.y)/100;
  if histsize<10
    histsize = 10;
  end
  hobj = hist(wSd,plist('N',histsize));
  
  % get values out of the object
  hx = hobj.x;
  hy = hobj.y;
  
  % willing to work with columns
  [nx,ny] = size(hx);
  if ny>nx
    hx = hx.';
  end
  [nx,ny] = size(hy);
  if ny>nx
    hy = hy.';
  end
  
  gm = utils.math.gammapdf(hx,A,B);
  
  fontsize = 18;
  lwidth = 3;
  
  histploth = figure('Name','Data histogram vs. Gamma pdf');
  h1 = stairs(hx,hy./sum(hy.*[0; diff(hx)]));
  grid on
  hold on
  h2 = plot(hobj.x,gm);
  xlabel('x','FontSize',fontsize);
  ylabel('Counts','FontSize',fontsize);
  set(h2(1), 'Color',[0 113 188]./255, 'LineStyle','-','LineWidth',lwidth);
  set(h1(1), 'Color',[216 82 26]./255, 'LineStyle','-','LineWidth',lwidth);
  %     set(h2(1), 'Color',[0.1 0.1 0.1], 'LineStyle','--','LineWidth',lwidth);
  legend([h1(1),h2(1)],{'Histogram','Gamma PDF'});
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ----- Set outputs -----
  if nargout == 1
    varargout{1} = ksout;
  elseif nargout == 2;
    varargout{1} = ksout;
    varargout{2} = cdfploth;
  elseif nargout == 3;
    varargout{1} = ksout;
    varargout{2} = cdfploth;
    varargout{3} = histploth;
  else
    % multiple output is not supported
    error('### Maximum number of outputs is 2 ###')
  end
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
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
  
  pl = plist();
 
  % MaxIter
  p = param({'Confidence', 'Required confidence level for the KS test.'}, paramValue.DOUBLE_VALUE(95));
  pl.append(p);
  
  % decide to downsample the spectrum in order to have independent bins
  p = param({'downsamplespectrum', 'Decide to downsample the spectrum in order to have independent bins.'}, ...
    paramValue.FALSE_TRUE);
  pl.append(p);
  
  % decide to downsample the spectrum in order to have independent bins
  p = param({'downsamplebins', 'Number of bins to skip in order to get independence.'}, ...
    paramValue.DOUBLE_VALUE(3));
  pl.append(p);
  
end
% END

