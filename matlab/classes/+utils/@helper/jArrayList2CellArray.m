% JARRAYLIST2CELLARRAY Converts a java ArrayList into a MATLAB cell array.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: JARRAYLIST2CELLARRAY Converts a java ArrayList into a MATLAB
%              cell array.
%
% CALL:        cellArray = jArrayList2CellArray(jArrayList)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = jArrayList2CellArray(jArrayList)
  
  if isjava(jArrayList) && isa(jArrayList, 'java.util.ArrayList')
    
    c = {};
    for ii=0:jArrayList.size()-1
      c = [c {jArrayList.get(ii)}];
    end
  else
    error('### The input is not a java ArrayList but from class %s', class(jArrayList));
  end
  
end
