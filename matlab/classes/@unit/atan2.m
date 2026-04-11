% ATAN2 implements atan2 operator for two unit objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Implements atan2 operator for two unit objects.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v = atan2(v1, v2)
  
  if ~isempty(v1.strs) && ~isempty(v2.strs) && ~isequal(v1, v2)
    error('### cannot compute atan2 for different units');
  end
  
  v = unit('rad');
  
end
