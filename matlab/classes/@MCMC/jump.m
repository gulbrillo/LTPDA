% JUMP: Propose new point on the parameter space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% JUMP: Propose new point on the parameter space. Used for the
%       Metropolis Hastings Algorithm
% 
%
% 2012
%
function [xn, hjump, Sn] = jump(xo,cvar,hjump,jumps,nacc,search,Tc,proposalSampler,ADAPTIVE, covUpdate, smpl, epsilon)
  
  if search
    if nacc <= Tc(1)
      if(mod(nacc,10) == 0 && mod(nacc,25) ~= 0 && mod(nacc,100) ~= 0 && hjump  ~= 1)
        hjump = 1;
        modcov = jumps(2)^2*cvar;
      elseif(mod(nacc,20) == 0 && mod(nacc,100) ~= 0 && hjump ~= 1)
        hjump = 1;
        modcov = jumps(3)^2*cvar;
      elseif(mod(nacc,50) == 0 && hjump  ~= 1)
        hjump = 1;
        modcov = jumps(4)^2*cvar;
      else
        hjump = 0;
        modcov = jumps(1)^2*cvar;
      end
    elseif nacc <= Tc(2)
      modcov = 2*cvar;
    else
      modcov = cvar;
    end
  else
    modcov = cvar;
  end
  
  % Check if the adaptive scheme is on. We need to update the covariance of
  % the current chain for the adaptive scheme. We do it every covUpdate
  % steps to respect the annealing procedures. Without the annealing, the
  % new covariance could be calculated on every iteration of the main MCMC
  % loop.
  if ADAPTIVE && nacc > covUpdate && nacc<=Tc(3) && nacc > Tc(1) + covUpdate && mod(nacc, covUpdate) == 0
    
    % Get the temporal chain & calculate the covariance
    tempChain = smpl(nacc-covUpdate:nacc, 4:end);
    newCov    = cov(tempChain);
    [xn, Sn]  = MCMC.drawAdaptiveSample(xo,newCov,epsilon);
    
  % the default non-adaptive produces proposals from the normal
  % distribution. Note: this relies on the previous if search above.
  else
    xn = proposalSampler(xo,modcov);
    Sn = cvar;
  end

end

% END