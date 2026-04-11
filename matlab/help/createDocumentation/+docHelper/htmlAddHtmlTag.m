% HTMLADDHTMLTAG adds the <HTML> tag to the file descriptor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HTMLADDHTMLTAG adds the <HTML> tag to the file descriptor.
%
% CALL:        docHelper.htmlAddHtmlTag(fid)
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function htmlAddHtmlTag(fid)
  
  % Add DOCTYPE
  fprintf(fid, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">\n');
  fprintf(fid, '\n');
  
  % Add <HTML> tag
  fprintf(fid, '<!-- $Id$ -->\n');
  fprintf(fid, '<html lang="en">\n');
  
end
