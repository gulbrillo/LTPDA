%ITEM  returns an html string  add an enumeration item with given text, in HTML
%
% CALL
%        html = item()
%
%
function html = item(text)

  html = sprintf('\t<li>%s</li>\n',text); 

end
