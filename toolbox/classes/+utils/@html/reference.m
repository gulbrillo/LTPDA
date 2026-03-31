% REFERENCE  returns an html string that is a link to a previously set
% label of the same document, in HTML.
%
% CALL
%        html = reference(label,title)
%
%
function html = reference(label, title)

  html = sprintf('<a href="#%s">%s</a>\n',label,title); 
 
end
