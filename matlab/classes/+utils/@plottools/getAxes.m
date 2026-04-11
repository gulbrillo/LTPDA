% GETAXES gets an array of axes from the given figure handle.
% 
% CALL:
%        axesArray = getAxes(figureHandle)
% 

function axesArray = getAxes(fh)  
  axesArray = [];
  children = get(fh, 'Children');
  for kk=1:numel(children)
    child = children(kk);
    type  = get(child, 'Type');
    if strcmp(type, 'axes') && isempty(get(child, 'Tag'))
      axesArray = [axesArray child];
    end
  end  
end
% END