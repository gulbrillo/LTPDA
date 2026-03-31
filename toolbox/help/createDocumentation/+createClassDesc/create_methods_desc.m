function create_methods_desc(fid, meta_obj, html_filename, indentation_in)
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%               Go throught the methods of the meta class               %%%
  %%%                     and collect all public methods                    %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  public_fcn = struct;
  static_fcn = struct;
  
  for ii = length(meta_obj.Methods):-1:1
    
    method = meta_obj.Methods{ii};
    
    %%% Display only public and not handle methods
    if  strcmp(method.Access, 'public') && ...
        ~strcmp(method.DefiningClass.Name, 'handle') && ...
        ~method.Hidden
      
      %%% Devide the methods into 'normal' and 'static' methods
      if ~method.Static
        public_fcn.(method.Name) = method.DefiningClass.Name;
      else
        static_fcn.(method.Name) = method.DefiningClass.Name;
      end
      
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%        Create a struct which fields represent the categories          %%%
  %%%                and devide the methods into this fields                %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%% The struct have the following fields:
  %%%    Operator:
  %%%    Trigonometry:
  %%%    Constructor:
  
  method_names = fieldnames(public_fcn);
  
  category_struct = struct();
  
  for ii = 1:length(method_names)
    
    try
      
      %%% Get minfo-object
      info = feval(sprintf('%s.getInfo',meta_obj.Name), method_names{ii});
      
      fcn_name = sprintf('%s/%s',public_fcn.(method_names{ii}), method_names{ii});
      category = strrep(info.mcategory, ' ', '_');
      
      %%% Add the new category to the struct
      if ~ismember(category, fieldnames(category_struct))
        category_struct.(category) = {fcn_name};
      else
        category_struct.(category){end+1} = fcn_name;
      end
      
      %%% Order the fiels of the structure.
      category_struct = orderfields(category_struct);
    catch
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%   Remove from the default link_box in the class not used categories   %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  def_link_box   = default_link_box(html_filename);
  fcn_link_box   = {};
  fcn_categories = sort(fieldnames(category_struct));
  rr = 1;
  
  for ii = 1:numel(fcn_categories)
    idx = strcmpi(fcn_categories{ii}, strrep(def_link_box(:,1), ' ', '_'));
    if any(idx)
      fcn_link_box{rr,1} = def_link_box{idx,1};
      fcn_link_box{rr,2} = def_link_box{idx,2};
      fcn_link_box{rr,3} = def_link_box{idx,3};
    else
      fcn_link_box{rr,1} = fcn_categories{ii};
      fcn_link_box{rr,2} = sprintf('%s#%s', html_filename, lower(strrep(fcn_categories{ii}, ' ', '_')));
      fcn_link_box{rr,3} = sprintf('%s methods', fcn_categories{ii});
    end
    rr = rr + 1;
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%            Append to the fid the Information of the methods           %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  indentation(1:indentation_in) = ' ';
  
  %%% Headline
  fprintf(fid, '%s<h2 class="title"><a name="top_methods"/>Methods</h2>\n', indentation);
  
  %%% Link box
  docHelper.htmlAddLinkTable(fid, fcn_link_box, 'subcategorylist', indentation_in);
  
  %%% Top of page link
  createClassDesc.create_top_of_page(fid, indentation_in);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%                   Create a table for each category                    %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  categories = fieldnames(category_struct);
  
  for ii = 1:length(categories)
    category = categories{ii};
    category_struct.(category) = sort(category_struct.(category));
    
    %%% table predefinitions %%%
    fprintf(fid, '%s<!-- ===== Methods Category: %s ===== -->\n', indentation, category);
    fprintf(fid, '%s<h3 class="title"><a name="%s"/>%s</h3>\n', indentation, lower(category), strrep(category, '_', ' '));
    
    fcns  = category_struct.(category);
    nFcns = numel(fcns);
    table = cell(nFcns+1, 3);
    
    table{1,1} = 'Methods'; table{1,2} = 'Description'; table{1,3} = 'Defining Class';
    for mm = 1:nFcns
      % Define the first column
      fcn       = fcns{mm};
      fcnName   = regexp(fcn, '(?<=/).*', 'match', 'once');
      defClName = strtok(fcn, '/');
      clName    = meta_obj.Name;
      
      % First column: Method name
      if strcmp(clName, fcnName)
        % Special case for a constructor
        table{mm+1, 1} = sprintf('<a href="matlab:doc(''%s'')">%s</a>', clName, fcnName);
      else
        table{mm+1, 1} = sprintf('<a href="matlab:doc(''%s/%s'')">%s</a>', clName, fcnName, fcnName);
      end
      
      % Second column the description of the method
      table{mm+1, 2} = docHelper.getFirstCommentLine(clName, fcnName);
      
      % Third column the defining class
      table{mm+1, 3} = defClName;
    end
    
    docHelper.htmlAddStripedTable(fid, indentation_in, table, 80, [14 72 14]);
    
    %%% Back to top of the methods %%%
    back2m = 'Back to Top of Section';
    
    fprintf(fid, '%s  <!-- ===== Back to Top of Methods ===== -->\n', indentation);
    fprintf(fid, '%s  <a href="#top_methods">\n', indentation);
    fprintf(fid, '%s    <img src="doc_to_top_up.gif" border="0" align="bottom" alt="%s"/>\n', indentation, back2m);
    fprintf(fid, '%s    %s\n', indentation, back2m);
    fprintf(fid, '%s  </a>\n\n', indentation);
    fprintf(fid, '%s</p>\n\n', indentation);
  end
  
