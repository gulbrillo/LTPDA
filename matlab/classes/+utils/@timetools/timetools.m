% TIMETOOLS class for tools to manipulate the time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TIMETOOLS class for tools to manipulate the time.
%
% TIMETOOLS METHODS:
%
%     Static methods:
%       utc2gps         - Converts UTC time to GPS seconds.
%       gps2utc         - Converts GPS seconds to UTC time.
%       reformat_date   - Reformats the input date
%
% HELP:        To see the available static methods, call
%              >> methods utils.timetools
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef timetools

  %------------------------------------------------
  %--------- Declaration of Static methods --------
  %------------------------------------------------
  methods (Static)

    %-------------------------------------------------------------
    % List other methods
    %-------------------------------------------------------------

    GPS_time = gpsnow()          % Returns the current GPS time based on the system clock.
    GPS_time = utc2gps(UTC_time) % Converts UTC time to GPS seconds.
    UTC_time = gps2utc(GPS_time) % Converts GPS seconds to UTC time.
    s        = reformat_date(s)  % Reformats the input date
    timeZone = getTimezone(varargin) % Get the list of supported timezones

  end % End static methods

end

