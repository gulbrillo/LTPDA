%
%
%   Compute the heat factor for the MCMC chains.
%
%   MN 2010
%
function beta = computeBeta(nacc, Tc, anneal, xi)

  if ~isempty(Tc)
    
    if nacc <= Tc(1)
      
      % compute heat factor
      switch anneal
        
        case 'simul'
          
          heat = xi;
          
        case 'thermo'
          
          % under update
          heat = xi;
          
      end  
      
        beta = 10^(-heat*(1-Tc(1)/Tc(2)));
        
    elseif Tc(1) < nacc  && nacc <= Tc(2)
      
      beta = 10^(-xi*(1-nacc/Tc(2)));
      
    else
      
      beta = 1;
      
    end
    
  else
    
    beta = 1;
    
  end
  
end
