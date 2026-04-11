
function obj = getFromType(node, inhists)
  
  type = utils.xml.mchar(node.getAttribute('type'));
  
  if  strcmp(type, 'double')   || strcmp(type, 'logical')
    
    obj = utils.xml.getNumber(node);
    
  elseif strcmp(type, 'char')
    
    obj = utils.xml.getString(node);
    
  elseif strcmp(type, 'cellstr')
    
    obj = eval(utils.xml.mchar(node.getTextContent()));
    
  elseif strcmp(type, 'cell')
    
    obj = utils.xml.getCell(node, inhists);
    
  elseif strcmp(type, 'history')
    
    inhistUUIDs = utils.xml.mchar(node.getAttribute('val'));
    if ~isempty(inhistUUIDs)
      inhistUUIDs = regexp(inhistUUIDs, ' ', 'split');
      obj = [];
      for uu = 1:numel(inhistUUIDs)
        obj = [obj utils.xml.getHistoryFromUUID(inhists, inhistUUIDs{uu})];
      end
    end
    
  elseif utils.helper.ismember(type, utils.helper.ltpda_classes)
    
    obj = utils.xml.getObject(node, inhists);
    
  elseif strcmp(type, 'struct')
    
    obj = utils.xml.getStruct(node, inhists);
    
  elseif strcmp(type, 'sym')
    
    obj = utils.xml.getSym(node);
    
  elseif strcmp(type, 'sun.util.calendar.ZoneInfo')
  
    obj = java.util.TimeZone.getTimeZone(utils.xml.getString(node));

  elseif strcmp(type, 'doubleVector') || strcmp(type, 'doubleMatrix') || ...
      strncmp(type, 'uint', 4) || strncmp(type, 'int', 3) || ...
      strcmp(type, 'single')   || strcmp(type, 'float')
    
    obj = utils.xml.getNumber(node);
    
  else
    
    % It might be possible that a NON LTPDA class is stored inside a LTPDA
    % class. 
    try
      obj = utils.xml.getObject(node, inhists);
    catch Me
      error('### Unknown type [%s] [%s]', type, Me.message);
    end
  end
  
end
