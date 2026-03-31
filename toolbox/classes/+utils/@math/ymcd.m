%
% Yu-Mykland convergence diagnostic
%
% NK 2012
%

function hair = ymcd(C, dbg_info, plot_diag)

  T = size(C,1);
  S = sum(C) / T;
  X = cumsum(C-repmat(S,size(C,1),1));
  
  d = zeros(1,T);
  
  % Compute Hairiness
  for ii = 1+1:T-1
    
    if (X(ii) > X(ii-1) && X(ii) < X(ii+1)) || ...
       (X(ii) < X(ii-1) && X(ii) > X(ii+1))
      
      d(ii) = 1;
     
    else
      
      d(ii) = 0;
      
    end
      
  end
  
  hair = (1/(T-1))*sum(d);
  
  if dbg_info
    
    fprintf(['* ', 'Index of "hairiness"', ...
             '                  : = %s \n'], num2str(hair))
           
  end
  
  if plot_diag
    
    figure
    plot(X,'LineWidth',2);
    
    title('Yu-Mykland convergence diagnostic')
    xlabel('Samples')
    
  end
  
end
% END