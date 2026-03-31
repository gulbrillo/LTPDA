% ISEMPTYUNIT overloads the isequal operator for ltpda unit objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ISEMPTYUNIT overloads the isequal operator for ltpda unit objects.
%
%              Two units are considered equal if each has the same unit
%              components with the same exponents and prefixes. The order
%              of the units doesn't matter.
%
% CALL:        result = isemptyunit(u)
%
% INPUTS:      u         - Input objects
%
% OUTPUTS:     If the two objects are considered equal, result == true,
%              otherwise, result == false.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = isemptyunit(objs, varargin)
  
  import utils.const.*
  
  result  = false;
    
  for jj = 1:numel(objs)
    
    % compare these two units
    result(jj) = isequal(objs(jj), unit());
    
  end
  
end
