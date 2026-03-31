% QQPLOT makes quantile-quantile plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Make quantile-quantile plot and calculate confidence
% intervals on the basis of the Kolmogorov-Smirnov test.
%
% CALL:         qqplot(a, pl)
% 
% INPUT:        a: are real valued AO
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'kstest')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = qqplot(varargin)

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
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % combine plists
  if isempty(pl)
    model = 'empirical';
  else
    model = lower(find_core(pl, 'TESTDISTRIBUTION'));
    if isempty(model)
      model = 'empirical';
      pl.pset('TESTDISTRIBUTION', model);
    end
  end
  
  pl = applyDefaults(getDefaultPlist(model), pl);
  
  % get parameters
  conf = find_core(pl, 'CONFLEVEL');
  if isa(conf, 'ao')
    conf = conf.y;
  end
  shapeparam = find_core(pl, 'SHAPEPARAM');
  if isa(shapeparam, 'ao')
    shapeparam = shapeparam.y;
  end
  ftsize = find_core(pl, 'FONTSIZE');
  if isa(ftsize, 'ao')
    ftsize = ftsize.y;
  end
  lwidth = find_core(pl, 'LINEWIDTH');
  if isa(lwidth, 'ao')
    lwidth = lwidth.y;
  end

  % switch among test type
  switch lower(model)
    case 'normal'
      mmean = find_core(pl, 'MEAN');
      if isa(mmean, 'ao')
        mmean = mmean.y;
      end
      sstd = find_core(pl, 'STD');
      if isa(sstd, 'ao')
        sstd = sstd.y;
      end
      distparams = [mmean, sstd];
      dist = 'normdist';
    case 'chi2'
      ddof = find_core(pl, 'DOF');
      if isa(ddof, 'ao')
        ddof = ddof.y;
      end
      distparams = [ddof];
      dist = 'chi2dist';
    case 'f'
      dof1 = find_core(pl, 'DOF1');
      if isa(dof1, 'ao')
        dof1 = dof1.y;
      end
      dof2 = find_core(pl, 'DOF2');
      if isa(dof2, 'ao')
        dof2 = dof2.y;
      end
      distparams = [dof1, dof2];
      dist = 'fdist';
    case 'gamma'
      shp = find_core(pl, 'SHAPE');
      if isa(shp, 'ao')
        shp = shp.y;
      end
      scl = find_core(pl, 'SCALE');
      if isa(scl, 'ao')
        scl = scl.y;
      end
      distparams = [shp, scl];
      dist = 'gammadist';
    otherwise
      distparams = [];
  end
  
  
  % run test
  switch lower(model)
    case 'empirical'
      
      % build parameters struct
      params = struct(...
        'conflevel',conf,...
        'FontSize',ftsize,...
        'LineWidth',lwidth);
      
      y1 = as(1).y;
      % run over input aos
      for ii=1:numel(as)-1
        y2 = as(ii+1).y;
        if size(y1,1)~=size(y2,1)
          % reshape
          y2 = y2.';
        end
        utils.math.qqplot(y1, y2, params);
        
      end
       
    otherwise
      
      % build parameters struct
      params = struct(...
        'ProbDist',dist,...
        'ShapeParam',shapeparam,...
        'params',distparams,...
        'conflevel',conf,...
        'FontSize',ftsize,...
        'LineWidth',lwidth);
      
      % run over input aos
      for ii=1:numel(as)
        
        utils.math.qqplot(as(ii).y, [], params);
        
      end
      
  end
  
  
end


%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pl = getDefaultPlist(sets{1});
  else
    sets = SETS();
    % get plists
    pl(size(sets)) = plist;
    for kk = 1:numel(sets)
      pl(kk) =  getDefaultPlist(sets{kk});
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end


%--------------------------------------------------------------------------
% Defintion of Sets
%--------------------------------------------------------------------------

function out = SETS()
  out = {...
    'empirical', ...
    'normal',    ...
    'chi2',   ...
    'f', ...
    'gamma' ...
    };
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(set)
  persistent pl;  
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;  
end

function plo = buildplist(set)
  plo = plist();
    
  p = param({'TESTDISTRIBUTION', ['test data are compared with the given'...
    'test distribution. Available choices are:<ol>'...
    '<li>EMPIRICAL test the all the input object (starting from the second) against the first object.</li>'...
    '<li>NORMAL test all the input objects against the Normal distribution</li>'...
    '<li>CHI2 test all the input objects against the Chi square distribution</li>'...
    '<li>F test all the input objects against the F distribution</li>'...
    '<li>GAMMA test all the input objects against the Gamma distribution</li></ol>']}, ...
    {1, {'EMPIRICAL', 'NORMAL', 'CHI2', 'F', 'GAMMA'}, paramValue.SINGLE});
  plo.append(p);
  
  p = param({'CONFLEVEL', 'Confidence level for confidence interval calculations.'},...
    paramValue.DOUBLE_VALUE(0.95));
  plo.append(p);
  
  p = param({'SHAPEPARAM', ['In the case of comparison of a data series with a'...
    'theoretical distribution and the data series is composed of correlated'...
    'elements. K can be adjusted with a shape parameter in order to recover'...
    'test fairness [3]. In such a case the test is performed for K* = Phi * K.'...
    'Phi is the corresponding Shape parameter. The shape parameter depends on'...
    'the correlations and on the significance value. It does not depend on'...
    'data length.']}, paramValue.DOUBLE_VALUE(1));
  plo.append(p);
  
  p = param({'FONTSIZE', 'Font size for axis'}, paramValue.DOUBLE_VALUE(22));
  plo.append(p);
  
  p = param({'LINEWIDTH', 'Line Width'}, paramValue.DOUBLE_VALUE(2));
  plo.append(p);
  
  switch lower(set)
    case 'empirical'
      % do nothing
    case 'normal'
      p = param({'MEAN', ['The mean of the normal distribution']}, paramValue.DOUBLE_VALUE(0));
      plo.append(p);
      p = param({'STD', ['The standard deviation of the normal distribution']}, paramValue.DOUBLE_VALUE(1));
      plo.append(p);
    case 'chi2'
      p = param({'DOF', ['Degrees of freedom of the chi square distribution']}, paramValue.DOUBLE_VALUE(2));
      plo.append(p);
    case 'f'
      p = param({'DOF1', ['First degree of freedom of the F distribution']}, paramValue.DOUBLE_VALUE(2));
      plo.append(p);
      p = param({'DOF2', ['Second degree of freedom of the F distribution']}, paramValue.DOUBLE_VALUE(2));
      plo.append(p);
    case 'gamma'
      p = param({'SHAPE', ['Shape parameter (k) of the Gamma distribution']}, paramValue.DOUBLE_VALUE(2));
      plo.append(p);
      p = param({'SCALE', ['Scale parameter (theta) of the Gamma distribution']}, paramValue.DOUBLE_VALUE(2));
      plo.append(p);
    otherwise
  end
  



end
