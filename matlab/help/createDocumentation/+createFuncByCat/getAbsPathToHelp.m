% GETABSPATHTOHELP returns the absolute path from this package to the main help folder.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETABSPATHTOHELP returns the absolute path from this package
%              to the main help folder.
%
% CALL:        path = createFuncByCat.getAbsPathToHelp()
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function txt = getAbsPathToHelp()
  
  txt = mfilename('fullpath');
  txt = strrep(txt, fullfile('createDocumentation', '+createFuncByCat', mfilename()), '');
  
end