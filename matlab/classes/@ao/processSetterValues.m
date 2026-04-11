% PROCESSSETTERVALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PROCESSSETTERVALUES.
%                1. Checks if the value is in the plist
%                2. Checks if there are more than one value that the number
%                   of values are the same as the number of objects.
%                3. Replicate the values to the number of objects.
%
% CALL:        [objs, values] = processSetterValues(objs, pls, rest, pName)
%
% IMPUTS:      objs:  Array of objects
%              pls:   Array of PLISTs or empty array
%              rest:  Cell-array with possible values
%              pName: Property name of objs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [objs, values] = processSetterValues(varargin)
  
  [objs, values] = processSetterValues@ltpda_uoh(varargin{:});
  
  % Special case for AOs
  % If the default value is a double and the user havend defined a value
  % and there are only two AOs the use the second AO as the value.
  if  nargin==5              && ...
      isnumeric(varargin{5}) && ...
      isempty(values)
    values = {objs(end)};
    objs   = objs(1:end-1);
  end
  
end

