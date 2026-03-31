% PAGEFOOTER returns an html string suitable for ending an html page.
%
% CALL
%        html = pageFooter()
%
%
function html = pageFooter()
  
  html = '';
  html = [html sprintf('  </body>\n')];
  html = [html sprintf('</html>')];
  
end
