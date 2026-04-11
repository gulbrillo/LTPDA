

function htmlAddBotNavTable(fid, preHtml, preTitle, postHtml, postTitle, relPathToMainHelp)
  
  prevArrowFile = fullfile(relPathToMainHelp, 'b_prev.gif');
  postArrowFile = fullfile(relPathToMainHelp, 'b_next.gif');
  
  fprintf(fid, '    <br>\n');
  fprintf(fid, '    <br>\n');
  fprintf(fid, '    <table class="nav" summary="Navigation aid" border="0" width="100%%" cellpadding="0" cellspacing="0">\n');
  fprintf(fid, '      <tr valign="top">\n');
  if ~isempty(preHtml)
    fprintf(fid, '        <td align="left" width="20"><a href="%s"><img src="%s" border="0" align="bottom" alt="%s"></a>&nbsp;</td>\n', preHtml, prevArrowFile, preTitle);
    fprintf(fid, '        <td align="left">%s</td>\n', preTitle);
  end
  fprintf(fid, '        <td>&nbsp;</td>\n');
  if ~isempty(postHtml)
    fprintf(fid, '        <td align="right">%s</td>\n', postTitle);
    fprintf(fid, '        <td align="right" width="20"><a href="%s"><img src="%s" border="0" align="bottom" alt="%s"></a></td>\n', postHtml, postArrowFile, postTitle);
  end
  fprintf(fid, '      </tr>\n');
  fprintf(fid, '    </table>\n');
  fprintf(fid, '\n');
  fprintf(fid, '    <br/>\n');
  fprintf(fid, '    <p class="copy">&copy;LTP Team</p>\n');
  fprintf(fid, '\n');
  
end
