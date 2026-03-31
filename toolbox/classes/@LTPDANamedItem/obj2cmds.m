% This method is only necessary for the LTPDA method type() which
% displays the history commands of a LTPDA object.
%
% A LTPDATelemetry object can only exist in the history-plist of a
% LTPDA object.
function [cmd, pre_cmd] = obj2cmds(objsIn)
  nObjs = numel(objsIn);
  cmd = 'teleVar';
  pre_cmd = cell(1, nObjs);
  for ii = 1:nObjs
    pre_cmd{ii} = sprintf('teleVar(%d) = %s;', ii, string(objsIn(ii)));
  end
  pre_cmd = fliplr(pre_cmd);
end
% END