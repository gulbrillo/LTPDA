
function attachNumberToDom(number, dom, parent)
  
  % Store the original shape
  parent.setAttribute('shape', sprintf('%dx%d', size(number)));
  parent.setAttribute('type', class(number));
  
  if isempty(number)
    
    %%%%% Nothing to do
    % For example: <parent shape="8x0"/>
    
  elseif numel(number) == 1
    
    %%%%% Single number
    % For example: <parent shape="1x1">1</parent>
    %              <parent shape="1x1">1+3i</parent>
    if isreal(number)
      numberStr = sprintf('%.17g', number);
    else
      numberStr = ['[', num2str(number, 20), ']'];
    end
    content = dom.createTextNode(numberStr);
    parent.appendChild(content);
    
  elseif isvector(number) && ...
      isreal(number)      && ...
      numel(number) <= utils.xml.MAX_DOUBLE_IN_ROW
    
    %%%%% Real vector which is not longer than 50000 values
    % For example: <parent shape="1x10">1 2 3 4 5 6 7 8 9 0</parent>
    content = dom.createTextNode(strtrim(utils.xml.num2str(number)));
    parent.appendChild(content);
    
  elseif isvector(number) && ...
      ~isreal(number)     && ...
      numel(number) <= utils.xml.MAX_IMAG_IN_ROW
    
    %%%%% imaginary vector which is not longer than 1000 values
    % For example: <parent shape="1x10">[1+1i 2+1i 3 4-4i ...]</parent>
    content = dom.createTextNode(strtrim(utils.xml.mat2str(number)));
    parent.appendChild(content);
    
  elseif (size(number,1) > 1) && ...
      (size(number,2) > 1)    && ...
      isreal(number) && numel(number) <= utils.xml.MAX_NUM_IN_MATRIX
    
    %%%%% Real matrix which have not more than 2500 values
    % For example: <parent shape="2x3">[1 2 3; 4 5 6]</parent>
    content = dom.createTextNode(strtrim(utils.xml.mat2str(number)));
    parent.appendChild(content);
    
  elseif isvector(number)
    
    %%%%% General vector
    % For example: <parent>
    %                <realData type="vector">
    %                  <vector> 1  2  3  4  5  6  7  8  9 10 ...</vector>
    %                  <vector>11 12 13 14 15 16 17 18 19 20 ...</vector>
    %                </realData>
    %                <imagData type="vector">
    %                  <vector> 1  2  3  4  5  6  7  8  9 10 ...</vector>
    %                  <vector>11 12 13 14 15 16 17 18 19 20 ...</vector>
    %                </imagData>
    %              </parent>
    utils.xml.attachVectorToDom(number, dom, parent);
    
  elseif (size(number,1) > 1) && (size(number,2) > 1)
    
    %%%%% General matrix
    % For example: <parent>
    %                <realData type="matrix">
    %                  <matrix> 1  2  3  4  5  6  7  8  9 10 ...</matrix>
    %                  <matrix>11 12 13 14 15 16 17 18 19 20 ...</matrix>
    %                     ...
    %                </realData>
    %                <imagData type="matrix">
    %                  <matrix> 1  2  3  4  5  6  7  8  9 10 ...</matrix>
    %                  <matrix>11 12 13 14 15 16 17 18 19 20 ...</matrix>
    %                     ...
    %                </imagData>
    %              </parent>
    utils.xml.attachMatrixToDom(number, dom, parent);
    
  else
    
    error('### Should not happen. Size of the input object %dx%d', size(number))
    
  end
  
end

