% KSTEST perform the Kolmogorov - Smirnov statistical hypothesis test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% DESCRIPTION:
% 
% Kolmogorov - Smirnov test is typically used to assess if a sample comes
% from a specific distribution or if two data samples came from the same
% distribution. The test statistics is d_K = max|S(x) - K(x)| where S(x)
% and K(x) are cumulative distribution functions of the two inputs
% respectively.
% In the case of the test on a single data series:
% - null hypothesis is that the data are a realizations of a random variable
%   which is distributed according to the given probability distribution
% In the case of the test on two data series:
% - null hypothesis is that the two data series are realizations of the same random variable
% 
% CALL:
% 
% H = utils.math.kstest(y1, y2, alpha, distparams)
% [H] = utils.math.kstest(y1, y2, alpha, distparams)
% [H, KSstatistic] = utils.math.kstest(y1, y2, alpha, distparams)
% [H, KSstatistic, criticalValue] = utils.math.kstest(y1, y2, alpha, distparams)
% [H, KSstatistic, criticalValue] = utils.math.kstest(y1, y2, alpha, distparams, shapeparam)
% [H, KSstatistic, criticalValue, pValue] = utils.math.kstest(y1, y2, alpha, distparams, shapeparam, criticalValue)
% 
% INPUT:
% 
% - Y1 are the data we want to test against Y2.
% 
% - Y2 can be a theoretical distribution or a second set of data. In case
% of theoretical distribution, Y2 should be a string with the corresponding
% distribution name. Permitted values are:
%   - 'NormDist' Nomal distribution
%   - 'Chi2Dist' Chi square distribution
%   - 'FDist' F distribution
%   - 'GammaDist' Gamma distribution
% If Y2 is left empty a normal distribution is assumed.
% 
% - ALPHA is the desired significance level (default = 0.05). It represents
% the probability of rejecting the null hypothesis when it is true.
% Rejecting the null hypothesis, H0, when it is true is called a Type I
% Error. Therefore, if the null hypothesis is true , the level of the test,
% is the probability of a type I error.
% 
% - DISTPARAMS are the parameters of the chosen theoretical distribution.
% You should not assign this input if Y2 are experimental data. In general
% DISTPARAMS is a vector containing the following distribution parameters:
%   - In case of 'NormDist', DISTPARAMS is a vector containing mean and
%   standard deviation of the normal distribution [mean sigma]. Default [0 1]
%   - In case of 'Chi2Dist' , DISTPARAMS is a number containing containing
%   the degrees of freedom of the chi square distribution [dof]. Default [2] 
%   - In case of 'FDist', DISTPARAMS is a vector containing the two degrees
%   of freedom of the F distribution [dof1 dof2]. Default [2 2]
%   - In case of 'GammaDist', DISTPARAMS is a vector containing the shape
%   and scale parameters [k, theta]. Default [2 2]
% 
% - SHAPEPARAM In the case of comparison of a data series with a
% theoretical distribution and the data series is composed of correlated
% elements. K can be adjusted with a shape parameter in order to recover
% test fairness [3]. In such a case the test is performed for K' = Phi * K.
% Phi is the corresponding Shape parameter. The shape parameter depends on
% the correlations and on the significance value. It does not depend on
% data length. Default [1]
% 
% - CRITICALVALUE In case the critical value for the test is available from
% external calculations, e.g. Monte Carlo simulation, the vale can be input
% to the method
% 
% OUTPUT:
% 
% - H indicates the result of the hypothesis test:
%  H = false => Do not reject the null hypothesis at significance level ALPHA.
%  H = true => Reject the null hypothesis at significance level ALPHA.
% 
% - TEST STATISTIC is the value of d_K = max|S(x) - K(x)|.
% 
% - CRITICAL VALUE is the value of the test statistics corresponding to the
% significance level. CRITICAL VALUE is depending on K, where K is the data length of Y1 if
% Y2 is a theoretical distribution, otherwise if Y1 and Y2 are two data
% samples K = n1*n2/(n1 + n2) where n1 and n2 are data length of Y1 and Y2
% respectively. In the case of comparison of a data series with a
% theoretical distribution and the data series is composed of correlated
% elements. K can be adjusted with a shape parameter in order to recover
% test fairness [3]. In such a case the test is performed for K' = Phi * K.
% If TEST STATISTIC > CRITICAL VALUE the null hypothesis is rejected.
% 
% - P VALUE is the probability value associated to the test statistic.
% NOT YET IMPLEMENTED!!!
% 
% Luigi Ferraioli 17-02-2011
% 
% REFERENCES:
% 
%   [1] Massey, F.J., (1951) "The Kolmogorov-Smirnov Test for Goodness of
%   Fit", Journal of the American Statistical Association, 46(253):68-78.
%   [2] Miller, L.H., (1956) "Table of Percentage Points of Kolmogorov
%   Statistics", Journal of the American Statistical Association,
%   51(273):111-121.
%   [3] Ferraioli L. et al, to be published.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [H, KSstatistic, criticalValue, pValue] = kstest(y1, y2, alpha, varargin)

  % check inputs
  if isempty(y2)
    y2 = 'normdist'; % set normal distribution as default
  end
  if isempty(alpha)
    alpha = 0.05;
  end
  
  if nargin > 3
    dof = varargin{1};
  elseif nargin <= 3 && ischar(y2)
    switch lower(y2) % assign dof
      case 'fdist'
        dof = [2 2];
      case 'normdist'
        dof = [0 1];
      case 'chi2dist'
        dof = [2];
      case 'gammadist'
        dof = [2 2];
    end
  end
  
  shp = 1;
  if nargin > 4
    shp = varargin{2};
    if isempty(shp)
      shp = 1;
    end
  end
  
  if nargin > 5
    criticalValue = varargin{3};
  else
    criticalValue = [];
  end
  
  n1     =  length(y1);
  
  % get empirical distribution for input data
  [CD1,x1] = utils.math.ecdf(y1);

  % check if we have a second dataset or a theoretical distribution as second
  % input
  if ischar(y2)
    % switch between theoretical distributions
    switch lower(y2)
      case 'fdist'
        CD2 = utils.math.Fcdf(x1, dof(1), dof(2));
      case 'normdist'
        CD2 = utils.math.Normcdf(x1, dof(1), dof(2));
      case 'chi2dist'
        CD2 = utils.math.Chi2cdf(x1, dof(1));
      case 'gammadist'
        CD2 = gammainc(x1./dof(2), dof(1));
      otherwise
        error('??? Unrecognized distribution type')
    end
    n2 =  [];
    n1 = shp*n1;
    % calculate empirical distribution for second input dataset
  else
    [eCD2, ex2] = utils.math.ecdf(y2);
    CD2  =  interp1(ex2, eCD2, x1, 'linear');
    n2  =  length(y2);
  end
  
  KSstatistic = max(abs(CD1 - CD2));
  
  if isempty(criticalValue)
    criticalValue = utils.math.SKcriticalvalues(n1, n2, alpha/2);
  end
  
  % "H = 0" implies that we "Do not reject the null hypothesis at the
  % significance level of alpha," and "H = 1" implies that we "Reject null
  % hypothesis at significance level of alpha."
  H  =  (KSstatistic > criticalValue);
  
  if nargout > 3
    pValue = [];
    warning('Output of pValue is not yet supported. It will be supported in a next release')
    %pValue = utils.math.KSpValue(KSstatistic, n1, n2);
  end

end
