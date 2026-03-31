% SPCORR calculate Spearman Rank-Order Correlation Coefficient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% 
% SPCORR calculates Spearman Rank-Order Correlation Coefficient
%
% CALL:         b = spcorr(a, pl)
% 
% INPUT:       a: are real valued AO. Number of input AOs should be >= 2.
%                 All the input AOs from the second are compared with the
%                 first one.
% 
% OUTPUT:      b: Spearman rank-order correlation coefficients. The
%                 procinfo of b contain further information as:
%                 - pValue: Probability associated with the calculated rs
%                 in the hypothesis that the correlation between the
%                 objects is zero.
%                 - TestRes: True or false on the basis of the test
%                 results. The null hypothesis for the test is that the two
%                 series are uncorrelated.
%                 TestRes = 0 => Do not reject the null hypothesis at
%                 significance level alpha. (pValue >= alpha)
%                 TestRes = 1 => Reject the null hypothesis at significance
%                 level alpha. (pValue < alpha)
%
% PARAMETERS:  
% 
%       - ALPHA is the desired significance level. It represents the
%       probability of rejecting the null hypothesis when it is true. The
%       error done if the null hypothesis is rejected when it is true is
%       called a Type I Error. Therefore, if the null hypothesis is true,
%       alpha is the probability of a type I error. Default [0.05].
% 
% NOTE: 
%       The statistic of Spearman rank-order correlation coefficient is
%       well approximated by a Student t distribution. Hypothesis test is
%       then based on such statistic.
% 
% References:
%      [1] W. H. Press, S. A. Teukolsky, W. T. Vetterling, B. P. Flannery,
%      Numerical Recipes 3rd Edition: The Art of Scientific Computing,
%      Cambridge University Press; 3 edition (September 10, 2007).
% 
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'spcorr')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = spcorr(varargin)

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
  [as, ao_invars]     = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  if nargout == 0
    error('### SPCORR cannot be used as a modifier. Please give an output variable.');
  end
  
  % check input
  if numel(as)<2
    error('### Number of input AOs must be larger or equal to two.')
  end
  
  % Collect input histories
  inhists = [as.hist];
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % get parameters
  alpha = find_core(pl, 'ALPHA');
  if isa(alpha, 'ao')
    alpha = alpha.y;
  end
  
  y1 = as(1).y;
  bs = ao.initObjectWithSize(1, numel(as)-1);
  % run over input aos
  for ii=1:numel(bs)
    
    y2 = as(ii+1).y;
    if size(y1,1)~=size(y2,1)
      % reshape
      y2 = y2.';
    end
    [rs,pValue,TestRes] =...
      utils.math.spcorr(y1, y2, alpha);
    
    bs(ii) = ao(rs);
    bs(ii).setName(sprintf('SpCorr(%s,%s)',  as(1).name, as(ii+1).name));
    plproc = plist(...
      'TestRes',TestRes,...
      'pValue',pValue);
    bs(ii).setProcinfo(plproc);
    bs(ii).addHistory(getInfo('None'), pl, [ao_invars(1) ao_invars(ii+1)], [inhists(1) inhists(ii+1)]);
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

function plo = buildplist()
  plo = plist();
  
  p = param({'ALPHA', ['ALPHA is the desired significance level. It represents'...
    'the probability of rejecting the null hypothesis when it is true.'...
    'The error done if the null hypothesis is rejected when it is true is'...
    'called a Type I Error. Therefore, if the null hypothesis is true, alpha'...
    'is the probability of a type I error.']}, paramValue.DOUBLE_VALUE(0.05));
  plo.append(p);

end
