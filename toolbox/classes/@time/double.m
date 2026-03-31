% DOUBLE Converts a time object into a double
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Converts a time object into a double.  The result is the number
% of seconds elapsed since the unix epoch, 1970-01-01 00:00:00.000 UTC.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function d = double(varargin)
  obj = [varargin{:}];
  d = reshape([ obj.utc_epoch_milli ] / 1000.0, size(obj));
end
