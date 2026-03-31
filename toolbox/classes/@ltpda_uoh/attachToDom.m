
function collectedHist = attachToDom(obj, dom, parent, collectedHist)
  
  collectedHist = attachToDom@ltpda_uo(obj, dom, parent, collectedHist);
  
  % Add hist
  % Adding the history is a special case because here we store only the
  % UUID of the history object. The history object will be stored in a
  % special history-graph.
  if isa(obj.hist, 'history')
    histNode = dom.createElement('hist');
    histNode.setAttribute('hist_UUID', obj.hist.UUID);
    parent.appendChild(histNode);
    
    % Add history nodes
    collectedHist = obj.hist.attachToDom(dom, parent, collectedHist);
  end
  
  % Add procinfo
  if isa(obj.procinfo, 'plist')
    procinfoNode = dom.createElement('procinfo');
    collectedHist = obj.procinfo.attachToDom(dom, procinfoNode, collectedHist);
    parent.appendChild(procinfoNode);
  end
  
  % Add timespan
  if isa(obj.timespan, 'timespan')
    timespanNode = dom.createElement('timespan');
    collectedHist = obj.timespan.attachToDom(dom, timespanNode, collectedHist);
    parent.appendChild(timespanNode);
  end
  
  % Add plotinfo
  if isa(obj.plotinfo, 'plotinfo')
    plotinfoNode = dom.createElement('plotinfo');
    collectedHist = obj.plotinfo.attachToDom(dom, plotinfoNode, collectedHist);
    parent.appendChild(plotinfoNode);
  end
  
end
