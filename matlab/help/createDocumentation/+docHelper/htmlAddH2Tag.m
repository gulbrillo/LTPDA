% HTMLADDH2TAG adds the <H2> tag to the file descriptor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HTMLADDH2TAG adds the <H2> tag to the file descriptor.
%
% CALL:        docHelper.htmlAddH2Tag(fid, title)
%              docHelper.htmlAddH2Tag(fid, title, h2_class)
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function htmlAddH2Tag(fid, title, h2_class)
  
  if nargin < 3
    h2_class = '';
  else
    h2_class = sprintf(' class="%s"', h2_class);
  end
  
  fprintf(fid, '\n');
  fprintf(fid, '    <h2%s>%s</h2>\n', h2_class, title);
  
end
