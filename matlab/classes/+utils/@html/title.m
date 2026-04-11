% TITLE  returns an html string that is a title with given level
%
% CALL
%        html = title(text,level)
%
%
function html = title(text,level)

  html = sprintf('<H%d>%s</H%d>\n',level,text,level); 
 
end
