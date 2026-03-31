% XMLREAD Reads a XML object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   XMLREAD Reads a XML object.
%
% CALL:          obj = xmlread(node);
%                obj = xmlread(node ,'class');
%                obj = xmlread(node ,'ao');
%                obj = xmlread(node ,'time');
%
% XML HIERARCHY: ----------------------   ltpda_object   ----------------------
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
% SEE ALSO:      utils.xml.xmlwrite
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function values = xmlread(rootNode, obj_name)
  
%   if nargin == 1
%     node_name = mchar(rootNode.getNodeName);
%     
%     switch node_name
%       case 'ltpda_object'
%         
%         % Get the xml version from the document node
%         % node.getOwnerDocument.item(0).hasAttribute('ltpda_version')
%         if rootNode.hasAttribute('ltpda_version')
%           xml_ver = strtok(mchar(rootNode.getAttribute('ltpda_version')));
%         else
%           xml_ver = '1.0';
%         end
%         
%         tbx_ver = strtok(getappdata(0, 'ltpda_version'));
%         
%         % set the application data 'xml_ver' if the xml version is lower than the
%         % toolbox version.
%         % This application data is nedded in the function xml_read_object to
%         % update the object string.
%         if utils.helper.ver2num(xml_ver) < utils.helper.ver2num(tbx_ver)
%           update = xml_ver;
%         else
%           update = '';
%         end
%         
%         values = xml_read_ltpda_object(rootNode, update);
%       case 'object'
%         values = xml_read_object(rootNode, false);
%       case 'property'
%         values = xml_read_property_cell(rootNode, false);
%       case 'cell'
%         values = xml_read_property_cell(rootNode, false);
%       case 'real_data'
%         values = xml_read_real_imag_data(rootNode);
%       case 'imag_data'
%         values = xml_read_real_imag_data(rootNode);
%       case 'matrix'
%         %%%%% row vector
%         values = sscanf(mchar(child_node.getTextContent), '%g ', [1,inf]);
%       case 'vector'
%         %%%%% column vector
%         values = sscanf(mchar(child_node.getTextContent), '%g ');
%       otherwise
%         %%%%% Search for the next valid node name.
%         for ii = 1:rootNode.getLength
%           item = rootNode.item(ii-1);
%           if item.hasChildNodes
%             values = utils.xml.xmlread(item);
%           end
%         end
%     end
  if nargin >= 1
    
    values      = [];
    valuesShape = [];
    h           = history.initObjectWithSize(1,0);
    
    queryNode = rootNode.getElementsByTagName('ltpda_object');
    
    for ii= 1:queryNode.getLength
      
      LTPDANode = queryNode.item(ii-1);
      if LTPDANode.getNodeType == LTPDANode.ELEMENT_NODE
        
        if LTPDANode.hasAttribute('ltpda_version')
          ltpda_version = strtok(utils.xml.mchar(LTPDANode.getAttribute('ltpda_version')));
        else
          ltpda_version = '1.0';
        end
        
        if  (utils.helper.ver2num(ltpda_version) > utils.helper.ver2num('2.3')) || ...
            (strcmp(strtok(ltpda_version), '2.3'))
          %%%%%%%%%%%%%%%%%%   reading of a new XML file   %%%%%%%%%%%%%%%%%%
          
          for jj = 1:LTPDANode.getLength
            
            objNode = LTPDANode.item(jj-1);
            if objNode.getNodeType == objNode.ELEMENT_NODE
              
              className = utils.xml.mchar(objNode.getNodeName());
              
              if strcmp(className, 'historyRoot')
                
                h = history(objNode, history.initObjectWithSize(1,0));
                
              else
                valuesShape = utils.xml.getShape(objNode);
                val = feval(className, objNode, h);
                if ~exist('obj_name', 'var') || strcmp(class(val), obj_name)
                  values = [values val];
                else
                  error('### Skip the read object because it is from the class [%s] and not from the class [%s].', class(val), obj_name);
                end
              end
              
            end
          end
          values = reshape(values, valuesShape);
          
        else
          %%%%%%%%%%%%%%%%%%   reading of a old XML file   %%%%%%%%%%%%%%%%%%
          
          for jj = 1:LTPDANode.getLength
            objNode = LTPDANode.item(jj-1);
            if objNode.hasChildNodes
              % Get node name
              node_name = utils.xml.mchar(objNode.getNodeName);
              switch node_name
                case 'object'
                  val =  xml_read_object(objNode, ltpda_version);
                  if isempty(valuesShape), valuesShape = getShape(objNode); end
                  if ~exist('obj_name', 'var') || strcmp(class(val), obj_name)
                    values = [values val];
                  else
                    error('### Skip the read object because it is from the class [%s] and not from the class [%s].', class(val), obj_name);
                  end
                otherwise
              end
            end
          end % over all childs
          
          if ~isempty(valuesShape)
            values = reshape(values, valuesShape);
          end
        end
        
      end % LTPDANode.ELEMENT_NODE
      
    end % ii= 1:queryNode.getLength
    
  else
    error('### Invalid command of this function');
  end
  
  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: XML_READ_LTPDA_OBJECT Reads a ltoda_object element with the form:
