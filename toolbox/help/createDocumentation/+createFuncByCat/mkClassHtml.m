

function mkClassHtml(classFilename, categoryStruct, prevHtmlFilename, postHtmlFilename)
  
  relPathToMainHelp = strcat(createFuncByCat.getRelPathToHelp(), 'ug/');
  clName = strtok(classFilename, '_');
  
  fprintf('  - Create class page [%s] of the section: Function by Category - ', clName);
  
  fid = fopen(fullfile(createFuncByCat.getAbsPathToHtmlFiles, classFilename), 'w');
  
  % Add <HTML> tag
  docHelper.htmlAddHtmlTag(fid);
  
  % Add <HEAD>
  title = sprintf('%s Class page of the section: Functions by Category', upper(clName));
  docHelper.htmlAddHeadTag(fid, title, relPathToMainHelp);
  
  % Add <BODY> tag
  docHelper.htmlAddBodyTag(fid);
  
  % Add top navigation table
  preHtml   = prevHtmlFilename;
  preTitle  = getDescFromFilename(prevHtmlFilename);
  postHtml  = postHtmlFilename;
  postTitle = getDescFromFilename(postHtmlFilename);
  docHelper.htmlAddTopNavTable(fid, preHtml, preTitle, postHtml, postTitle, relPathToMainHelp)
  
  % Add <H2> tag
  docHelper.htmlAddH2Tag(fid, sprintf('Categories of the Class %s', upper(clName)), 'categorytitle');
  
  cats  = fieldnames(categoryStruct);
  nCats = numel(cats);
  catTable = cell(nCats, 3);
  for ii = 1:nCats
    cat = cats{ii};
    catTable{ii, 1} = catOutput(cat);
    catTable{ii, 2} = sprintf('%s#%s', classFilename, cat);
    catTable{ii, 3} = docHelper.getDescriptionForCategory(cat);
  end
  docHelper.htmlAddLinkTable(fid, catTable, 'subcategorylist', 4, 90);
  
  for cc=1:nCats
    
    % Add <H3> tag
    cat = cats{cc};
    h3title = sprintf('<a name="%s">%s</a>', cat, catOutput(cat));
    docHelper.htmlAddH3Tag(fid, h3title, 'subcategorytitle');
    fcns = categoryStruct.(cat);
    mTable = cell(numel(fcns),3);
    
    for ff=1:numel(fcns)
      fcn = fcns(ff);
      mTable{ff, 1} = fcn.Name;
      mTable{ff, 2} = sprintf('%s_%s.html', clName, fcn.Name);
      mTable{ff, 3} = docHelper.getFirstCommentLine(fcn);
    end
    
    % Add table with the methods of one category
    docHelper.htmlAddLinkTableWoFrame(fid, mTable)
    
    % Add Top Of Page link
    docHelper.htmlAddTopOfPageLink(fid, 4, relPathToMainHelp);
    
  end
  
  % Add bottom navigation table
  docHelper.htmlAddBotNavTable(fid, preHtml, preTitle, postHtml, postTitle, relPathToMainHelp);
  
  % Add </BODY> and </HTML> tags
  fprintf(fid, '   </body>\n');
  fprintf(fid, '</html>\n');
  
  fclose(fid);
  
  fprintf('finished.\n');
  
end

function cat = catOutput(cat)
  cat = regexprep(regexprep(strrep(cat, '_', ' '), '^(.)', '${upper($1)}'), '(?<=\s)(.)', '${upper($1)}');
end

function txt = getDescFromFilename(fn)
  if strfind(fn, 'mainFuncByCat.html')
    txt = 'Function Reference';
  elseif strfind(fn, 'ltpda_training_intro')
    txt = 'LTPDA Training Session 1';
  else
    txt = sprintf('%s Class Categories', upper(strtok(fn, '_')));
  end
end

