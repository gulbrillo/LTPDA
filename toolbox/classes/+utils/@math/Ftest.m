% Ftest perfomes an F-Test.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SFT performes an F-Test providing the measured F statistic,
%              the two degrees of freedom, the confidence level and the
%              type of the test (a boolean, one or two tailed). The null 
%              hypothesis H0 is rejected at the confidence level for the 
%              alternative hypothesis H1 if the test statistic falls in the 
%              critical region.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [test,critValue,pValue] = Ftest(F,dof1,dof2,alpha,twoTailed)
  
  n = numel(F);  

  if twoTailed
    % Lower bound
%     critValue(1) = icdf('f',alpha/2,dof1,dof2);
    critValue(1) = utils.math.Finv(alpha/2/n,dof1,dof2);
    % Upper bound
%     critValue(2) = icdf('f',1-alpha/2,dof1,dof2);
    critValue(2) = utils.math.Finv(1-alpha/2/n,dof1,dof2);
  else
%     critValue = icdf('f',1-alpha,dof1,dof2);
    critValue = utils.math.Finv(1-alpha/n,dof1,dof2);
  end
  
%   pValue = 1-cdf('f',F,dof1,dof2);
  pValue = 1-utils.math.Fcdf(F,dof1,dof2);
  
  if twoTailed
    test = F<critValue(1) | F>critValue(2);
  else
    test = F>critValue;
  end    

end
