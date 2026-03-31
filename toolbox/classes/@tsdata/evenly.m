% EVENLY defines if the data is evenly sampled or not
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% DESCRIPTION: 
%
% CALL:     evenly = evenly(data)
%
% INPUTS:   tsdata - a tsdata object
%
% OUTPUTS:  evenly - signals whether the data is regularly sampled or not
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function evenly = evenly(data)

  % if the x vector has a null dimension ether the tsdata is empty or
  % the x vector has been collapsed. in those cases the data is
  % assumed to be evenly sampled
  if isempty(data.xaxis.data)
    evenly = true;
    return;
  end
  
  % otherwise we fall back to the fitfs method
  [~, ~, uneven] = tsdata.fitfs(data.getX);
  evenly = ~uneven;
  
end

