% GENERATEVCSHASH generates a hash file for an LTPDA Extension module
%
% CALL: result = generateVCSHash(moduleDir, hashDir, hashFileName)
%
% M Hueller 23-05-13
%

function [success, message] = generateVCSHash(moduleDir, hashDir, hashFileName)

  % try to create a GIT hash first
  [success, message] = utils.modules.generateHash('GIT', moduleDir, hashDir, hashFileName);
  if success
    return;
  end
  
  % if this did not work, try Mercurial
  [success, message] = utils.modules.generateHash('HG', moduleDir, hashDir, hashFileName);
  if success
    return;
  end
  
  % if this did not work, try Subversion
  [success, message] = utils.modules.generateHash('SVN', moduleDir, hashDir, hashFileName);
  if success
    return;
  end
    
end
