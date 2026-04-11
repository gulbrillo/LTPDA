% GETOPTIONS returns the options array for this param value.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETOPTIONS returns the options array for this param value.
%
% CALL:        val = getOptions(paramValue);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = getOptions(pvin)
  
  if numel(pvin) ~= 1
    error('### This method works only with one paramValue object.');
  end
  
  out = pvin.options;
  
end