%
%              <ltpda_object>
%
%                 --> <object> ...
%                 --> <cell>   ...
%
%              </ltpda_object>
%
% SYMBOLS:     --> Marks a choice between alternatives.
%              ... Indicate that an element may be repeated.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function values = xml_read_ltpda_object(node, update)
  
  values = [];
  for ii = 1:node.getLength
    child_node = node.item(ii-1);
    if child_node.hasChildNodes
      % Get Node name
      node_name = mchar(child_node.getNodeName);
      switch node_name
        case 'object'
          values = [values xml_read_object(child_node, update)];
        case 'cell'
          values{end+1} = xml_read_property_cell(child_node, update);
        otherwise
          error('### The ''ltpda_object'' element can not contain a [%s] element.', node_name);
      end
    end
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: XML_READ_OBJECT Reads a object element with the form:
%
%              <object> ('type' - attribute)
%
%                 <property> ...
%
%              </object>
%
% SYMBOLS:     ... Indicate that an element may be repeated.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = xml_read_object(node, update)
  
  obj_type = mchar(node.getAttribute('type'));
  obj = [];
  
  % Set some properties which are stored in the attributes of the 'object' node
  obj = getSpecialObjectAttributes(obj, node, update);
  
  for ii = 1:node.getLength
    child_node = node.item(ii-1);
    %%% Read only the property if the node is a ELEMENT_NODE.
    if child_node.getNodeType == child_node.ELEMENT_NODE
      % Get node name
      node_name = mchar(child_node.getNodeName);
      % get property name from the attribute 'prop_name'
      prop_name = mchar(child_node.getAttribute('prop_name'));
      switch node_name
        case 'property'
          prop_value = xml_read_property_cell(child_node, update);
          
          try
            obj.(prop_name) = prop_value;
          catch
            warning('\n\n### Skip the unknown property [%s] in the object [%s]\n', prop_name, class(obj));
            disp([char(10) 'Code me up to convert me into the new structure !!!' char(10) ]);
          end
          
        otherwise
          error('### The ''object'' element can not contain a [%s] element.', node_name);
      end
    end
  end
  
  if isempty(update)
    % Make sure that the version we want to update to is far in the future.
    % In other words, we don't do an update if it's not necessary.
    update = '1000000000000000';
  else
    old_c = {'timeformat', 'pole', 'zero'};
    new_c = {'',           'pz',    'pz'};
    
    idx = strmatch(obj_type, char(old_c), 'exact');
    if ~isempty(idx)
      obj_type = new_c{idx};
    end
    
    %     if ~isempty(obj_type)
    %       % Update the structure to the current ltpda_version
    %       update_fcn = [obj_type '.update_struct'];
    %       obj = feval(update_fcn, obj, update);
    %     end
  end
  
  if ~isempty(obj_type) && ~strcmp(obj_type, 'struct')
    obj.class  = obj_type;
    obj.tbxver = update;
    obj = feval(obj_type, obj);
  elseif isempty(obj) && strcmp(obj_type, 'struct')
    obj = struct();
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: XML_READ_PROPERTY_CELL Reads a property element or a cell element
%              with the form:
%
%              <property> ('type', 'prop_name' -attributes)
% OR:          <cell>     ('type'              -attribute)
%
%                 --> atomic element
%                       - empty cell
%                       - empty double
%                       - empty char
%                       - char
%                       - double
%                       - logical
%                       - java (necessary for timezone)
%                 --> <cell>      ...
%                 --> <object>    ...
%                 --> <real_data> ...
%                     <imag_data> ...
%
%              </property>
% OR:          </cell>
%
% SYMBOLS:     --> Marks a choice between alternatives.
%              ... Indicate that an element may be repeated.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function prop_value = xml_read_property_cell(node, update)
  
  prop_value = [];
  real_value = [];
  imag_value = [];
  shape      = [];
  
  %%% Is the length of the node is equal 1 or zero
  %%% then is the property a atomic element
  if node.getLength == 0 || node.getLength == 1
    prop_value = xml_read_atomic_element(node);
    return
  end
  
  for ii = 1:node.getLength
    child_node = node.item(ii-1);
    if child_node.getNodeType == child_node.ELEMENT_NODE
      %%% Get the node name
      node_name = mchar(child_node.getNodeName);
      switch node_name
        case 'cell'
          if isempty(shape), shape = getShape(node); end
          prop_value{end+1} = xml_read_property_cell(child_node, update);
        case 'object'
          if isempty(shape), shape = getShape(child_node); end
          prop_value = [prop_value xml_read_object(child_node, update)];
        case 'real_data'
          real_value = xml_read_real_imag_data(child_node);
        case 'imag_data'
          imag_value = xml_read_real_imag_data(child_node);
        otherwise
          error('### The ''property'' or ''cell'' element can not contain a [%s] element.', node_name);
      end
      
      %%% Is real_value and imag_value filled then return the complex value
      if ~isempty(real_value) && ~isempty(imag_value)
        prop_value = complex(real_value, imag_value);
        %%% Is real_value filled then return the read value
      elseif ~isempty(real_value)
        prop_value = real_value;
      end
    end
  end
  
  %%% Reshape the prop_value if necessary
  if ~isempty(shape)
    prop_value = reshape(prop_value, shape);
  end
  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: XML_READ_REAL_IMAG_DATA Reads a real_data element or a
