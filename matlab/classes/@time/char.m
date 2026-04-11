% CHAR Convert a time object into a string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Convert a time object into a string.
%
% CALL:        str = char(time)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = char(varargin)

  % collect all time objects
  objs = [varargin{:}];

  % format
  str = format(objs);
end
