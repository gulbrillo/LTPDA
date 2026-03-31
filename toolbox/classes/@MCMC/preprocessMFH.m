% PREPROCESSMFH.M
% 
% A utility function to obtain the pure
% Matlab function handle out of a MFH object.
%
% Used for fast computations with the MCMC.
%
% NK 2014
%
function fh = preprocessMFH(xo, f)
  
  % Check if SNR calculation is available
  try
    
    % create function handle
    fh_str = f.function_handle();
    
    % declare objects locally
    declare_objects(f);
    
    % create function handle
    fh = eval(fh_str);
    
    [out1, out2] = fh(xo);
    
  catch err
    fprintf(['### Failed to extract second output from the input function... '...
             'Used for the case where the SNR is returned from the loglikelihood function. \n'...
             'Error: %s \n'], err.message);
           
    % This is needed in case the cost function
    % returns only one output.
    if numel(f.inputs) == 2
      % in case the proposal is input
      fh = @(p,C) deal(double(eval(f, p,C)));
    else
      fh = @(p) deal(double(eval(f, p)));
    end
  end
end
% END