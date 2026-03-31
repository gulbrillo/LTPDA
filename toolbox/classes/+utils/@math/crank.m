% CRANK calculate ranks for Spearman correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Given the data series w
% Calculate:
% rw: the ranks (ties are treated by midranking)
% s:  the sum(fk^3 - fk), where fk are the number of kth group of ties
% 
%   References:
%      [1] W. H. Press, S. A. Teukolsky, W. T. Vetterling, B. P. Flannery,
%      Numerical Recipes 3rd Edition: The Art of Scientific Computing,
%      Cambridge University Press; 3 edition (September 10, 2007)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rw,s] = crank(w)

  [sw,idx] = sort(w);

  n = numel(sw);
  s = 0;
  jj = 2; 

  while jj < n+1
    if sw(jj) ~= sw(jj-1);
      sw(jj-1) = jj-1;
      jj = jj+1;
    else
      jt = jj+1;
      while jt<=n+1 && sw(jt-1)==sw(jj-1)
        jt = jt + 1;
      end
      rnk = 0.5*(jj+jt-3);
      for ji=jj:jt-1
        sw(ji-1)=rnk;
      end
      t = jt-jj;
      s = s + (t*t*t-t);
      jj = jt;
    end
  end

  if jj==n+1
    sw(n)=n+1;
  end

  rw = zeros(size(sw));
  for ii=1:numel(sw)
    rw(idx(ii)) = sw(ii);
  end

end