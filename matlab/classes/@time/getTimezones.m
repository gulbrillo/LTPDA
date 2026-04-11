% GETTIMEZONES Get all possible timezones.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get all possible timezones.
%
% CALL:        zones = obj.getTimezones();
%
% INPUTS:      obj - can be a vector, matrix, list, or a mix of them.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getTimezones(varargin)

  varargout{1} = utils.timetools.getTimezone;

end

