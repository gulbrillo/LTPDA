% MUP2MAT converts Mupad string to MATLAB string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MUP2MAT converts:
% MUP2MAT converts the Mupad string r containing
% matrix, vector, or array to a valid MATLAB string.
%
% NOTE: Copied from the Symbolic Toolbox function sym/matlabFunction
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function r = mup2mat(r)
  
  r = strtrim(char(r));
  % Special case of the empty matrix or vector
  if strcmp(r,'vector([])') || strcmp(r,'matrix([])') || ...
      strcmp(r,'array([])')
    r = '[]';
  else
    % Remove matrix, vector, or array from the string.
    r = strrep(r,'matrix([[','['); r = strrep(r,'array([[','[');
    r = strrep(r,'vector([','['); r = strrep(r,'],[',';');
    r = strrep(r,']])',']'); r = strrep(r,'])',']');
  end
end
