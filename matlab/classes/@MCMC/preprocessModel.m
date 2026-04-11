%--------------------------------------------------------------------------
%      Reorganize the model. Used to create lighter versions of
%      the models to be used in the main loop.
%--------------------------------------------------------------------------
function preprocessModel(algo, freqs, mdlFreqDependent)
  
  Nexp = numel(freqs);    
  
  switch class(algo.model)
    case 'matrix'
      modelout(1:Nexp) = copy(algo.model, 1);
      for kk = 1:Nexp
        for ii = 1:numel(modelout(kk).objs)
          if (mdlFreqDependent)
            % set Xvals
            modelout(kk).objs(ii).setXvals(freqs{kk});
            % set alias
            modelout(kk).objs(ii).assignalias(modelout(kk).objs(ii),plist('xvals',freqs{kk}));
          else
            modelout(kk).objs(ii).setXvals(1);
          end
        end
      end
      algo.processedModel = copy(modelout, 1);
    case 'ssm'
      algo.processedModel = copy(algo.model, 1);
      algo.processedModel.clearNumParams;
      spl = plist('set',     'for bode',...
                  'outputs', algo.params.find('outNames'), ...
                  'inputs',  algo.params.find('inNames'));
      % first optimise our model for the case in hand
      algo.processedModel.reorganize(spl);
      % make it lighter
      algo.processedModel.optimiseForFitting();
  end
  
end