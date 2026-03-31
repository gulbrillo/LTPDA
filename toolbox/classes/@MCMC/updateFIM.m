%--------------------------------------------------------------------------
% Update the Fisher Matrix
%--------------------------------------------------------------------------
function [cov, dstep] = updateFIM(data, param, xo, lp, mdl, freqs, dstep, ngrid, ranges, inNames, outNames)
  
   error('This function, of updating the FIM has to be updated... Sorry for the inconvnience')

   model = copy(mdl, 1);
  
   % Simplify the model for bode
   if isa(model, 'ssm')
     model.setParameters(plist('names',param,'values',xo));
     model.simplify(plist('inputs', inNames, 'outputs', outNames));
   end
   
   [FisMat, dstep] = fisher(...
                           model,...
                           data,...
                           param,...
                           xo,...
                           lp,...
                           freqs,...
                           dstep, ...
                           ngrid, ...
                           ranges...
                           );
   
   % inverse is the optimal covariance matrix
   cvar = FisMat\eye(size(FisMat));
   
   % Scale it
   cov = (numel(param)^(-1/2))*ao(cvar);
   
end