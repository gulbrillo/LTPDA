% UNWRAPDEG Unwrap a phase vector given in degrees.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: UNWRAPDEG Unwrap a phase vector given in degrees.
%
% CALL:       deg = unwrapdeg(phase)
%
% INPUTS:     phase - phase vector
%
% OUTPUTS:    deg   - degrees vector
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function deg = unwrapdeg(phase)
  deg = unwrap(phase*pi/180)*180/pi;
end
% END
