%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CPU benchmarking for comparing speeds among different
% architectures/computers.
%
% DESCRIPTION: CPUbenchmark provides a benchmark CPU time for comparison
%              among different architectures/computers. It gives the mean
%              CPU time and the mean error.
%
% CALL:        [a, b] = CPUbenchmark;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [avgT,stdT]=CPUbenchmark

 avgT = zeros(10,1);
 stdT = avgT;

 for jj=1:10
  m = zeros(100,1);
  for kk = 1:100
    tic
    for i = 1:1e4
    a = rand(10,10);
    a = a';
    end
    m(kk)=toc;
  end

  avgT(jj) = mean(m);
  stdT(jj) = std(m)/sqrt(numel(m));
  
 end
 
 avgT = mean(avgT);
 stdT = mean(stdT);

end