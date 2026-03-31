%
% A utility function used to collect the data objects shaped in MATRIX or
% AO arrays, and keep their history at the same time.
%
% The algorithm here is used as a pointer only, and the collected AOs go
% into the hoidden property 'outputs' of the algorithm.
%
% NK 2015
%
function [inhists] = collectOutputAOs(algo, objects)
  
  ms = utils.helper.collect_objects(objects, 'matrix', {});
  bs = utils.helper.collect_objects(objects, 'ao', {});
  
  if ~isempty(ms) && ~isempty(bs)
    error('### Please provide data either as matrix objects or AOs, but not both...');
  end
  
  if ~isempty(ms)
    
    inhists = ms.hist;
    
    Nout = numel(ms(1).objs);
    Nexp = numel(ms);
    
    aos = ao.initObjectWithSize(Nout, Nexp);
    
    for jj = 1:Nexp
      for ii = 1:Nout
        aos(ii,jj) = copy(ms(jj).getObjectAtIndex(ii,1), 1);
      end
    end
    
  elseif ~isempty(bs)
    
    inhists = bs.hist;
    
    aos = copy(bs, 1);
    
  elseif strcmpi(class(algo.model), 'mfh')
    % do nothing, assign only empty objects
    aos     = [];
    inhists = [];
  else
    error(['### Please provide system output data either as matrix objects or an array of AOs. '...
           'Unless the model is a MFH object.']);
  end
  
  % Fill therelevant fields
  algo.outputs = aos;
  
end % End of collectOutputAOs