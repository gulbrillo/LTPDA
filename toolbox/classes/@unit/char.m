% CHAR convert a unit object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a unit object into a string.
%
% CALL:        string = char(unit)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = char(v)
  str = ' ';
  for jj = 1:numel(v)
    NDimensions = numel(v(jj).strs);
    if NDimensions == 0
      nameString = '[]';
    else
      nameString = '';
      vjj = v(jj);
      for nd = 1:NDimensions
        if(vjj.exps(nd) ~= 0)
          pval = vjj.vals(nd);
          nameString = [nameString '['];
          prefix = unit.val2prefix(pval);
          nameString = [nameString prefix];
          exponent = vjj.exps(nd);
          % handle some common cases
          if exponent == 1
            n = 1; d = 1;
          elseif exponent == -1
            n = -1; d = 1;
          elseif exponent == 2
            n = 2; d = 1;
          elseif exponent == -2
            n = -2; d = 1;
          else
            [n, d] = rat(exponent);
          end
          if d == 1
            if vjj.exps(nd) ~= 1
              nameString = sprintf('%s%s^(%g)]', nameString, vjj.strs{nd}, vjj.exps(nd));
            else
              nameString = [nameString  vjj.strs{nd} ']'];
            end
          else
            nameString = sprintf('%s%s^(%g/%g)]', nameString, vjj.strs{nd}, n, d);
          end
        else
          nameString = [nameString '[]'];
        end
      end
    end
    str_loop = strrep(nameString, '][', ' ');
    str = [str, str_loop];
  end
  
  str = strtrim(str);
end
