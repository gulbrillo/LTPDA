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
      objs(kk).class = 'time';
      objs(kk).tbxver = '1.0';
    end
    objs = time(objs);
  end

end
