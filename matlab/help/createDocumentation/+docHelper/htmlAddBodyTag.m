% HTMLADDBODYTAG adds the <BODY> tag to the file descriptor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HTMLADDBODYTAG adds the <BODY> tag to the file descriptor.
%
% CALL:        docHelper.htmlAddBodyTag(fid)
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function htmlAddBodyTag(fid)
  
  fprintf(fid, '  <body>\n');
  fprintf(fid, '\n');
  fprintf(fid, '    <a name="top_of_page" id="top_of_page"></a>\n');
  fprintf(fid, '    <p style="font-size:1px;">&nbsp;</p>\n');
  fprintf(fid, '\n');
  
end
