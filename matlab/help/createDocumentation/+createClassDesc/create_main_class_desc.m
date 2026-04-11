function create_main_class_desc()
  
  cls = utils.helper.ltpda_userclasses();
  link_box = cell(numel(cls), 3);
  
  for ii=1:numel(cls)
    link_box{ii,1} = sprintf('%s class', upper(cls{ii}));
    link_box{ii,2} = sprintf('class_desc_%s.html', cls{ii});
    link_box{ii,3} = docHelper.getDescriptionForClass(cls{ii});
  end
  
  fprintf('\n  - Create main documentation of the class description: ');
  
  outfile = fullfile(createClassDesc.getAbsPathToHtmlFiles(), 'class_desc_main_content.html');
  fid = fopen(outfile, 'w');
  
  fprintf(fid, '<!-- $Id$ -->\n\n');
  
  fprintf(fid, '  <!-- ================================================== -->\n');
  fprintf(fid, '  <!--                 BEGIN CONTENT FILE                 -->\n');
  fprintf(fid, '  <!-- ================================================== -->\n');
  
  docHelper.htmlAddLinkTable(fid, link_box, 'categorylist', 2, 100)
  
  fprintf(fid, '  <!-- ================================================== -->\n');
  fprintf(fid, '  <!--                  END CONTENT FILE                  -->\n');
  fprintf(fid, '  <!-- ================================================== -->\n');
  
  fclose(fid);
  
  fprintf('finished.\n');
  
end


