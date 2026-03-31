% resp_pz_Q_core Simple core method to compute the response of a pz model (with Q>=0.5)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Simple core method which computes the response of a pz model
%
% CALL:        r = resp_pz_Q_core(f, f0, Q)
%
% INPUTS:      f:   frequencies
%              f0:  pole/zero frequency
%              Q:   quality factor
%                  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function r = resp_pz_Q_core(f, f0, Q)

    re = 1 - (f.^2./f0^2);
    im = f ./ (f0*Q);
    r = 1./complex(re, im);

end

