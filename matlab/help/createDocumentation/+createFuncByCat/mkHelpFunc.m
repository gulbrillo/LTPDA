


function mkHelpFunc(htmlFilename, metaFcn, className, prevHtmlFilename, postHtmlFilename)
  
  fcnName = metaFcn.Name;
  
  relPathToMainHelp = strcat(createFuncByCat.getRelPathToHelp(), 'ug/');
  fid = fopen(fullfile(createFuncByCat.getAbsPathToHtmlFiles, htmlFilename), 'w');
  
  % Add <HTML> tag
  docHelper.htmlAddHtmlTag(fid);
  
  % Add <HEAD> tag
  htmlTitle = sprintf('LTPDA Method: %s/%s', className, fcnName);
  docHelper.htmlAddHeadTag(fid, htmlTitle, relPathToMainHelp);
  
  % Add <BODY> tag
  docHelper.htmlAddBodyTag(fid);
  
  % Add top navigation table
  preHtml   = prevHtmlFilename;
  preTitle  = createFuncByCat.getAltFromFilename(prevHtmlFilename);
  postHtml  = postHtmlFilename;
  postTitle = createFuncByCat.getAltFromFilename(postHtmlFilename);
  docHelper.htmlAddTopNavTable(fid, preHtml, preTitle, postHtml, postTitle, relPathToMainHelp)
  
  % Add <H1> tag
  docHelper.htmlAddH1Tag(fid, sprintf('Method %s/%s', className, fcnName));
  
  % Add the help text
  docHelper.htmlAddHelp(fid, className, fcnName);
  
  % Add striped table with two columns
  table = cell(5,2);
  table{1,1} = 'Method Details'; table{1,2} = '';
  table{2,1} = 'Access';         table{2,2} = metaFcn.Access;
  table{3,1} = 'Defining Class'; table{3,2} = metaFcn.DefiningClass.Name;
  table{4,1} = 'Sealed';         table{4,2} = num2str(metaFcn.Sealed);
  table{5,1} = 'Static';         table{5,2} = num2str(metaFcn.Static);
  docHelper.htmlAddStripedTable(fid, 4, table);
  
%   disp(' ein link für edit einbauen?');  
  
  try
    m = feval(sprintf('%s.getInfo', className), fcnName);
    txt = m.tohtmlTable(createFuncByCat.getRelPathToHelp);
    fprintf(fid, '    <a name="top_of_page" id="top_of_page"></a>\n');
    fprintf(fid, '    <h2>Parameter Description</h2>');
    fprintf(fid, '    <a name="down" id="down"></a>');
    fprintf(fid, '\n');
    fprintf(fid, '%s', txt);
    fprintf(fid, '\n');
  catch
  end
  
  % Add bottom navigation table
  docHelper.htmlAddBotNavTable(fid, preHtml, preTitle, postHtml, postTitle, relPathToMainHelp)
  
  % Add </BODY> and </HTML> tags
  fprintf(fid, '   </body>\n');
  fprintf(fid, '</html>\n');
  
  fclose(fid);
  
end
