
function attachCellstrToDom(objs, dom, parent)
  
  if numel(objs) ~= 1 && ~iscellstr(objs)
    error('### Please use the function attachCellToDom because this function can handle only a single cell of strings');
  end
  
  % Store the original shape of the string
  parent.setAttribute('shape', sprintf('%dx%d', size(objs)));
  
  if isempty(objs)
    % Create cell string
    cellstr = sprintf('cell(%d,%d)', size(objs));
  else
    cellstr = sprintf('''%s'', ', objs{:});
    cellstr = strcat('{', cellstr(1:end-2), '}');
  end
  
  % Attach the string as a content to the parent node
  content = dom.createTextNode(cellstr);
  parent.appendChild(content);
end
