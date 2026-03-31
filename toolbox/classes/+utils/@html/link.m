% LINK  returns an html string that is a link to a given URL, in html.
%
% CALL
%        html = link(URL,title)
%
%
function html = link(URL, title)

  html = sprintf('<a href="%s">%s</a>',URL,title); 
 
end
