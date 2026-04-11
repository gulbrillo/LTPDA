%BEGINBODY  returns an html string to start the body of the document.
%           It prepends a hidden comment as a mark to be able to search for
%           the begin of the body
% CALL
%        html = beginBody(begin_mark)
%
%
function html = beginBody(mark)
 
  html = sprintf('%s\n<BODY>\n',mark);
end
