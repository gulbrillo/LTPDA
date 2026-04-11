% DEG2RAD Convert degrees to radians
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DEG2RAD Convert degrees to radians
%
% CALL:       r = deg2rad(deg, min, sec)
%
% INPUTS:     deg - degrees
%             min - minutes
%             sec - seconds
%
% OUTPUTS:    r   - radians
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function r = deg2rad(deg, min, sec)
  r = (deg + min/60 + sec/3600)*pi/180;
end

