%PARAGRAPH  returns an html string  to add a paragrapgh to a HTML document
%
% CALL
%        html = paragraph()
%
%
function html = paragraph(text)

  html = sprintf('<pre>%s</pre>\n',text); 
  
end
