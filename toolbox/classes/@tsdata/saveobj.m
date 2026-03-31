% SAVEOBJ is called by MATLABs save function for user objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SAVEOBJ is called by MATLABs save function for user objects.
%              When an object is saved to a MAT-file, the save function
%              calls this saveobj method before it saves the object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function objs = saveobj(objs)
  
  % ATTENTION: We keep the meaning of t0 for backwards compatibility.
  %            This means
  %              - before saving, t0 = t0 + toffset
  %              - after  saving, t0 = t0 - toffset
  for jj=1:numel(objs)
    objs(jj) = objs(jj).setT0(objs(jj).t0 + objs(jj).toffset/1e3);
  end
  
end
