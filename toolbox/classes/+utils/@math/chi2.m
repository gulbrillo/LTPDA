%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Compute chi2 and its gradient.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [chi2,g] = chi2(p,data,models,Dmodels,lb,ub)

  weights = 1;
  Nfreeparams = numel(p);
  Nmdls = numel(models);
  Ndata = numel(data(:,1));
  Np = numel(p);
  
  mdldata = zeros(Ndata,Nmdls);
  for kk=1:Nmdls
    mdldata(:,kk) = models{kk}(p);
  end  
  res = (mdldata-data).*weights;
  if all(p>=lb & p<=ub)
    chi2 = res'*res;
    chi2 = sum(diag(chi2));
  else
    chi2 = 10e50;
  end
  
  if nargout > 1 % gradient required
    grad = cell(Nmdls,1);
    g = zeros(Nmdls,Nfreeparams);
    for kk=1:Nmdls
      grad{kk} = zeros(Ndata,Np);
      for ii=1:Np        
        grad{kk}(:,ii) = Dmodels{kk}{ii}(p);
        g(kk,ii) = 2.*res(:,kk)'*grad{kk}(:,ii);
      end
    end
    if Nmdls>1
      g = sum(g);
    end
  end
  
end
