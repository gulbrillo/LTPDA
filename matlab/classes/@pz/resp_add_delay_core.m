% resp_add_delay_core Simple core method to add a pure delay in frequency domain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Simple core method to add a pure delay in frequency domain
%
% CALL:        r = resp_add_delay_core(r, f, delay)
%
% INPUTS:      f:       frequency response
%              r:       array of frequencies
%              delay:   delay
%                  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function r = resp_add_delay_core(r, f, delay)

    f = reshape(f,size(r));
  
    r = r .* exp(-2*pi*f*1i*delay); % Row vector

end


  