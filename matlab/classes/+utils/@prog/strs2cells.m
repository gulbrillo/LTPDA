function cell = strs2cells(varargin)
% STRS2CELLS convert a set of input strings to a cell array.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRS2CELLS convert a set of input strings to a cell array.
%
% CALL:       cell = strs2cells(str1, str2, ...)
%
% INPUTS:     str1 - string
%             str2 - string
%                     ...
%
% OUTPUTS:    cell - cell array of the input strings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cell = [];
for j=1:nargin
  cell = [cell cellstr(varargin{j})];
end



% END