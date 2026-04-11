function create_property_desc(fid, meta_obj, indentation_in)
  
  %   fid_read = fopen('property_descriptions.txt', 'r');
  %   f_line   = fgetl(fid_read);
  %
  %   prop_desc = struct();
  %
  %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %   %%%             Create from the desc_file a struct which contains            %%%
  %   %%%                       all information of the file.                       %%%
  %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %   %%% Create a struct with
  %   %%%
  %
  %   while ischar(f_line)
  %
  %     f_line = strtrim(f_line);   % Remove leading and ending whitespace
  %     if isempty(f_line)
  %       % skip this line
  %     elseif f_line(1) == '%'
  %       % skip comment line
  %     else
  %
  %       [prop_name, desc] = strtok(f_line, '-');
  %
  %       prop_name = strtrim(prop_name);
  %       desc      = strtrim(desc(2:end));
  %
  %       [class_name, prop_name] = strtok(prop_name, '.');
  %
  %       prop_name = prop_name(2:end);
  %
  %       prop_desc.(class_name).(prop_name) = desc;
  %     end
  %     f_line = fgetl(fid_read);
  %   end
  %
  %   fclose(fid_read);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%            Append to the fid the Information of the properties           %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  indentation(1:indentation_in) = ' ';
  
  %%% Headline
  fprintf(fid, '%s<h2 class="title"><a name="top_properties"/>Properties</h2>\n', indentation);
  
  fprintf(fid, '%s<p>\n', indentation);
  fprintf(fid, '%s  The LTPDA toolbox restrict access of the properties.<br></br>\n', indentation);
  fprintf(fid, '%s  The get access is ''public'' and thus it is possible to get the values with the dot-command (similar to structures).<br></br>\n', indentation);
  fprintf(fid, '%s  <pre class="programlisting">For example:<br></br>val = obj.prop(2).prop;</pre>\n', indentation);
  fprintf(fid, '%s  The set access is ''protected'' and thus it is only possible to assign a value to a property with a set-method.\n', indentation);
  fprintf(fid, '%s  <pre class="programlisting">\n', indentation);
  fprintf(fid, 'For example:\n');
  fprintf(fid, 'obj2 = obj1.setName(<span class="string">''my name''</span>) <span class="comment">%% This command creates a copy of obj1 (obj1 ~= obj2)</span>\n');
  fprintf(fid, 'obj.setName(<span class="string">''my name''</span>);        <span class="comment">%% This command applies to obj</span>');
  fprintf(fid, '%s  </pre>\n', indentation);
  fprintf(fid, '%s</p>\n', indentation);

  %%% Get the properties we want to show
  prop = docHelper.getMetaPropList(meta_obj);
  idxPub    = strcmp({prop.GetAccess}, 'public');
  idxHidden = [prop.Hidden];
  idxDep    = [prop.Dependent];
  idxTrans  = [prop.Transient];
  
  showProp = prop(idxPub & ~idxHidden & ~idxDep & ~idxTrans);
  nProp    = numel(showProp);
  
  %%% Define the table
  table = cell(nProp+1,3);
  table{1,1} = 'Properties'; table{1,2} = 'Description'; table{1,3} = 'Defining Class';
  for ii=1:nProp
    % First Column the property name
    table{ii+1,1} = sprintf('<a href="matlab:doc(''%s.%s'')">%s</a>', meta_obj.Name, showProp(ii).Name, showProp(ii).Name);

    % Third column the defining class
    table{ii+1,3} = showProp(ii).DefiningClass.Name;
    
    % Third column the property description
    try
      % Special case for ao.hist because the AO class have a method with
      % this name :(
      if strcmp(meta_obj.Name, 'ao') && strcmp(showProp(ii).Name, 'hist')
        desc = 'History of the object (history object)';
      elseif strcmp(meta_obj.Name, 'filterbank') && strcmp(showProp(ii).Name, 'type')
        desc = 'Type of the bank';
      elseif strcmp(meta_obj.Name, 'pest') && strcmp(showProp(ii).Name, 'y')
        % special case because the pest class have a method AND property
        % named as 'y'.
        desc = 'Best fit parameters';
      else
        desc = help(sprintf('%s.%s', meta_obj.Name, showProp(ii).Name));
        desc = regexp(desc, '(?<= - ).*', 'match');
        desc = strtrim(desc{1});
      end
    catch
      desc = '-- No description found --';
    end
    if ~isempty(desc), desc(1) = upper(desc(1)); end
    table{ii+1,2} = desc;
  end
    
  docHelper.htmlAddStripedTable(fid, indentation_in, table, 80, [14 72 14])
  
  %%% Table predefinitions %%%
%   fprintf(fid, '%s<!-- ===== Properties ===== -->\n', indentation);
%   fprintf(fid, '%s<p>\n', indentation);
%   fprintf(fid, '%s  <table cellspacing="0" class="body" cellpadding="2" border="0" width="80%%">\n', indentation);
%   fprintf(fid, '%s    <colgroup>\n', indentation);
%   fprintf(fid, '%s      <col width="15%%"/>\n', indentation);
%   fprintf(fid, '%s      <col width="73%%"/>\n', indentation);
%   fprintf(fid, '%s      <col width="12%%"/>\n', indentation);
%   fprintf(fid, '%s    </colgroup>\n', indentation);
%   fprintf(fid, '%s    <thead>\n', indentation);
%   fprintf(fid, '%s      <tr valign="top">\n', indentation);
%   fprintf(fid, '%s        <th class="categorylist">Properties</th>\n', indentation);
%   fprintf(fid, '%s        <th class="categorylist">Description</th>\n', indentation);
%   fprintf(fid, '%s        <th class="categorylist">Defined in class</th>\n', indentation);
%   fprintf(fid, '%s      </tr>\n', indentation);
%   fprintf(fid, '%s    </thead>\n', indentation);
%   fprintf(fid, '%s    <tbody>\n', indentation);
%   
%   for ii = 1:length(meta_obj.Properties)
%     
%     prop = meta_obj.Properties{ii};
%     
%     if ~prop.Hidden && ~prop.Dependent
%       
%       try
%         
%         % Special case for ao.hist because the AO class have a method with
%         % this name :(
%         if strcmp(meta_obj.Name, 'ao') && strcmp(prop.Name, 'hist')
%           description = 'History of the object (history object)';
%         elseif strcmp(meta_obj.Name, 'filterbank') && strcmp(prop.Name, 'type')
%           description = 'Type of the bank';
%         else
%           description = help(sprintf('%s.%s', meta_obj.Name, prop.Name));
%           description = regexp(description, '(?<= - ).*', 'match');
%           description = strtrim(description{1});
%         end
%         
%       catch
%         description = '-- No description found --';
%       end
%       
%       if mod(ii,2) == 0
%         bgcolor = '';
%       else
%         bgcolor = ' bgcolor="#f3f4f5"';
%       end
%       
%       fprintf(fid, '%s      <!-- Property: ''%s'' -->\n', indentation, prop.Name);
%       fprintf(fid, '%s      <tr valign="top">\n', indentation);
%       fprintf(fid, '%s        <td%s>\n', indentation, bgcolor);
%       fprintf(fid, '%s          <p><a href="matlab:doc(''%s.%s'')">%s</a></p>\n', indentation, meta_obj.Name, prop.Name, prop.Name);
%       fprintf(fid, '%s        </td>\n', indentation);
%       fprintf(fid, '%s        <td%s>\n', indentation, bgcolor);
%       fprintf(fid, '%s          <p>%s</p>\n', indentation, description);
%       fprintf(fid, '%s        </td>\n', indentation);
%       fprintf(fid, '%s        <td%s>\n', indentation, bgcolor);
%       fprintf(fid, '%s          <p>%s</p>\n', indentation, prop.DefiningClass.Name);
%       fprintf(fid, '%s        </td>\n', indentation);
%       fprintf(fid, '%s      </tr>\n', indentation);
%       
%     end
%   end
%   
%   %%% Table end %%%
%   fprintf(fid, '%s    </tbody>\n', indentation);
%   fprintf(fid, '%s  </table>\n', indentation);
%   fprintf(fid, '%s</p>\n\n', indentation);
  
  %%% Top of page link
  createClassDesc.create_top_of_page(fid, indentation_in);
  
end






