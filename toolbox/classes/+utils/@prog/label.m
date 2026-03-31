function s = label(si)
% LABEL makes the input string into a suitable string for using on plots.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LABEL makes the input string into a suitable string for
%              using on plots.
%
% CALL:       s = label(sin)
%
% INPUTS:     sin - input string
%
% OUTPUTS:    s   - suitable string for the plot functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s = strrep(si, '_', '\_');
