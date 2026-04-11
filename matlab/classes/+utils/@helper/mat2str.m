% MAT2STR overloads the mat2str operator to set the precision at a central place.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MAT2STR overloads the mat2str operator to set the
%              precision at a central place.
%
% CALL:        str = mat2str(number);
%              str = mat2str(matrix);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = mat2str(number)
  
  if isempty(number)
    str = '[]';
    return
  end
  
  if isvector(number) && isreal(number)    
    s = size(number);
    % For vectors it is faster to use sprintf directly
    if s(1) ~= s(2)
      str = '[';
    else
      str = '';
    end
    if s(1) > s(2)
      str = [str sprintf('%.17g;', number)];
    else
      str = [str sprintf('%.17g ', number)];
    end
    if s(1) ~= s(2)
      str = [str(1:end-1) ']'];
    else
      str = str(1:end-1);
    end
    
  else
    str = mat2str(number, 20);
  end
  
end
  
