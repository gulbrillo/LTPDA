% HTMLREPSPECCHAR replace all special characters by the HTML name.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HTMLREPSPECCHAR replace all special characters by the HTML
%              name.
%
% CALL:        html = docHelper.htmlRepSpecChar(html)
%
% INPUTS:      html - HTML string
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function html = htmlRepSpecChar(html)
  
  % Cover the link(s) in the html text because this link contains special
  % characters
  found = regexp(html, '<\s*a[^>]*>(.*?)<\s*/\s*a>', 'match');
  for ii =1:numel(found)
    html = strrep(html, found{ii}, sprintf('$$$%d', ii));
  end
  
  html = strrep(html, '&', '&amp;');
  html = strrep(html, '<', '&lt;');
  html = strrep(html, '>', '&gt;');
  html = strrep(html, '|', '&#124;');
  
  % Recover the links(s)
  for ii=1:numel(found)
    html = strrep(html, sprintf('$$$%d', ii), found{ii});
  end
  
end

