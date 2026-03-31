% GETLEGENDS gets an array of legends from the given figure handle.
% 
% CALL:
%        legendArray = getLegends(figureHandle)
% 

function legendArray = getLegends(fh)  
  legendArray = [];
  children = get(fh, 'Children');
  for kk=1:numel(children)
    child = children(kk);
    if isa(child, 'Legend') || isa(child, 'matlab.graphics.illustration.Legend')
      legendArray = [legendArray child]; 
    else
      tag  = get(child, 'tag');
      if strcmp(tag, 'legend')
        legendArray = [legendArray child];
      end
    end
  end  
end
% END