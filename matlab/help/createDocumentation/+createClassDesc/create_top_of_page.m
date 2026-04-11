function create_top_of_page(fid, indentation_in)

  indentation(1:indentation_in) = ' ';

  fprintf(fid, '%s<!-- ===== Top of page ===== -->\n', indentation);
  fprintf(fid, '%s<a href="#top_of_page">\n', indentation);
  fprintf(fid, '%s  <img src="doc_to_top_up.gif" border="0" align="bottom" alt="Back to Top"/>\n', indentation);
  fprintf(fid, '%s  Back to Top\n', indentation);
  fprintf(fid, '%s</a>\n\n', indentation);

end
