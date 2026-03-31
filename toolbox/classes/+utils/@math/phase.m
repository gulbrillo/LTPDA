% PHASE return the phase in degrees for a given complex input.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PHASE return the phase in degrees for a given complex
%              input. Supposed to be analogous to angle but return degrees
%              instead of radians.
%
% CALL:       p = phase(resp)
%
% INPUTS:     resp - complex number
%
% OUTPUTS:    p    - phase
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function p = phase(resp)

  p = angle(resp)*180/pi;

end

