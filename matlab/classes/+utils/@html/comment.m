% COMMENT  returns an html string representing a hidden comment   
%
% CALL
%        html = comment(text)
%
%
function html = comment(text)

  html = sprintf('<!--%s-->\n',text); 
 
end
