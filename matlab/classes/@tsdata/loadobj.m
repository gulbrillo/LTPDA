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
      objs(kk).class = 'tsdata';
      objs(kk).tbxver = '1.0';
    end
    objs = tsdata(objs);
  end
  
  % ATTENTION: We keep the meaning of t0 for backwards compatibility.
  %            This means
  %              - before saving, t0 = t0 + toffset
  %              - after loading, t0 = t0 - toffset
  for jj=1:numel(objs)
      objs(jj).setT0(objs(jj).t0 - objs(jj).toffset/1e3);
  end
  
end
