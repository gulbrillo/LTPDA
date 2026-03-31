% SETLEGENDLOCATION gets an array of legends from the given figure handle
% and set the legend location to the desired position specified in input
% cell array
% 
% CALL:
%        legendArray = setLegendLocation(figureHandle,cellArray)
%
% NOTE: cellArray is a cell array with a location string per legend
% location strings are listed in Matlab documentation, see: doc legend
% 

function varargout = setLegendLocation(fh,cellArray) 

  % get legend array out of figure handle
  legendArray = utils.plottools.getLegends(fh);
  % consistency check
  if numel(legendArray)~=numel(cellArray)
    error('Number of legend locations does not correspond to number of legend objects. Input a cell array with %d legend location strings.',numel(legendArray));
  end
  for kk=1:numel(legendArray)
    set(legendArray(kk),'Location',cellArray{kk});
  end
  
  if nargout~=0
    varargout{1} = legendArray;
  end
 
end
% END