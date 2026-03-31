
function hists = fromDom(obj, node, inhists)
  
  %  <historyRoot>
  %     <history UUID="1111" ...>
  %         ...
  %     </history>
  %     <history UUID="2222" methodInfo="#setDescription#ltpda_uoh#Helper#(ID): setDescription.m,v 1.8 2009/09/10 10:05:00 ingo Exp $#[1 -1 1 -1]#true#(ID): minfo.m,v 1.31 2010/04/27 15:49:26 ingo Exp $" methodInvars="{'a'}" proctime="1272392086974" shape="1x1">
  %         ...
  %        <inhists UUID="1111"/>
  %     </history>
  %     <history UUID="3333" ...>
  %         ...
  %        <inhists UUID="2222"/>
  %     </history>
  %  </historyRoot>
  
  hists = [history.initObjectWithSize(1,0), inhists];
  
  % Get history
  histNodes = utils.xml.getChildrenByName(node, 'history');
  for ii=0:histNodes.getLength()-1
    
    %%%%%%%%%% Make sure that we always have a new history object
    h = history();
    
    %%%%%%%%%% Call super-class
    fromDom@ltpda_nuo(obj, histNodes.item(ii), inhists);
    
    h = getHistoryObj(h, histNodes.item(ii), hists);
    
    if ~isempty(h.inhists)
      inhistUUIDs = regexp(h.inhists, ' ', 'split');
      if ~isempty(inhistUUIDs)
        h.inhists = [];
        for uu = 1:numel(inhistUUIDs)
          h.inhists = [h.inhists utils.xml.getHistoryFromUUID(hists, inhistUUIDs{uu})];
        end
      end
    end
    
    hists = [hists h];
  end
  
end

function obj = getHistoryObj(obj, node, hists)
  
  %  <history UUID="..." methodInfo="..." methodInvars="cell(0,0)" proctime="1">
  %     <plistUsed UUID="8a9a33c2-94c7-435b-a42d-ae02f50a3b6f" created="1272388257003" creator="#indiep#127.0.1.1#hws169#GLNX86#7.9 (R2009b)#6.12 (R2009b)#5.3 (R2009b)#4.3 (R2009b)#3.6 (R2009b)#8.4 (R2009b)#2.2 (R2009b)#(ID): provenance.m,v 1.54 2010/04/27 15:49:26 ingo Exp $" shape="1x1">
  %        ...
  %     </plistUsed>
  %  </history>
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = history.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Get properties from the node attributes
    
    % Get methodInfo
    if node.hasAttribute('methodInfo')
      obj.methodInfo = minfo.setFromEncodedInfo(minfo(), utils.xml.mchar(node.getAttribute('methodInfo')));
    end
    
    % Get methodInvars
    obj.methodInvars = eval(utils.xml.mchar(node.getAttribute('methodInvars')));
    
    % Get proctime
    obj.proctime = str2double(utils.xml.mchar(node.getAttribute('proctime')));
    
    % Get UUID
    obj.UUID = utils.xml.mchar(node.getAttribute('UUID'));
    
    % Get objectClass
    obj.objectClass = utils.xml.recoverString(node.getAttribute('objectClass'));
    
    % Get context
    if node.hasAttribute('context')
      obj.context = eval(utils.xml.mchar(node.getAttribute('context')));
    end
    
    % Get creator
    if node.hasAttribute('creator')
      obj.creator = provenance.setFromEncodedInfo(provenance(), utils.xml.mchar(node.getAttribute('creator')));
    else
      % XML file saved with LTPDA 2.3.1
      % Get the creator from the plistUsed
      plistUsedNode = utils.xml.getChildByName(node, 'plistUsed');
      if ~isempty(plistUsedNode) && plistUsedNode.hasAttribute('creator')
        obj.creator = provenance.setFromEncodedInfo(provenance(), utils.xml.mchar(plistUsedNode.getAttribute('creator')));
      end
    end
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get plistUsed
    plistUsedNode = utils.xml.getChildByName(node, 'plistUsed');
    if ~isempty(plistUsedNode)
      obj.plistUsed = plist(plistUsedNode, hists);
    end
    
    % Get minfo
    minfoNode = utils.xml.getChildByName(node, 'minfo');
    if ~isempty(minfoNode)
      obj.methodInfo = minfo(minfoNode, hists);
    end
    
    % Get inhists
    inhistsNode = utils.xml.getChildByName(node, 'inhists');
    if ~isempty(inhistsNode)
      obj.inhists = utils.xml.mchar(inhistsNode.getAttribute('UUID'));
    end
    
  end
  
end
