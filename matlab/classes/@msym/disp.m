% DISP display an msym object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP display an msym object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function disp(obj, varargin)
  for ii=1:numel(obj)
    fprintf('  <a href="matlab:helpPopup msym">msym</a> with properties:\n\n');
    fprintf('    s: %s\n\n', obj(ii).s);
  end
end
