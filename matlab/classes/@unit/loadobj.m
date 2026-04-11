% LOADOBJ is called by the load function for user objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LOADOBJ is called by the load function for user objects.
%              When an object is loaded from a MAT-file, the load function calls
%              the loadobj method if the structure of the object is changed.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function objs = loadobj(objs)
  
  if isstruct(objs)
    for kk = 1:numel(objs)
      objs(kk).class = 'unit';
      objs(kk).tbxver = '1.0';
    end
    objs = unit(objs);
  else
    % reparse the units to ensure we have valid fields.
    objs = unit(char(objs));
  end
  
end
