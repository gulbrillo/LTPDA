function create_class_desc()
  
  fprintf('\n  - Create documentation of the class description: ');
  ltpdaclasses = utils.helper.ltpda_userclasses();
  
  main_link_box{1,1} = 'Properties';  main_link_box{1,3} = 'Properties of the class';
  main_link_box{2,1} = 'Methods';     main_link_box{2,3} = 'All Methods of the class ordered by category.';
  main_link_box{3,1} = 'Examples';    main_link_box{3,3} = 'Some constructor examples';
  
  for ii = 1:length(ltpdaclasses)
    
    fprintf('+');
    class_name = ltpdaclasses{ii};
    
    html_filename = sprintf('class_desc_%s.html', class_name);
    
    if ismember(class_name, ltpdaclasses)
      html_example_filename = sprintf('constructor_examples_%s.html', class_name);
    else
      html_example_filename = 'constructor_examples_main.html';
    end
    
    meta_obj = meta.class.fromName(class_name);
    
    main_link_box{1,2} = [html_filename '#top_properties'];
    main_link_box{2,2} = [html_filename '#top_methods'];
    main_link_box{3,2} = html_example_filename;
    
    outfile = fullfile(createClassDesc.getAbsPathToHtmlFiles(), sprintf('class_desc_%s_content.html', class_name));
    fid_write = fopen(outfile, 'w');
    
    fprintf(fid_write, '<!-- $Id$ -->\n\n');
    
    fprintf(fid_write, '  <!-- ================================================== -->\n');
    fprintf(fid_write, '  <!--                 BEGIN CONTENT FILE                 -->\n');
    fprintf(fid_write, '  <!-- ================================================== -->\n');
    
    docHelper.htmlAddLinkTable(fid_write, main_link_box, 'categorylist', 2);
    
    fprintf(fid_write, '  <!-- ===== Back to Class descriptions ===== -->\n');
    fprintf(fid_write, '  <a href="class_desc_main.html">\n');
    fprintf(fid_write, '    <img src="doc_to_top_up.gif" border="0" align="bottom" alt="Back to Class descriptions"/>\n');
    fprintf(fid_write, '    Back to Class descriptions\n');
    fprintf(fid_write, '  </a>\n\n');
    
    createClassDesc.create_property_desc(fid_write, meta_obj, 2);
    
    createClassDesc.create_methods_desc(fid_write, meta_obj, html_filename, 2);
    
    fprintf(fid_write, '  <!-- ================================================== -->\n');
    fprintf(fid_write, '  <!--                  END CONTENT FILE                  -->\n');
    fprintf(fid_write, '  <!-- ================================================== -->\n');
    
    fclose(fid_write);
    
  end
  
  fprintf('finished.\n');
  
end

