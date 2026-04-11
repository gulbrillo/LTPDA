

function mkMainHtml(mainFuncByCatFilename, cls)
  
  relPathToMainHelp = strcat(createFuncByCat.getRelPathToHelp(), 'ug/');
  
  fprintf('\n  - Create main page of the section: Function by Category - ');

  % Create folder
  mkdir(createFuncByCat.getAbsPathToHtmlFiles)
  
  % Creat file
  fid = fopen(fullfile(createFuncByCat.getAbsPathToHtmlFiles, mainFuncByCatFilename), 'w+');
  
  % Add <HTML> tag
  docHelper.htmlAddHtmlTag(fid);
  
  % Add <HEAD>
  docHelper.htmlAddHeadTag(fid, 'Main page of the section: Functions by Category', relPathToMainHelp);
  
  % Add <BODY> tag
  docHelper.htmlAddBodyTag(fid);
  
  % Add top navigation table
  docHelper.htmlAddTopNavTable(fid, '', '', '', '', relPathToMainHelp)

  % Add <H1> tag
  docHelper.htmlAddH1Tag(fid, 'Function Reference');
  
  table = cell(numel(cls), 3);
  for ii=1:numel(cls)
    table{ii,1} = sprintf('%s class', upper(cls{ii}));
    table{ii,2} = sprintf('%s_main_funcByCat.html', lower(cls{ii}));
    table{ii,3} = docHelper.getDescriptionForClass(cls{ii});
  end
  
  docHelper.htmlAddLinkTable(fid, table, 'categorylist', 2, 100)
  
  % Add bottom navigation table
  docHelper.htmlAddBotNavTable(fid, '', '', 'ao_main_funcByCat.html', 'Categories of the Class AO', relPathToMainHelp)
  
  % Add </BODY> and </HTML> tags
  fprintf(fid, '   </body>\n');
  fprintf(fid, '</html>\n');
  
  fclose(fid);
  
  fprintf('finished.\n');
  
end