%              imag_data element with the form:
%
%              <real_data> ('type' -attribute) <imag_data> ('type' -attribute)
%                          ('shape'-attribute)             ('shape'-attribute)
%
%                 --> <matrix> ...                --> <matrix> ...
%                 --> <vector> ...                --> <vector> ...
%
%              </real_data>                    </imag_data>
%
%              <matrix> ('type' -attribute)    <vector> ('type' -attribute)
%
%                 row vector (double)             column vector (double)
%
%              </matrix>                       </vector>
%
% SYMBOLS:     --> Marks a choice between alternatives.
%              ... Indicate that an element may be repeated.
%
% REMARK:      The matrix elements will be read as a row vector.
%              The vector elements will be read as a column vector.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function value = xml_read_real_imag_data(node)
  
  value            = [];
  header_displayed = true;
  
  %%% Get the shape of the matrix/vector
  shape = getShape(node);
  
  %   value = zeros(shape);
  %   idx   = 1;
  
  node_name = '';
  for ii = 1:node.getLength
    child_node = node.item(ii-1);
    if child_node.hasChildNodes
      %%% Get node name
      node_name = mchar(child_node.getNodeName);
      %%% Get type
      node_type = mchar(child_node.getAttribute('type'));
      switch node_name
        case 'matrix'
          %%% row vector
          if strcmp(node_type, 'sym')
            matrix_row = sym(mchar(child_node.getTextContent));
          else
            matrix_row = sscanf(mchar(child_node.getTextContent), '%g ', [1,inf]);
          end
          value = [value; matrix_row];
          %           value(idx,:) = matrix_row;
          %           idx = idx + 1;
        case 'vector'
          %%% column vector
          if strcmp(node_type, 'sym')
            vector_column = sym(mchar(child_node.getTextContent));
          else
            vector_column = sscanf(mchar(child_node.getTextContent), '%g ');
          end
          value = [value; vector_column];
          %           value(idx:idx + length(vector_column) - 1) = vector_column;
          %           idx = idx + length(vector_column);
          header_displayed = TerminalOutput(node, header_displayed, node_name, length(value));
        otherwise
          error('### The ''real_data'' or ''imag_data'' element can not contain a [%s] element.', node_name);
      end
    end
  end
  
  if strcmp(node_name, 'matrix')
    header_displayed = true;
    TerminalOutput(node, header_displayed, node_name, size(value,1));
  end
  value = reshape(value, shape);
  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: xml_read_atomic_element Reads a atomic element.
