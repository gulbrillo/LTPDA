function htmlAddTopOfPageLink(fid, indent, relPathToMainHelp)
  
  indentStr = blanks(indent);
  toTopArrowFile = strcat(relPathToMainHelp, 'doc_to_top_up.gif');
  
  fprintf(fid, '%s<!-- ===== Top of page ===== -->\n', indentStr);
  fprintf(fid, '%s<a href="#top_of_page">\n', indentStr);
  fprintf(fid, '%s  <img src="%s" border="0" align="bottom" alt="Back to Top"/>\n', indentStr, toTopArrowFile);
  fprintf(fid, '%s  Back to Top\n', indentStr);
  fprintf(fid, '%s</a>\n\n', indentStr);
  
end
