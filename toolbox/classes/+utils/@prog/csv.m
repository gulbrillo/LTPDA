% CSV makes comma separated list of numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CSV make comma separated list of numbers
%
% CALL:       s = csv(x)
%
% INPUTS:     x - the list of numbers to convert
%
% OUTPUTS:    s - a makes comma separated list string
%
% EXAMPLE:    s = utils.prog.csv([1:10])
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = csv(x)
  s = sprintf('%g,', x);
  s = s(1:end-1);
end
