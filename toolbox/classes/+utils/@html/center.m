%CENTER  returns an html string to center the given text 
%
% CALL
%        html = center()
%
%



function html = center(text)

  html = sprintf('<center>%s</center>\n',text); 

end
