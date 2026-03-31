

function mkMain()
  
  cls = utils.helper.ltpda_userclasses();
  
  mainFuncByCatFilename = 'mainFuncByCat.html';
  prevHtmlFilename      = '../../ug/class_desc_timespan.html';
  
  % Remove "Function By Category" folder to make sure that we have a clean
  % documentation.
  xml_path = createFuncByCat.getAbsPathToXmlFile();
  [success, message, mid] = rmdir(xml_path, 's');
  
  % Create the folder again
  mkdir(xml_path);
  xml_filename = fullfile(xml_path, 'helpfuncbycat.xml');
  xml_fid      = fopen(xml_filename, 'w+');
  
  if xml_fid < 0
    error('Failed to create %s', xml_filename);
  end    
  
  %%%%% Add to XML the item: Main
  fprintf(xml_fid, '<!-- $Id$ -->\n\n');
  fprintf(xml_fid, '<toc version="2.0">\n');
  fprintf(xml_fid, '  <tocitem target="%s">Functions\n', strcat(createFuncByCat.getRelPathToHtmlFiles, mainFuncByCatFilename));
  
  % Create main HTML page
  createFuncByCat.mkMainHtml(mainFuncByCatFilename, cls);
  
  for jj=1:numel(cls)
    
    cl = cls{jj};
    
    % get all public functions for each category
    categoryStruct = getPubFcn(meta.class.fromName(cl));
    catNames = fieldnames(categoryStruct);
    
    %%%%% Add to XML the item: Class
    classFilename = getClassFilename(cl);
    fprintf(xml_fid, '    <tocitem target="%s">%s\n', strcat(createFuncByCat.getRelPathToHtmlFiles, classFilename), lower(cl));
    
    % Create HTML page for the classes
    if jj==1
      prevFn = mainFuncByCatFilename;
    else
      prevFn = getClassFilename(cls{jj-1});
    end
    if jj==numel(cls)
      postFn = '../../ug/ltpda_training_intro.html';
    else
      postFn = getClassFilename(cls{jj+1});
    end
    createFuncByCat.mkClassHtml(classFilename, categoryStruct, prevFn, postFn);
    
    % Some output
    fprintf('      function pages: ');
    for cc=1:numel(catNames)
      
      catName = catNames{cc};
      dispCatName = catName;
      dispCatName(1) = upper(dispCatName(1));
      idx = strfind(dispCatName, '_');
      if ~isempty(idx)
        dispCatName(idx)   = ' ';
        dispCatName(idx+1) = upper(dispCatName(idx+1));
      end
      
      % Get all functions for this category
      metaFcns = categoryStruct.(catName);
      
      %%%%% Add to XML the item: Category
      target = sprintf('%s#%s', strcat(createFuncByCat.getRelPathToHtmlFiles, classFilename), catName);
      fprintf(xml_fid, '      <tocitem target="%s">%s\n', target, dispCatName);
      
      % Loop over all function of one category
      for mm=1:numel(metaFcns)
        metaFcn = metaFcns(mm);
        fcnInfo = docHelper.getFirstCommentLine(metaFcn);
        fcnInfo = docHelper.htmlRepSpecChar(fcnInfo);
        
        htmlFilename = getFuncFilename(cl, metaFcn.Name);
        linkName = strcat(createFuncByCat.getRelPathToHtmlFiles(), htmlFilename);
        
        %%%%% Add to XML the item: Function
        fprintf(xml_fid, '        <tocitem target="%s"><name>%s</name><purpose>%s</purpose></tocitem>\n', linkName, metaFcn.Name, fcnInfo);
        
        % Create HTML page for each method of a class
        if mm<numel(metaFcns)
          postHtmlFilename = getFuncFilename(cl, metaFcns(mm+1).Name);
        elseif cc<numel(catNames)
          postHtmlFilename = getFuncFilename(cl, categoryStruct.(catNames{cc+1})(1).Name);
        elseif jj<numel(cls)
          cs = getPubFcn(meta.class.fromName(cls{jj+1}));
          cn = fieldnames(cs);
          postHtmlFilename = getFuncFilename(cls{jj+1}, cs.(cn{1})(1).Name);
        else
          postHtmlFilename = '../../ug/ltpda_training_intro.html';
        end
        
        createFuncByCat.mkHelpFunc(htmlFilename, metaFcn, cl, prevHtmlFilename, postHtmlFilename);
        prevHtmlFilename = htmlFilename;
      end
      
      % Some output
      fprintf('+');
      
      % Close item: Category
      fprintf(xml_fid, '      </tocitem>\n');
    end
    % Some output
    fprintf('\n');
    
    % Close item: Class
    fprintf(xml_fid, '    </tocitem>\n');
    
  end
  
  fprintf(xml_fid, '  </tocitem>\n');
  fprintf(xml_fid, '</toc>\n');
  
  fclose(xml_fid);
  
end

function f = getClassFilename(cl)
  f = sprintf('%s_main_funcByCat.html', cl);
end

function f = getFuncFilename(cl, fcn)
  f = sprintf('%s_%s.html', cl, fcn);
end

function categoryStruct = getPubFcn(metaObj)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                 Go throught the methods of the meta class                 %
  %                       and collect all public methods                      %
  %                                                                           %
  %          Create a struct which fields represent the categories            %
  %                  and devide the methods into this fields                  %
  %                                                                           %
  %   The struct have the following fields:                                   %
  %      Operator:                                                            %
  %      Trigonometry:                                                        %
  %      Constructor:                                                         %
  %      ...
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  categoryStruct = struct();
  
  meths       = docHelper.getMetaMethList(metaObj);
  methsDefCls = [meths.DefiningClass];
  
  idxAccess = strcmp({meths.Access}, 'public');
  idxDefCl  = strcmp({methsDefCls.Name}, 'handle');
  idxHidden = [meths.Hidden];
  
  docMeths = meths([idxAccess & ~idxDefCl & ~idxHidden]);
  
  for ii = length(docMeths):-1:1
    
    mth = docMeths(ii);
    %%% Devide the methods into 'normal' and 'static' methods
    if ~mth.Static
      
      cat = getCategory(metaObj.Name, mth.Name);
      if ~isempty(cat)
        categoryStruct = addCategory(categoryStruct, cat, mth);
      else
        if ~utils.helper.ismember(mth.Name, {'copy', 'Contents'})
          warning('!!! Didn''t find a category for the method %s/%s', metaObj.Name, mth.Name);
        end
      end
      
    else
      categoryStruct = addCategory(categoryStruct, 'static', mth);
    end
    
  end
  
  % Sort categories
  categoryStruct = orderfields(categoryStruct);
  
  % Sort the function names in each category
  cats = fieldnames(categoryStruct);
  for ii=1:numel(cats)
    metaFcns = categoryStruct.(cats{ii});
    [~, idx] = sort({metaFcns.Name});
    metaFcns = metaFcns(idx);
    categoryStruct.(cats{ii}) = metaFcns;
  end
end

function cat = getCategory(clName, mthName)
  cat = '';
  try
    %%% Get minfo-object
    info = feval(sprintf('%s.getInfo',clName), mthName);
    cat = lower(strrep(info.mcategory, ' ', '_'));
  catch
  end
end

function s = addCategory(s, cat, fcn)
  %%% Add the new category to the struct
  if ~ismember(cat, fieldnames(s))
    s.(cat) = fcn;
  else
    s.(cat)(end+1) = fcn;
  end
end




