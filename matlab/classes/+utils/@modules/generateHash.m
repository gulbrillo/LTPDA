% GENERATEHASH generates a hash file for an LTPDA Extension module
% based on the VCS the module was handled by.
%
% CALL: [success, message] = generateHash(vers_syst, moduleDir, hashDir, hashFileName)
%
% M Hueller 23-05-13
%

function [success, message] = generateHash(vers_syst, moduleDir, hashDir, hashFileName)
  
  % Choose the command based on VCS
  switch upper(vers_syst)
    case 'GIT'
      cmd = sprintf('git log -n 1 --format="%%H" > %s', hashFileName);
    case 'SVN'
      cmd = sprintf('svnversion > %s', hashFileName);
    case 'HG'
      cmd = sprintf('hg id -i > %s', hashFileName);
    otherwise
  end
  
  % Handle the case where we produce a local .hash file
  local = strcmp(moduleDir, hashDir);
  
  % Create version hash file for this module
  currentDir = pwd();
  cd(moduleDir);
  
  [status, message] = system(cmd);
  
  if status ~= 0
    success = false;
    if ltpda_mode == utils.const.msg.DEBUG
      warning('Failed to create %s hash for module at %s', upper(vers_syst), moduleDir);
    end
  else
    if ~local
      [success, message] = utils.modules.copyHashFile(hashFileName, moduleDir, hashDir);
    else
      success = true;
      message = '';
    end
  end
  
  % remove the generated hash file
  if ~local
    delete(hashFileName);
  end
  
  cd(currentDir);
  
end
