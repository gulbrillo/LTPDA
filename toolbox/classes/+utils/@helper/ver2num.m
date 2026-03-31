% VER2NUM converts a version string into a number.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    ver2num
%
% DESCRIPTION: VER2NUM converts a version string into a number.
%
% CALL:        ver_num = ver2num(ver_str);
%
% INPUTS:      ver_str = major[.minor[.revision]] -> 1 or 1.2 or 1.2.3
%
% OUTPUT:      ver_num = major * 1 + minor * 0.01 + revision * 0.0001
%
% EXAMPLES:    '1'       --> 1
%              '1.2'     --> 1.02
%              '1.2.3'   --> 1.0203
%              '1.12.13' --> 1.1213
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ver_num = ver2num(ver_str)

ver_num = getVerParts(ver_str) * [1; .01; .0001];

function parts = getVerParts(ver_str)

parts = sscanf(ver_str, '%d.%d.%d')';
if length(parts) < 3
  parts(3) = 0; % zero-fills to 3 elements
end

