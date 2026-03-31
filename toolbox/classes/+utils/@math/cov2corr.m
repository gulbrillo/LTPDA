%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COV2CORR
% Convert covariance to standard deviation and correlation coefficient
% 
% SigC is a 1-by-n vector with the standard deviation of each process.
% CorrC is an n-by-n matrix of correlation coefficients.
% 
% Algorithm
% 
% SigC(i) = sqrt(Covar(i,i))
% CorrC(i,j) = Covar(i,j)/(SigC(i)*SigC(j))
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [CorrC,SigC] = cov2corr(Covar)

  CorrC = Covar;
  SigC = sqrt(diag(Covar));
  for tt=1:size(CorrC,1)
    for hh=1:size(CorrC,2)
      CorrC(tt,hh) = Covar(tt,hh)/(sqrt(Covar(tt,tt))*sqrt(Covar(hh,hh)));
    end
  end
end