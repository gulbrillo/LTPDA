% COPYHASHFILE copies an hash file for an LTPDA Extension module into the LTPDA hash folder
%
% CALL: [success, message] = copyHashFile(hashFileName, moduleDir, hashDir)
%
% M Hueller 23-05-13
%

function [success, message] = copyHashFile(hashFileName, moduleDir, hashDir)
  
  % Copy the hash file into place
  hashFileSource = fullfile(moduleDir, hashFileName);
  hashFileDest = fullfile(hashDir, hashFileName);
  [success, message, messageid] = copyfile(hashFileSource, hashFileDest, 'f');
  if ~success && ltpda_mode == utils.const.msg.DEBUG
    warning('Failed to copy Version Control Identifier %s for module at %s into the LTPDA hash folder %s', ...
      hashFileName, moduleDir, hashDir);
  else
    % Make the new hash file read only
    if ispc
      [success, message, messageid] = fileattrib(hashFileDest, '-w');
    else
      [success, message, messageid] = fileattrib(hashFileDest, '-w', 'a');
    end
    if ~success && ltpda_mode == utils.const.msg.DEBUG
      warning('!!! Failed to set attributes for %s', hashFileDest);
    end
  end
end