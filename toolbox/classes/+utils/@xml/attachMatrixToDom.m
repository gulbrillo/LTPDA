
function attachMatrixToDom(numbers, dom, parent)

  shape = sprintf('%dx%d', size(numbers));
  
  % REMARK: It is not possible to name the type 'matrix' because 'matrix'
  %         is also a class name.
  
  %%%%%   Real data   %%%%%
  realNode = dom.createElement('realData');
  realNode.setAttribute('type', 'doubleMatrix');
  realNode.setAttribute('shape', shape);

  %%% Set the parent attribute 'type' to doubleMatrix
  parent.setAttribute('type', 'doubleMatrix');
  parent.appendChild(realNode);
  
  for ii = 1:size(numbers,1)

    number_str = strtrim(utils.xml.num2str(real(numbers(ii,:))));
    if ~isempty(number_str)
      %%% Create new matrix node
      content = dom.createTextNode(number_str);
      matrixNode = dom.createElement('doubleMatrix');
      matrixNode.setAttribute('type', class(numbers));
      matrixNode.appendChild(content);
      realNode.appendChild(matrixNode);
    end
  end
  
  %%%%%   Imaginary data   %%%%%
  if ~isreal(numbers)
    imagNode = dom.createElement('imagData');
    imagNode.setAttribute('type', 'doubleMatrix');
    imagNode.setAttribute('shape', shape);
    parent.appendChild(imagNode);
    for ii = 1:size(numbers,1)
      number_str = strtrim(utils.helper.num2str(imag(numbers(ii,:))));
      if ~isempty(number_str)
        %%% Create new matrix node
        content = dom.createTextNode(number_str);
        matrixNode = dom.createElement('doubleMatrix');
        matrixNode.setAttribute('type', class(numbers));
        matrixNode.appendChild(content);
        imagNode.appendChild(matrixNode);
      end
    end
  end
  
end
