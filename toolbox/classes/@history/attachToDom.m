
function collectedHist = attachToDom(histObjs, dom, parent, collectedHist)
  
  persistent collectedHistUUIDs
  
  if isempty(collectedHistUUIDs)
    collectedHistUUIDs = {};
  end
  
  % Attach the history always to the historyRoot node
  historyRoot = dom.getElementsByTagName('historyRoot');
  historyRoot = historyRoot.item(0);
  
  % Do not call the super class
  % attachToDom@ltpda_nuo(obj, dom, node);
  
  addgraph(histObjs);
  
  function histId = addgraph(histObjs)
    
    histId = '';
    for oo = 1:numel(histObjs)
      histObj = histObjs(oo);
      
      if ~any(strcmp(collectedHistUUIDs, histObj.UUID))
        
        % Create object node
        histNode = dom.createElement(class(histObj));
        histNode.setAttribute('shape', sprintf('%dx%d', size(histObj)));
        
        % Add methodInfo
        if isa(histObj.methodInfo, 'minfo')
          
          if numel(histObj.methodInfo) == 1 && isempty(histObj.methodInfo.children)
            % Special case if the minfo-object doesn't have children.
            % Store in this case the minfo-object as an attribute.
            histNode.setAttribute('methodInfo', histObj.methodInfo.getEncodedString());
          else
            % Create an own minfo node if the minfo-object have children or
            % there are more than one minfo-objects
            collectedHist = histObj.methodInfo.attachToDom(dom, histNode, collectedHist);
          end
        end
        
        % Add plistUsed
        if isa(histObj.plistUsed, 'plist')
          pUsedNode = dom.createElement('plistUsed');
          collectedHist = histObj.plistUsed.attachToDom(dom, pUsedNode, collectedHist);
          histNode.appendChild(pUsedNode);
        end
        
        % Add methodInvars
        histNode.setAttribute('methodInvars', utils.xml.cellstr2str(histObj.methodInvars));
        
        % Add proctime
        histNode.setAttribute('proctime', num2str(histObj.proctime));
        
        % Add UUID
        histNode.setAttribute('UUID', histObj.UUID);
        
        % Add objectClass
        histNode.setAttribute('objectClass', utils.xml.prepareString(histObj.objectClass));

        % Add context
        histNode.setAttribute('context', utils.xml.cellstr2str(histObj.context));
                
        % Add creator
        % Special behavior for the creator of a PLIST because
        % provenance/attachToDom adds a extra node and this is not what we
        % want. Store the creator information direct to the plist node as an
        % attribute.
        if isa(histObj.creator, 'provenance')
          SEPARATOR = ' ?? ';
          creatorInfo = histObj.creator(1).getEncodedString();
          for cc = 2:numel(histObj.creator)
            creatorInfo = [creatorInfo, SEPARATOR, histObj.creator(cc).getEncodedString()];
          end
        else
          creatorInfo = '';
        end
        histNode.setAttribute('creator', creatorInfo);
                
        % Add inhists
        if ~isempty(histObj.inhists)
          inhistsNode = dom.createElement('inhists');
          attrHistId = addgraph(histObj.inhists);
          inhistsNode.setAttribute('UUID', strtrim(attrHistId));
          histNode.appendChild(inhistsNode);
        end
        
        collectedHistUUIDs = [collectedHistUUIDs {histObj.UUID}];
        collectedHist = [collectedHist histNode];
      end
      
      % Add the object UUID to the output.
      histId = [histId, ' ', histObj.UUID];
      
    end
    
  end
  
  for hh = 1:numel(collectedHist)
    historyRoot.appendChild(collectedHist(hh));
  end
  
end

% END