%              This function identify the following types:
%                 --> atomic element
%                       - empty cell
%                       - empty double
%                       - empty char
%                       - char
%                       - double
%                       - logical
%                       - java (necessary for timezone)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function values = xml_read_atomic_element(node)
  
  values = '';
  
  type = mchar(node.getAttribute('type'));
  switch type
    case {'', 'char'}
      shape = getShape(node);
      if (any(shape==1))
        values = mchar(node.getTextContent);
      else
        values = reshape(mchar(node.getTextContent), shape);
      end
      values = strrep(values, '<NEW_LINE>', '\n');
      values = strrep(values, 'CVS_TAG', '$');
      %%% Special case if 'values' is empty because
      %%% there are more than an one empty char fields.
      %%% For example: '' AND char('', '') AND char('', '', '') AND ...
      if isempty(values)
        if any(shape)
          char_str = 'char(';
          for ii = 1:max(shape)
            char_str = [char_str, ''''', '];
          end
          char_str = char_str(1:end-2);
          cmd = strcat('values = ', char_str, ');');
          eval(cmd);
        else
          values = '';
        end
      end
      
    case {'double', 'uint64', 'uint32', 'int32', 'int64'}
      number = mchar(node.getTextContent);
      
      %%% Special case if 'values' is empty because
      %%% there are more than an one empty double fields.
      %%% For example: [] AND zeros(1,0) AND zeros(0,1) AND zeros(2,0) AND ...
      if isempty(number)
        shape = getShape(node);
        values = zeros(shape);
      else
        values = str2double(number);
      end
      
      % cast to other number type
      if strcmp(type, 'uint64')
        values = uint64(values);
      elseif strcmp(type, 'uint32')
        values = uint32(values);
      elseif strcmp(type, 'int64')
        values = int64(values);
      elseif strcmp(type, 'int32')
        values = int32(values);
      end
      
    case 'sym'
      number = mchar(node.getTextContent);
      
      %%% Special case if 'values' is empty because
      %%% there are more than an one empty double fields.
      %%% For example: [] AND zeros(1,0) AND zeros(0,1) AND zeros(2,0) AND ...
      if isempty(number)
        shape = getShape(node);
        values = sym(shape);
      else
        values = sym(number);
      end
      
    case 'cell'
      cell_str = mchar(node.getTextContent);
      
      %%% Special case if 'values' is empty because
      %%% there are more than an one empty cell fields.
      %%% For example: {} AND cell(1,0) AND cell(0,1) AND cell(2,0) AND ...
      if isempty(cell_str)
        shape = getShape(node);
        values = cell(shape);
      else
        error('### Should not happen because a not empty ''cell'' node have several child nodes.');
      end
      
    case 'logical'
      cmd = ['logical(' mchar(node.getTextContent) ');'];
      values = eval(cmd);
      
    case 'sun.util.calendar.ZoneInfo'
      values = java.util.TimeZone.getTimeZone(mchar(node.getTextContent));
      
    otherwise
      
      if any(strcmp(utils.helper.ltpda_non_abstract_classes, type))
        %%% Special case for reading an object with the size Nx0 or 0xN
        shape = getShape(node);
        cmd = sprintf('%s.initObjectWithSize', type);
        values = feval(cmd, shape(1), shape(2));
      else
        error('### Unknown type attribute [%s].', type');
      end
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    shape = getShape(node)
%
% INPUTS:      node - A DOM node with an attribute 'shape'
%
% DESCRIPTION: getShape Helper function to get the shape from the
%              attribute 'shape' as a set of double.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function shape = getShape(node)
  shape = [NaN NaN];
  if node.hasAttribute('shape')
    shape_str = mchar(node.getAttribute('shape'));
    x_idx     = strfind(shape_str, 'x');
    shape     = [str2double(shape_str(1:x_idx-1)) str2double(shape_str(x_idx+1:end))];
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    obj = getSpecialObjectAttributes(obj, node)
%
% INPUTS:      obj  - a object structure or empty array
%              node - A DOM node with the node name 'object'
%
% DESCRIPTION:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = getSpecialObjectAttributes(obj, node, update)
  
  if strcmp(mchar(node.getNodeName), 'object')
    
    if strcmp(mchar(node.getAttribute('type')), 'time')
      
      % Get attributes for a time object
      % Check if the attribute exist (necessary for backwards compability)
      if (node.hasAttribute('utc'))
        obj.utc_epoch_milli = str2double(mchar(node.getAttribute('utc')));
        obj.timezone        = java.util.TimeZone.getTimeZone(mchar(node.getAttribute('timezone')));
        obj.timeformat      = mchar(node.getAttribute('timeformat'));
      end
      
    elseif strcmp(mchar(node.getAttribute('type')), 'provenance')
      
      % Get attributes for a provenance object
      % Check if the attribute exist (necessary for backwards compability)
      if (node.hasAttribute('info'))
        objStr = mchar(node.getAttribute('info'));
        obj = provenance.setFromEncodedInfo(obj, objStr);
      end
      
    elseif strcmp(mchar(node.getAttribute('type')), 'minfo')
      
      % Get attributes for a minfo object
      % Check if the attribute exist (necessary for backwards compability)
      if (node.hasAttribute('info'))
        objStr = mchar(node.getAttribute('info'));
        obj = minfo.setFromEncodedInfo(obj, objStr);
      end
      
    elseif strcmp(mchar(node.getAttribute('type')), 'param')
      
      % Get attributes for a param object
      % Check if the attribute exist (necessary for backwards compability)
      if (node.hasAttribute('key'))
        obj.key = mchar(node.getAttribute('key'));
        
        for ii = 1:node.getLength
          childNode = node.item(ii-1);
          %%% Read only the property if the node is a ELEMENT_NODE.
          if childNode.getNodeType == childNode.ELEMENT_NODE
            obj.val = xml_read_property_cell(childNode, update);
          end
        end
      end
      
    else
      % Get general attributes.
      if node.hasAttribute('name')
        obj.name = mchar(node.getAttribute('name'));
      end
      if node.hasAttribute('description')
        obj.description = mchar(node.getAttribute('description'));
      end
      if node.hasAttribute('UUID')
        obj.UUID = mchar(node.getAttribute('UUID'));
      end
      if node.hasAttribute('created')
        obj.created = str2double(mchar(node.getAttribute('created')));
      end
      if node.hasAttribute('proctime')
        obj.proctime = str2double(mchar(node.getAttribute('proctime')));
      end
    end
    
    
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    header_displayed = TerminalOutput(node, header_displayed, node_name, number)
%
% DESCRIPTION: Displays the terminal output.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function header_displayed = TerminalOutput(node, header_displayed, node_name, number)
  
  import utils.const.*
  
  THRESHOLD_DISP_MATRIX = 10;
  THRESHOLD_DISP_VECTOR = 1000;
  
  showing = false;
  
  if strcmp(node_name, 'matrix')
    if number >= THRESHOLD_DISP_MATRIX
      showing = true;
      add_text = 'matrix lines';
    end
  else
    if number >= THRESHOLD_DISP_VECTOR
      showing = true;
      add_text = 'data samples';
    end
  end
  
  if showing == true
    
    parent = node.getParentNode; % The parent node have the 'property name' information
    
    if header_displayed == true
      if parent.hasAttribute('prop_name')
        disp_prop_name = mchar(parent.getAttribute('prop_name'));
      else
        disp_prop_name = 'Unknown Property Name';
      end
      utils.helper.msg(msg.PROC2, 'Reading property: %s', disp_prop_name);
      
      if strcmp(mchar(node.getNodeName), 'real_data')
        utils.helper.msg(msg.PROC2, 'Reading real data');
      else
        utils.helper.msg(msg.PROC2, 'Reading imag data');
      end
      header_displayed = false;
    end
    
    utils.helper.msg(msg.PROC2, 'Read %d %s', number, add_text);
  end
end

function c = mchar(s)
  c = cell(s);
  c = c{1};
end



