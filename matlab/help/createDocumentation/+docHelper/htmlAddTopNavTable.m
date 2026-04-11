

function htmlAddTopNavTable(fid, preHtml, preTitle, postHtml, postTitle, relPathToMainHelp)
  
  prevArrowFile = strcat(relPathToMainHelp, 'b_prev.gif');
  nextArrowFile = strcat(relPathToMainHelp, 'b_next.gif');
  helptocFile   = strcat(relPathToMainHelp, '../helptoc.html');
  
  fprintf(fid, '    <table class="nav" summary="Navigation aid" border="0" width="100%%" cellpadding="0" cellspacing="0">\n');
  fprintf(fid, '      <tr>\n');
  fprintf(fid, '        <td valign="baseline"><b>LTPDA Toolbox&trade;</b></td>\n');
  fprintf(fid, '        <td><a href="%s">contents</a></td>\n', helptocFile);
  if isempty(preHtml) && isempty(postHtml)
    % No arrows
    fprintf(fid, '        <td valign="baseline" align="right" width="194">&nbsp;&nbsp;&nbsp;</td>\n');
  else
    fprintf(fid, '        <td valign="baseline" align="right"><a href="%s"><img src="%s" border="0" align="bottom" alt="%s"></a>&nbsp;&nbsp;&nbsp;<a href="%s"><img src="%s" border="0" align="bottom" alt="%s"></a></td>\n', preHtml, prevArrowFile, preTitle, postHtml, nextArrowFile, postTitle);
  end
  fprintf(fid, '      </tr>\n');
  fprintf(fid, '    </table>\n');
end
