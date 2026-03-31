% COLOR  returns an html string that represents given text with given font color  
%
% CALL
%        html = color(text)
%
%
function html = color(text, color)

  html = sprintf('<font color="%s">%s</font>',color, text); 
 
end
