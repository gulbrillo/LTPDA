%ENDBODY  returns an html string to end the body of the document.
%           It appends a hidden comment as a mark to be able to search for
%           the end of the body
%
% CALL
%        html = endBody(comment)
%
%
function html = endBody(mark)

  html = sprintf('</BODY>\n%s\n',mark);
end
