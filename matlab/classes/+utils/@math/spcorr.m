% SPCORR calculate Spearman Rank-Order Correlation Coefficient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% 
% SPCORR calculates Spearman Rank-Order Correlation Coefficient
% 
% CALL:
%       [rs,pValue,TestRes] = spcorr(y1,y2,alpha)
% 
% INPUT: 
%       - y1 and y2 are data series
%       - alpha is the significance level. Default 0.05
% 
% OUTPUT:
%       - rs: Spearman rank-order correlation coefficient
%       - pValue: Probability associated with the calculated rs in the
%       hypothesis that the correlation between y1 and y2 is zero
%       - TestRes: True or false on the basis of the test results. The null
%       hypothesis for the test is that the two series y1 and y2 are
%       uncorrelated.
%         TestRes = 0 => Do not reject the null hypothesis at significance
%         level alpha. (pValue >= alpha)
%         TestRes = 1 => Reject the null hypothesis at significance level
%         alpha. (pValue < alpha)
% 
% NOTE: 
%       The statistic of Spearman rank-order correlation coefficient is
%       well approximated by a Student t distribution. Hypothesis test is
%       then based on such statistic.
% 
%   References:
%      [1] W. H. Press, S. A. Teukolsky, W. T. Vetterling, B. P. Flannery,
%      Numerical Recipes 3rd Edition: The Art of Scientific Computing,
%      Cambridge University Press; 3 edition (September 10, 2007)
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rs,pValue,TestRes] = spcorr(y1,y2,alpha)
  
  % check size
  if size(y1)~=size(y2)
    error('y1 and y2 must have the same size')
  end
  
  % check input
  if isempty(alpha)
    alpha = 0.05;
  elseif alpha > 1
    alpha = alpha/100;
  end
    
  
  % calculate rank for y1 and y2
  [r1,s1] = utils.math.crank(y1);
  [r2,s2] = utils.math.crank(y2);
  
  n = numel(y1);
  
  dv = (r1-r2).^2;
  
  dd = sum(dv);
  
  en = n*n*n-n;
  
  sq1 = sqrt(1-s1/en);
  sq2 = sqrt(1-s2/en);
  
  % calculate Spearman rank-order correlation coefficient
  rs = (1 - 6*(dd + s1/12 + s2/12)/en)/(sq1*sq2);
  
  % transform rs in t which is according Student's distribution with n-2
  % degrees of freedom
  t = rs*sqrt((n-2)/(1-rs^2));
  
  % Indicated with f(x) the prob. distribution function (Student's t in the
  % present caase). The probability Pr(k <= t) is proportional to the
  % integral Int_(-t,t)[f(x)dx]. For a Student's distribution such integral
  % is represeted by the Beta incomplete function
  % Pr(k <= t) = betainc(df/(df+t^2),df/2,1/2,'upper')
  % As a consequence Pr(k > t) = 1 - Pr(k <= t) which in Matlab can be
  % effectively calculated as
  % Pr(k > t) = betainc(df/(df+t^2),df/2,1/2,'lower')
  % Which provides the probability of finding a value grater than t if our
  % variable k is distributed according to a Student's distribution with df
  % degrees of freedom. Such a value represent the required pValue for the
  % test in the hypothesis that the two input data series are uncorrelated
  fac = (rs+1)*(1-rs);
  if fac>0
    df = n-2;
    pValue = betainc(df/(df+t*t),0.5*df,0.5,'lower');
  else
    pValue = 0;
  end
  
  TestRes = (pValue < alpha);
  
  
end