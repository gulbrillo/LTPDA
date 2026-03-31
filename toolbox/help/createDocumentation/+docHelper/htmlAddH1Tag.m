% HTMLADDH1TAG adds the <H1> tag to the file descriptor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HTMLADDH1TAG adds the <H1> tag to the file descriptor.
%
% CALL:        docHelper.htmlAddH1Tag(fid)
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function htmlAddH1Tag(fid, title)
  
  fprintf(fid, '\n');
  fprintf(fid, '    <h1 class="title">%s</h1>\n', title);
  fprintf(fid, '    <hr />\n\n');
  
end
