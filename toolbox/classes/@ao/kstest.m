% KSTEST perform KS test on input AOs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Kolmogorov - Smirnov test is typically used to assess if a
% sample comes from a specific distribution or if two data samples came
% from the same distribution. The test statistics is d_K = max|S(x) - K(x)|
% where S(x) and K(x) are cumulative distribution functions of the two
% inputs respectively.
% In the case of the test on a single data series:
% - null hypothesis is that the data are a realizations of a random variable
%   which is distributed according to the given probability distribution
% In the case of the test on two data series:
% - null hypothesis is that the two data series are realizations of the same random variable
%
% CALL:         b = kstest(a1, pl)
%               b = kstest(a1, a2, pl)
%               b = kstest(a1, a2, a3, pl)
% 
% INPUT:        ai: are real valued AO
% 
% OUTPUT:       b: are cdata AOs containing the results of the test: 
%                 true  if the null hypothesis is rejected
%                       at the given significance level.
%                 false if the null hypothesis is not rejected
%                       at the given significance level.
% The procinfo of b contain further information as:
%                 - KSstatistic, the value of d_K = max|S(x) - K(x)|.
%                 - criticalValue, it is the value of the test statistics
%                 corresponding to the significance level. CRITICAL VALUE
%                 is depending on K, where K is the data length of Y1 if Y2
%                 is a theoretical distribution, otherwise if Y1 and Y2 are
%                 two data samples K = n1*n2/(n1 + n2) where n1 and n2 are
%                 data length of Y1 and Y2  respectively. In the case of
%                 comparison of a data series with a theoretical
%                 distribution and the data series is composed of
%                 correlated  elements. K can be adjusted with a shape
%                 parameter in order to recover test fairness. In such a
%                 case the test is performed for K' = Phi * K. If
%                 KSstatistic > criticalValue the null hypothesis is 
%                 rejected.
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'kstest')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = kstest(varargin)

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
  
  if nargout == 0
    error('### KSTEST cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input histories
  inhists = [as.hist];

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
  alpha = find_core(pl, 'ALPHA');
  if isa(alpha, 'ao')
    alpha = alpha.y;
  end
  shapeparam = find_core(pl, 'SHAPEPARAM');
  if isa(shapeparam, 'ao')
    shapeparam = shapeparam.y;
  end
  criticalvalue = find_core(pl, 'CRITICALVALUE');
  if isa(criticalvalue, 'ao')
    criticalvalue = criticalvalue.y;
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
      y1 = as(1).y;
      bs = ao.initObjectWithSize(1, numel(as)-1);
      % run over input aos
      for ii = 1:numel(bs)
        y2 = as(ii+1).y;
        if size(y1, 1) ~= size(y2, 1)
          % reshape
          y2 = y2.';
        end
        [H, KSstatistic, criticalValue] =...
          utils.math.kstest(y1, y2, alpha, distparams, shapeparam, criticalvalue);
        
        bs(ii) = ao(H);
        bs(ii).setName(sprintf('KStest(%s,%s)', as(1).name, as(ii+1).name));
        plproc = plist(...
          'KSstatistic', KSstatistic,...
          'criticalValue', criticalValue);
        bs(ii).setProcinfo(plproc);
        bs(ii).setDescription(['False: null hypothesis is not rejected. '...
          'True: null hypothesis is rejected.']);
        bs(ii).addHistory(getInfo('None'), pl, [ao_invars(1) ao_invars(ii+1)], [inhists(1) inhists(ii+1)]);
      end
       
    otherwise
      bs = ao.initObjectWithSize(1, numel(as));
      % run over input aos
      for ii = 1:numel(bs)
        [H, KSstatistic, criticalValue] =...
          utils.math.kstest(as(ii).y, dist, alpha, distparams, shapeparam, criticalvalue);
        
        bs(ii) = ao(H);
        bs(ii).setName(sprintf('KStest(%s,%s)', as(ii).name,model));
        plproc = plist(...
          'KSstatistic',KSstatistic,...
          'criticalValue',criticalValue);
        bs(ii).setProcinfo(plproc);
        bs(ii).setDescription(['False: null hypothesis is not rejected. '...
          'True: null hypothesis is rejected.']);
        bs(ii).addHistory(getInfo('None'), pl, ao_invars(ii), inhists(ii));
      end
      
  end
  
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
    
  p = param({'TESTDISTRIBUTION', ['test data are compared with the given '...
    'test distribution. Available choices are:<ol>'...
    '<li>EMPIRICAL test all the input objects (starting from the second) against the first object.</li>'...
    '<li>NORMAL test all the input objects against the Normal distribution, '...
    'with mean specified by the ''MEAN'' parameter, and sigma specified by the ''STD'' parameter</li>'...
    '<li>CHI2 test all the input objects against the Chi square distribution, ' ...
    'with degrees of freedom specified by the ''DOF'' parameter</li>'...
    '<li>F test all the input objects against the F distribution, '...
    'with first degree of freedom specified by the ''DOF1'' parameter, and '...
    'second degree of freedom specified by the ''DOF2'' parameter</li>'...
    '<li>GAMMA test all the input objects against the Gamma distribution, '...
    'with shape parameter (k) specified by the ''SHAPE'' parameter, '...
    'and scale parameter (theta) specified by the ''SCALE'' parameter</li></ol>']}, ...
    {1, {'EMPIRICAL', 'NORMAL', 'CHI2', 'F', 'GAMMA'}, paramValue.SINGLE});
  plo.append(p);
  
  p = param({'ALPHA', ['ALPHA is the desired significance level. It represents '...
    'the probability of rejecting the null hypothesis when it is true.'...
    'Rejecting the null hypothesis, H0, when it is true is called a Type I '...
    'Error. Therefore, if the null hypothesis is true , the level of the test, '...
    'is the probability of a type I error.']}, paramValue.DOUBLE_VALUE(0.05));
  plo.append(p);
  
  p = param({'SHAPEPARAM', ['In the case of comparison of a data series with a '...
    'theoretical distribution and the data series is composed of correlated '...
    'elements. K can be adjusted with a shape parameter in order to recover '...
    'test fairness [3]. In such a case the test is performed for K* = Phi * K.<br>'...
    'Phi is the corresponding Shape parameter. The shape parameter depends on '...
    'the correlations and on the significance value. It does not depend on '...
    'data length.']}, paramValue.DOUBLE_VALUE(1));
  plo.append(p);
  
  p = param({'CRITICALVALUE', ['In case the critical value for the test is available from '...
    'external calculations, e.g. Monte Carlo simulation, the vale can be input '...
    'as a parameter.']}, paramValue.EMPTY_DOUBLE);
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
      p = param({'DOF', ['Degrees of freedom of the Chi square distribution']}, paramValue.DOUBLE_VALUE(2));
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
