% LABEL makes the input string into a suitable string for using on plots.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LABEL makes the input string into a suitable string for
%              using on plots.
%
% CALL:        s = label(sin)
%
% INPUTS:      sin - input string
%
% OUTPUTS:     s   - suitable string for the plot functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = label(si)

  s = strrep(si, '_', '\_');

end


