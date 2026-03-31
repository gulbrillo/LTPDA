
function fromDom(obj, node, inhists)
  
  %%%%%%%%%% Call super-class
  
  fromDom@ltpda_uo(obj, node, inhists);
  
  %%%%%%%%%% Get properties from the node attributes
  
  %%%%%%%%%% Get properties from the child nodes
  
  % Get hist
  histNode = utils.xml.getChildByName(node, 'hist');
  if ~isempty(histNode)
    inhistUUIDs = utils.xml.mchar(histNode.getAttribute('hist_UUID'));
    if ~isempty(inhistUUIDs)
      inhistUUIDs = regexp(inhistUUIDs, ' ', 'split');
      for uu = 1:numel(inhistUUIDs)
        obj.hist = [obj.hist utils.xml.getHistoryFromUUID(inhists, inhistUUIDs{uu})];
      end
    end
  end
  
  % Get procinfo
  childNode = utils.xml.getChildByName(node, 'procinfo');
  if ~isempty(childNode)
    obj.procinfo = utils.xml.getObject(childNode, inhists);
  end
  
  % Get timespan
  childNode = utils.xml.getChildByName(node, 'timespan');
  if ~isempty(childNode)
    obj.timespan = utils.xml.getObject(childNode, inhists);
  end
  
  % Get plotinfo
  childNode = utils.xml.getChildByName(node, 'plotinfo');
  if ~isempty(childNode)
    pi = utils.xml.getObject(childNode, inhists);
    if isa(pi, 'plist')
      pi = plotinfo(pi);
    end
    obj.plotinfo = pi;
  end
  
end
