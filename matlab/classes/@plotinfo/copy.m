% COPY makes a (deep) copy of the input plotinfo objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input plotinfo objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input plotinfo object
%              flag - true: make a deep copy, false: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input plotinfo objects
    new = plotinfo.newarray(size(old));
    
    for kk = 1:numel(old)
      if isa(old(kk).style, 'mpipeline.ltpdapreferences.PlotStyle')
        new(kk).style  = mpipeline.ltpdapreferences.PlotStyle(old(kk).style);
      end
      new(kk).includeInLegend = old(kk).includeInLegend;
      new(kk).showErrors = old(kk).showErrors;
      new(kk).axes = old(kk).axes;
      new(kk).figure = old(kk).figure;
    end
  else
    new = old;
  end
  
  varargout{1} = new;
end

