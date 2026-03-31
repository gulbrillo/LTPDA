% XMLWRITE Add an object to a xml DOM project.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   XMLWRITE Add an object to a xml DOM project.
%
% EXAMPLE:       xml = com.mathworks.xml.XMLUtils.createDocument('ltpda_object');
%                parent = xml.getDocumentElement;
%
%                xmlwrite(a, xml, parent, '');
%
%                xmlwrite('foo.xml', xml);
%
% FORMAT:        This function writes the object into the following xml format:
%
%                ----------------------   ltpda_object   ----------------------
%
%                <ltpda_object>
%
%                   --> <object> ...
%                   --> <cell>   ...
%
%                </ltpda_object>
%
%                -------------------------   object   -------------------------
%
%                <object> ('type' - attribute)
%
%                   <property> ...
%
%                </object>
%
%                ------------------------   property   ------------------------
%                --------------------------   cell   --------------------------
%
%                <property> ('type', 'prop_name' -attributes)
%            OR  <cell>     ('type'              -attribute)
%
%                   --> atomic element
%                         - empty cell
%                         - empty double
%                         - empty char
%                         - char
%                         - double
%                         - logical
%                         - java (necessary for timezone)
%                   --> <cell>      ...
%                   --> <object>    ...
%                   --> <real_data> ...
%                       <imag_data> ...
%
%                </property>
%            OR  </cell>
%
%                -------   real_data   --------|--------   imag_data   --------
%                                              |
%                <real_data>('type'-attribute) | <imag_data> ('type' -attribute)
%                           ('shape'-attribute)|             ('shape'-attribute)
%                                              |
%                   --> <matrix> ...           |    --> <matrix> ...
%                   --> <vector> ...           |    --> <vector> ...
%                                              |
%                </real_data>                  | </imag_data>
%                                              |
%                ---------   matrix   --------------------   vector   ---------
%                                              |
%                <matrix> ('type' -attribute)  | <vector> ('type' -attribute)
%                                              |
%                   row vector (double)        |    column vector (double)
%                                              |
%                </matrix>                     | </vector>
%
% SYMBOLS:       --> Marks a choice between alternatives.
%                ... Indicate that an element may be repeated.
%
% SEE ALSO:      utils.xml.xmlread
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = xmlwrite(objs, xml, parent, property_name)
  
  %%%%%%   Workaround for saving as the new XML format   %%%%%%
  ltpda_version = getappdata(0, 'ltpda_version');
  if  (utils.helper.ver2num(ltpda_version) > utils.helper.ver2num('2.3')) || ...
      (strcmp(strtok(ltpda_version), '2.3'))
    %%%%%%%%%%%%%%%%%%   reading of a new XML file   %%%%%%%%%%%%%%%%%%
    
    % Create history root node
    % The attachToDom methods will attach their histories to this node.
    historyRootNode = xml.createElement('historyRoot');
    parent.appendChild(historyRootNode);
    
    % clear the internal cache of history UUIDs from history/attachToDom
    clear history/attachToDom
    
    % Write objects
    collectedHist = objs.attachToDom(xml, parent, []);
    return
  end
  
  %%%%%%   If the property_name is filled then create a new property node   %%%%%
  if ~isempty(property_name)
    shape = sprintf('%dx%d', size(objs,1), size(objs,2));
    prop_node = xml.createElement('property');
    prop_node.setAttribute('prop_name', property_name);
    prop_node.setAttribute('shape', shape);
    prop_node.setAttribute('type', class(objs));
    parent.appendChild(prop_node);
    parent = prop_node;
  end
  
  %%%%%%%%%%%%%%%%   The object is a class object or a struct   %%%%%%%%%%%%%%%%%
  if (isobject(objs) || isstruct(objs)) && ~isa(objs, 'sym')
    
    if isa(objs, 'ltpda_obj')
      %%%%%   Skip empty fields for unser objects   %%%%%
      for ii = 1:numel(objs)
        obj = objs(ii);
        shape = sprintf('%dx%d', size(objs,1), size(objs,2));
        obj_node = xml.createElement('object');
        obj_node.setAttribute('type', class(obj));
        obj_node.setAttribute('shape', shape);
        parent.appendChild(obj_node);
        if isa(obj, 'minfo')
          
          % we don't write all fields
          info = obj.getEncodedString;
          obj_node.setAttribute('info', info);
          
        elseif isa(obj, 'provenance')
          
          % write info
          info = obj.getEncodedString;
          obj_node.setAttribute('info', info);
          
        elseif isa(obj, 'param')
          
          obj_node.setAttribute('key', obj.key');
          val = obj.getDefaultVal;
          utils.xml.xmlwrite(val, xml, obj_node, 'value');
          
        elseif isa(obj, 'time')
          
          % write utc_epoch_milli
          obj_node.setAttribute('utc', num2str(obj.utc_epoch_milli));
          % write timezone
          obj_node.setAttribute('timezone', char(obj.timezone.getID));
          % write timeformat
          obj_node.setAttribute('timeformat', obj.timeformat);
          
        else
          fields = getFieldnames(obj);
          for jj = 1:length(fields)
            if ~isempty(obj.(fields{jj})) || any(size(obj.(fields{jj})))
              % handle some fields as attributes
              if strcmp(fields{jj}, 'name')
                obj_node.setAttribute('name', obj.name);
              elseif strcmp(fields{jj}, 'description')
                obj_node.setAttribute('description', obj.description);
              elseif strcmp(fields{jj}, 'UUID')
                obj_node.setAttribute('UUID', obj.UUID);
              elseif strcmp(fields{jj}, 'created')
                obj_node.setAttribute('created', num2str(obj.created));
              elseif strcmp(fields{jj}, 'proctime')
                obj_node.setAttribute('proctime', num2str(obj.proctime));
              else
                utils.xml.xmlwrite(obj.(fields{jj}), xml, obj_node, fields{jj});
              end
            end
          end
        end
      end
    else
      %%%%%   Don't skip empty fields for structures and other   %%%%%
      for ii = 1:numel(objs)
        obj = objs(ii);
        shape = sprintf('%dx%d', size(objs,1), size(objs,2));
        obj_node = xml.createElement('object');
        obj_node.setAttribute('type', class(obj));
        obj_node.setAttribute('shape', shape);
        parent.appendChild(obj_node);
        fields = fieldnames(obj);
        for jj = 1:length(fields)
          utils.xml.xmlwrite(obj.(fields{jj}), xml, obj_node, fields{jj});
        end
      end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%   The object is a java object   %%%%%%%%%%%%%%%%%%%%%%%
  elseif isjava(objs)
    if strcmp(class(objs), 'sun.util.calendar.ZoneInfo')
      content = xml.createTextNode(char(objs.getID));
      parent.appendChild(content);
    else
      error('### Unknown Java');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%   The object is a cell object   %%%%%%%%%%%%%%%%%%%%%%%
  elseif iscell(objs)
    
    for ii = 1:numel(objs)
      obj = objs{ii};
      shape = sprintf('%dx%d', size(obj,1), size(obj,2));
      cell_node = xml.createElement('cell');
      cell_node.setAttribute('type', class(obj));
      cell_node.setAttribute('prop_name', property_name);
      cell_node.setAttribute('shape', shape);
      parent.appendChild(cell_node);
      utils.xml.xmlwrite(obj, xml, cell_node, '');
    end
    
    %%%%%%%%%%%%%%%%%%%%   The object is a character string   %%%%%%%%%%%%%%%%%%%%%
  elseif ischar(objs)
    
    % We mask the line break '\n' with a new identifier because we got
    % problems with saving into the database.
    objs_txt = objs;
    objs_txt = strrep(objs_txt, '\n', '<NEW_LINE>');
    
    % Replace the first and last DOLLAR $ of an version string with CVS_TAG
    if ~isempty(objs_txt) && (objs_txt(1) == '$') && (objs_txt(end) == '$') && (strcmp(property_name, 'version') || strcmp(property_name, 'mversion'))
      objs_txt = strrep(objs_txt, '$', 'CVS_TAG');
      %       objs_txt = ['CVS_TAG', objs_txt(2:end-1), 'CVS_TAG'];
    end
    
    % Set the shape of the node again because it is possible that we
    % replaced '\n' with '<NEW_LINE>'.
    parent.setAttribute('shape', sprintf('%dx%d', size(objs_txt,1), size(objs_txt,2)));
    
    objs_txt = reshape(objs_txt, 1, []);
    content = xml.createTextNode(objs_txt);
    parent.appendChild(content);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%   The object is a logical   %%%%%%%%%%%%%%%%%%%%%%%%%
  elseif islogical(objs)
    
    content = xml.createTextNode(mat2str(objs));
    parent.appendChild(content);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%   The object is a number   %%%%%%%%%%%%%%%%%%%%%%%%%%
  elseif isnumeric(objs) || isa(objs, 'sym')
    
    %%%%%   objs is a singel value   %%%%%
    if (size(objs,1) == 1) && (size(objs,2) == 1) || size(objs,1) == 0 || size(objs,2) == 0
      if strcmp(class(objs), 'sym')
        number_str = char(objs, 20);
      else
        if isreal(objs)
          number_str = sprintf('%.17g', objs);
        else
          number_str = num2str(objs, 20);
        end
      end
      content = xml.createTextNode(number_str);
      parent.appendChild(content);
      
      %%%%%   objs is a matrix   %%%%%
    elseif (size(objs,1) > 1) && (size(objs,2) > 1)
      
      xml_addmatrix(objs, xml, parent);
      
      %%%%%   objs is a vector   %%%%%
    elseif (size(objs,1) > 1) || (size(objs,2) > 1)
      
      xml_addvector(objs, xml, parent);
      
    end
    
  else
    error('### unknown type [%s]', class(objs));
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: XML_ADDVECTOR Add a vector element to the xml node. The element
%              have the form:
%
% REAL DATA:   <real_data type="vector">
%                 <vector type="double"> 1  2  3  4  5  6  7  8  9 10</vector>
%                 <vector type="double">11 12 13 14 15 16 17 18 19 20</vector>
%              </real_data>
%
% COMPLEX DATA:<real_data type="vector">
%                 <vector type="double"> 1  2  3  4  5  6  7  8  9 10</vector>
%                 <vector type="double">11 12 13 14 15 16 17 18 19 20</vector>
%              </real_data>
%
%              <imag_data type="vector">
%                 <vector type="double"> 1  2  3  4  5  6  7  8  9 10</vector>
%                 <vector type="double">11 12 13 14 15 16 17 18 19 20</vector>
%              </imag_data>
%
%              The vector objs will be split into several parts dependent from
%              the maximum size in one vector element.
%              Each part creates its own vectror element.
%
% HISTORY:     31-01-2008 Diepholz
%                 Creation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xml_addvector(objs, xml, parent)
  
  n_min            = 50000;
  header_displayed = true;
  
  shape = sprintf('%dx%d', size(objs,1), size(objs,2));
  
  %%%%%   Real data   %%%%%
  node_real = xml.createElement('real_data');
  node_real.setAttribute('type', 'vector');
  node_real.setAttribute('shape', shape);
  %%% Set the parent attribute 'type' to vector
  parent.setAttribute('type', 'vector');
  parent.appendChild(node_real);
  
  idx = 1;
  Ndata = length(objs);
  n = min(n_min, Ndata);
  while idx-1 <= Ndata
    header_displayed = TerminalOutput(parent, header_displayed, true, 'vector', idx+n-1);
    if isa(objs, 'sym')
      number_str = strtrim(char(objs(idx:min(Ndata,idx+n-1))));
    else
      number_str = strtrim(utils.helper.num2str(real(objs(idx:min(Ndata,idx+n-1)))));
    end
    if ~isempty(number_str)
      item = xml.createElement('vector');
      item.setAttribute('type', class(objs));
      content = xml.createTextNode(number_str);
      node_real.appendChild(item);
      item.appendChild(content);
    end
    idx = idx + n;
  end
  
  %%%%%   Imaginary data   %%%%%
  if ~isreal(objs) && ~isa(objs, 'sym')
    header_displayed = true;
    node_imag = xml.createElement('imag_data');
    node_imag.setAttribute('type', 'vector')
    node_imag.setAttribute('shape', shape);
    parent.appendChild(node_imag);
    
    idx   = 1;
    while idx-1 <= Ndata
      header_displayed = TerminalOutput(parent, header_displayed, false, 'vector', idx+n-1);
      number_str = strtrim(utils.helper.num2str(imag(objs(idx:min(Ndata,idx+n-1)))));
      if ~isempty(number_str)
        item = xml.createElement('vector');
        item.setAttribute('type', class(objs));
        content = xml.createTextNode(number_str);
        node_imag.appendChild(item);
        item.appendChild(content);
      end
      idx = idx + n;
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: XML_ADDMATRIX Add a matrix element to the xml node. The element
%              have the form:
%
% REAL DATA:   <real_data type="matrix">
%                 <matrix type="double">1 2 3</matrix>
%                 <matrix type="double">4 5 6</matrix>
%                 <matrix type="double">7 8 9</matrix>
%              </real_data>
%
% COMPLEX DATA:<real_data type="matrix">
%                 <matrix type="double">1 2 3</matrix>
%                 <matrix type="double">4 5 6</matrix>
%                 <matrix type="double">7 8 9</matrix>
%              </real_data>
%
%              <imag_data type="matrix">
%                 <matrix type="double">9 8 7</matrix>
%                 <matrix type="double">6 5 4</matrix>
%                 <matrix type="double">3 2 1</matrix>
%              </imag_data>
%
%              Each row in objs creates a matrix element.
%
% HISTORY:     31-01-2008 Diepholz
%                 Creation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xml_addmatrix(objs, xml, parent)
  
  shape            = sprintf('%dx%d', size(objs,1), size(objs,2));
  header_displayed = true;
  
  %%% Get the property name only for displaying the property name
  
  %%%%%   Real data   %%%%%
  node_real = xml.createElement('real_data');
  node_real.setAttribute('type', 'matrix');
  node_real.setAttribute('shape', shape);
  %%% Set the parent attribute 'type' to matrix
  parent.setAttribute('type', 'matrix');
  parent.appendChild(node_real);
  
  for ii = 1:size(objs,1)
    if strcmp(class(objs), 'sym')
      number_str = strtrim(char(objs(ii,:)));
    else
      number_str = strtrim(utils.helper.num2str(real(objs(ii,:))));
    end
    if ~isempty(number_str)
      item = xml.createElement('matrix');
      item.setAttribute('type', class(objs));
      content = xml.createTextNode(number_str);
      node_real.appendChild(item);
      item.appendChild(content);
    end
  end
  
  TerminalOutput(parent, header_displayed, true, 'matrix', ii);
  
  %%%%%   Imaginary data   %%%%%
  if ~isreal(objs) && ~isa(objs, 'sym')
    node_imag = xml.createElement('imag_data');
    node_imag.setAttribute('type', 'matrix');
    node_imag.setAttribute('shape', shape);
    parent.appendChild(node_imag);
    for ii = 1:size(objs,1)
      number_str = strtrim(utils.helper.num2str(imag(objs(ii,:))));
      if ~isempty(number_str)
        item = xml.createElement('matrix');
        item.setAttribute('type', class(objs));
        content = xml.createTextNode(number_str);
        node_imag.appendChild(item);
        item.appendChild(content);
      end
    end
    TerminalOutput(parent, header_displayed, false, 'matrix', ii);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Displays the terminal output.
%
% HISTORY:     31-01-2008 Diepholz
%                 Creation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function header_displayed = TerminalOutput(parent, header_displayed, isreal_num, obj_type, number)
  
  import utils.const.*
  
  THRESHOLD_DISP_MATRIX = 10;
  THRESHOLD_DISP_VECTOR = 1000;
  
  showing = false;
  
  if strcmp(obj_type, 'matrix')
    if number >= THRESHOLD_DISP_MATRIX
      showing = true;
    end
    add_text = 'matrix lines';
  else
    if number >= THRESHOLD_DISP_VECTOR
      showing = true;
    end
    add_text = 'data samples';
  end
  
  if showing
    
    if header_displayed
      if parent.hasAttribute('prop_name')
        disp_prop_name = char(parent.getAttribute('prop_name'));
      else
        disp_prop_name = 'Unknown Property Name';
      end
      utils.helper.msg(msg.PROC2, 'Writing property: %s', disp_prop_name);
      if isreal_num
        utils.helper.msg(msg.PROC2, 'Writing real data');
      else
        utils.helper.msg(msg.PROC2, 'Writing imag data');
      end
      
      header_displayed = false;
    end
    
    utils.helper.msg(msg.PROC3, 'Writing %d %s', number, add_text);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getFieldnames
%
% DESCRIPTION: Retruns the field names which should be storred in a XML file.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fields = getFieldnames(obj)
  meta = eval(['?' class(obj)]);
  metaProp = [meta.Properties{:}];
  props = {metaProp(:).Name};
  propGetAccess = strcmpi({metaProp(:).GetAccess}, 'public');
  propDependent = [metaProp(:).Dependent];
  fields = props(propGetAccess & ~propDependent);
end
