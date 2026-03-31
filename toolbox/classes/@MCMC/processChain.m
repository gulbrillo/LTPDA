% PROCESSCHAIN: Get the statisticts of the MCMC Chain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ProcessChain:  Returns the statisticts of the MCMC Chain
%
%         CALL:  p = processChain(chain, Tc, dbg_info, plot_flag)
%
%       INPUTS:  The MCMC chain and the Tc, the vector that defines the 
%                i-th sample to be descarded and a debugging flag.
%
%      OUTPUTS:  A pest objects with the statsistics of the MCMC chain.
%                Most information is stored in the procinfo property of the
%                pest object.
%
%  NK 2012     
%
function [mn, cv, cr, PSRF, T, X, KStest] = processChain(smpl, Tc, dbg_info, plot_diag)

  % print message
  fprintf('* Processing MCMC chains ... \n') 
  
  import utils.const.*
  
  nparam = size(smpl,2)-3;

  % Get rid of the burn-in samples
  if isempty(Tc)
    initial = 1;
  elseif numel(Tc) == 2
    initial = Tc(2)+1;
  else 
    initial = Tc(end)+1;
  end
  
  chain = smpl(initial:end,4:size(smpl,2));
  
  % Get mean and covariance
  mn = mean(chain);
  cv = cov(chain);

  % Calculate correlation of the parameters
  cr = utils.math.cov2corr(cv);
  
  try 
    
    % Get autocorrelation plot
    T  = utils.math.getCorr(chain, plot_diag);
    
    catch err
   
    mess = sprintf(['An error was produced while running diagnostics \n'...
                    'on the chains (autocorrelation). The error message is: "%s".'], err.message);
          
    utils.helper.msg(msg.PROC1, mess, mfilename('class'), mfilename);      
                                
    me = 'Not computed due to errors...';                      
    T  = me;
    
  end
  
  try

    % Yu-Mykland convergence diagnostic
    X = utils.math.ymcd(chain, dbg_info, plot_diag);
    
    catch err
   
    mess = sprintf(['An error was produced while running diagnostics \n'...
                    'on the chains (YM). The error message is: "%s".'], err.message);
          
    utils.helper.msg(msg.PROC1, mess, mfilename('class'), mfilename);      
                                
    me = 'Not computed due to errors...';                            
    X  = me;
    
  end

  try
    % Calculate Potential Scale Reduction Factor
    PSRF = utils.math.psre(dbg_info, chain);
    
  catch err
   
    mess = sprintf(['An error was produced while running diagnostics \n'...
                    'on the chains (PSRF). The error message is: "%s".'], err.message);
          
    utils.helper.msg(msg.PROC1, mess, mfilename('class'), mfilename);      
                                
    me   = 'Not computed due to errors...';                            
    PSRF = me;

    
  end
  
  try

    % Perform a Kolmogorov-Smirnov test to the first and last third of chains
    n    = floor(size(chain,1)/3);
    c1   = chain(1:n,:);
    c2   = chain((end-n+1):end,:);
    H    = zeros(1,nparam);  
    stat = cell(1,nparam);
    cVal = zeros(1,nparam);

    for ii =1:nparam
      [H(ii), stat{ii}, cVal(ii)] = utils.math.kstest(c1(:,ii), c2(:,ii), 0.05);
    end

    KStest.H    = H;
    KStest.cval = cVal;
    KStest.stat = stat;
  
  catch err
   
    mess = sprintf(['An error was produced while running diagnostics \n'...
                    'on the chains (KS). The error message is: "%s".'], err.message);
          
    utils.helper.msg(msg.PROC1, mess, mfilename('class'), mfilename);      
                                
    me     = 'Not computed due to errors...';
    KStest = me;
    
  end
  
end

% END