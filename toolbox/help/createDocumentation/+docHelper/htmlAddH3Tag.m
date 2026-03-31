% HTMLADDH3TAG adds the <H3> tag to the file descriptor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HTMLADDH3TAG adds the <H3> tag to the file descriptor.
%
% CALL:        docHelper.htmlAddH3Tag(fid, title)
%              docHelper.htmlAddH3Tag(fid, title, h3_class)
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function htmlAddH3Tag(fid, title, h3_class)
  
  if nargin < 3
    h3_class = '';
  else
    h3_class = sprintf(' class="%s"', h3_class);
  end
  
  fprintf(fid, '\n');
  fprintf(fid, '    <h3%s>%s</h3>\n', h3_class, title);
  
end