end


function fcn_link_box = default_link_box(html_filename)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%                  Define the link box for the methods                  %%%
  %%% link_box{:,1} --> Link name                                           %%%
  %%% link_box{:,2} --> URL                                                 %%%
  %%% link_box{:,3} --> Link description                                    %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  i = 1;
  fcn_link_box{i,1} = 'Arithmetic Operator';
  fcn_link_box{i,2} = [html_filename, '#arithmetic_operator'];
  fcn_link_box{i,3} = 'Arithmetic Operator';
  
  i = i+1;
  fcn_link_box{i,1} = 'Constructor';
  fcn_link_box{i,2} = [html_filename, '#constructor'];
  fcn_link_box{i,3} = 'Constructor of this class';
  
  i = i+1;
  fcn_link_box{i,1} = 'Converter';
  fcn_link_box{i,2} = [html_filename, '#converter'];
  fcn_link_box{i,3} = 'Convertor methods';
  
  i = i+1;
  fcn_link_box{i,1} = 'GUI function';
  fcn_link_box{i,2} = [html_filename, '#gui_function'];
  fcn_link_box{i,3} = 'GUI function methods';
  
  i = i+1;
  fcn_link_box{i,1} = 'Helper';
  fcn_link_box{i,2} = [html_filename, '#helper'];
  fcn_link_box{i,3} = 'Helper methods only for internal usage';
  
  i = i+1;
  fcn_link_box{i,1} = 'Internal';
  fcn_link_box{i,2} = [html_filename, '#internal'];
  fcn_link_box{i,3} = 'Internal methods only for internal usage';
  
  i = i+1;
  fcn_link_box{i,1} = 'Input';
  fcn_link_box{i,2} = [html_filename, '#input'];
  fcn_link_box{i,3} = 'Input methods';
  
  i = i+1;
  fcn_link_box{i,1} = 'MDC01';
  fcn_link_box{i,2} = [html_filename, '#mdc01'];
  fcn_link_box{i,3} = 'Mock data challenge 1';
  
  i = i+1;
  fcn_link_box{i,1} = 'Operator';
  fcn_link_box{i,2} = [html_filename, '#operator'];
  fcn_link_box{i,3} = 'Operator methods';
  
  i = i+1;
  fcn_link_box{i,1} = 'Output';
  fcn_link_box{i,2} = [html_filename, '#output'];
  fcn_link_box{i,3} = 'Output methods';
  
  i = i+1;
  fcn_link_box{i,1} = 'Relational Operator';
  fcn_link_box{i,2} = [html_filename, '#relational_operator'];
  fcn_link_box{i,3} = 'Relational operator methods';
  
  i = i+1;
  fcn_link_box{i,1} = 'Signal Processing';
  fcn_link_box{i,2} = [html_filename, '#signal_processing'];
  fcn_link_box{i,3} = 'Signal processing methods';
  
  i = i+1;
  fcn_link_box{i,1} = 'Statespace';
  fcn_link_box{i,2} = [html_filename, '#statespace'];
  fcn_link_box{i,3} = 'Statespace methods';
  
  i = i+1;
  fcn_link_box{i,1} = 'Trigonometry';
  fcn_link_box{i,2} = [html_filename, '#trigonometry'];
  fcn_link_box{i,3} = 'Trigometry methods';
  
  i = i+1;
  fcn_link_box{i,1} = 'User defined';
  fcn_link_box{i,2} = [html_filename, '#user_defined'];
  fcn_link_box{i,3} = 'User defined methods';
end



