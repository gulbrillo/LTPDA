% GETABSPATHTOHELP returns the absolute path from this package to the main help folder.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETABSPATHTOHELP returns the absolute path from this package
%              to the main help folder.
%
% CALL:        path = createContentFile.getAbsPathToHelp()
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function txt = getAbsPathToHelp()
  
  txt = mfilename('fullpath');
  txt = strrep(txt, fullfile('createDocumentation', '+createContentFile', mfilename()), '');
  
end