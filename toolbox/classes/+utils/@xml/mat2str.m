% MAT2STR overloads the mat2str operator to set the precision at a central place.
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
  
  MAX_PRECISION = 20;
  
  s = size(number);
  if s(1) ~= 1 && s(2) ~= 1
    str = mat2str(number, MAX_PRECISION);
    
  elseif isreal(number)
    
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
    str = mat2str(number, MAX_PRECISION);
  end
  
  % Make sure that the string have brackets (necessary for eval(str))
  if ~isempty(str) && str(1) ~= '['
    str = ['[' str ']'];
  end
  
  % Cast the number to the right numeric data type if the input number is
  % NOT a double.
  if ~isa(number, 'double')
    str = strcat(class(number), '(', str, ')');
  end
  
end

