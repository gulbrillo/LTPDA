% NUM2STR uses sprintf to convert a data vector to a string with a fixed precision.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: uses sprintf to convert a data vector to a string with a fixed precision.
%
% CALL:        str = num2str(number);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = num2str(number)
  str = sprintf('%.17g ', number);
end

