
function attachVectorToDom(numbers, dom, parent)
  
  shape = sprintf('%dx%d', size(numbers));
  
  %%%%%   Real data   %%%%%
  realNode = dom.createElement('realData');
  realNode.setAttribute('type', 'doubleVector');
  realNode.setAttribute('shape', shape);

  %%% Set the parent attribute 'type' to vector
  parent.setAttribute('type', 'doubleVector');
  parent.appendChild(realNode);
  
  idx = 1;
  Ndata = numel(numbers);
  n = min(utils.xml.MAX_DOUBLE_IN_ROW, Ndata);
  while idx-1 <= Ndata
    
    numberStr = strtrim(utils.helper.num2str(real(numbers(idx:min(Ndata,idx+n-1)))));
    if ~isempty(numberStr)
      %%% Create new vector node
      content = dom.createTextNode(numberStr);
      vectorNode = dom.createElement('doubleVector');
      vectorNode.setAttribute('type', class(numbers));
      vectorNode.appendChild(content);
      realNode.appendChild(vectorNode);
    end
    idx = idx + n;
  end
  
  %%%%%   Imaginary data   %%%%%
  if ~isreal(numbers)
    imagNode = dom.createElement('imagData');
    imagNode.setAttribute('type', 'doubleVector')
    parent.appendChild(imagNode);
    
    idx   = 1;
    while idx-1 <= Ndata
      numberStr = strtrim(utils.helper.num2str(imag(numbers(idx:min(Ndata,idx+n-1)))));
      if ~isempty(numberStr)
        content = dom.createTextNode(numberStr);
        vectorNode = dom.createElement('doubleVector');
        vectorNode.setAttribute('type', class(numbers));
        vectorNode.appendChild(content);
        imagNode.appendChild(vectorNode);
      end
      idx = idx + n;
    end
  end
  
end
