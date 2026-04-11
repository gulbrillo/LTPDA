% DEFINELOGLIKELIHOOD.M
% 
% A utility function that creates a function handle out of
% a given log-likelihood. The function is passed to the main
% sampling loop oof the algorithm.
%
% NK 2014
%
function logL = defineLogLikelihood(xo, model, data, param, lp, minFunc, Nexp, freqs, pl)

  if isempty(minFunc)
      
    outNames = find(pl, 'outNames');
    inNames  = find(pl, 'inNames');  
      
    spl(1:Nexp) = plist();
  
    % Define bode plist for ssm models
    for kk = 1:Nexp
      spl(kk) = plist('reorganize', false, 'f', freqs{kk},...
                    'inputs',inNames,'outputs',outNames);
    end  
    
    logL = @(x) loglikelihood_core(model, x, data, param, lp, spl);
    
  elseif ~isempty(minFunc) && strcmpi(class(minFunc), 'function_handle')
    
    logL = @(p) deal(minFunc(p));
    
  elseif strcmpi(class(minFunc), 'mfh')
    
    logL = MCMC.preprocessMFH(xo, minFunc);
    
  else
    error(['The model must be either a Matrix or a SSM object. If a log-likelihood '...
           'function is defined, it must be from the ''mfh'' class'])
  end
  
  % Evaluate function handle in order to check it
  try
    logL(xo);
  catch Me
    error('The evaluation of the function handle failed. Please check it again. Error: [%s]', Me.message)
  end
  
end

% END