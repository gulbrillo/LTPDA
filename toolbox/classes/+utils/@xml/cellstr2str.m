
function str = cellstr2str(c)
  
  if ~isempty(c)
    
    if ischar(c)
      str = ['''' c ''''];
    elseif iscell(c)
      str = '{';
      for cc = 1:size(c,1)
        
        str = [str, utils.xml.cellstr2str(c{cc, 1})];
        for rr = 2:size(c,2)
          str = [str, ', ' utils.xml.cellstr2str(c{cc, rr}) ];
        end
        
        str = [str '; '];
      end
      
      str = [str(1:end-2), '}'];
      
    else
      error('### This method can only create an executable string from cell(s) with strings.');
    end
    
  else
    % Check if empty cell or empty string
    if iscell(c)
      str = sprintf('cell(%d,%d)', size(c));
    elseif ischar(c)
      str = '''''';
    else
      error('### Expected only char or cell but get object of type [%s]', class(c));
    end
  end
  
end
