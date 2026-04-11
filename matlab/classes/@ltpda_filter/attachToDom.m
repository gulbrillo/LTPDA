
function collectedHist = attachToDom(obj, dom, parent, collectedHist)
  
  collectedHist = attachToDom@ltpda_tf(obj, dom, parent, collectedHist);
  
  % Add fs
  fsNode = dom.createElement('fs');
  utils.xml.attachNumberToDom(obj.fs, dom, fsNode);
  parent.appendChild(fsNode);
  
  % Add infile
  if ~isempty(obj.infile)
    infileNode = dom.createElement('infile');
    utils.xml.attachCharToDom(obj.infile, dom, infileNode);
    parent.appendChild(infileNode);
  end
  
  % Add a
  aNode = dom.createElement('a');
  utils.xml.attachNumberToDom(obj.a, dom, aNode);
  parent.appendChild(aNode);
  
  % Add histout
  histoutNode = dom.createElement('histout');
  utils.xml.attachNumberToDom(obj.histout, dom, histoutNode);
  parent.appendChild(histoutNode);
  
end
