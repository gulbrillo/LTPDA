% RDIVIDE implements rdivide operator for unit objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RDIVIDE implements rdivide operator for unit objects.
%
% CALL:        a = a1./scalar
%              a = a1./a2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v = rdivide(v1,v2)

  if isempty(v1.strs)
    v = copy(v2,1);
    v.exps = -v.exps;
    return;
  end
  
  if isempty(v2.strs)
    v = copy(v1,1);
    return;
  end
  
  if isnumeric(v1)
    v1 = unit();
  end
  if isnumeric(v2)
    v2 = unit();
  end

  v = unit;
  v.strs = [v1.strs v2.strs];
  v.exps = [v1.exps -1*v2.exps];
  v.vals = [v1.vals v2.vals];

end
