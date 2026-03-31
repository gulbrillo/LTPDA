%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CORR2COV
% Convert correlartion matrix to covariance matrix
% 
% SigC Vector of length n with the standard deviations of each process. n
% is the number of random processes.
% 
% CorrC n-by-n correlation coefficient matrix. If ExpCorrC is not
% specified, the processes are assumed to be uncorrelated, and the identity
% matrix is used.
% 
% Algorithm
% 
% Covar(i,j) = CorrC(i,j)*(SigmC(i)*SigmC(j) 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Covar = corr2cov(CorrC,SigC)

  Covar = CorrC;
  
  for tt=1:size(CorrC,1)
    for hh=1:size(CorrC,2)
      Covar(tt,hh) = CorrC(tt,hh)*SigC(tt)*SigC(hh);
    end
  end
end