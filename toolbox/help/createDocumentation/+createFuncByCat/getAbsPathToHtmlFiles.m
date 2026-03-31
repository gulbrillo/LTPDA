% GETABSPATHTOHTMLFILES returns the absolute path where we create the HTML pages.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETABSPATHTOHTMLFILES returns the absolute path where we
%              create the HTML pages.
%
% CALL:        path = createFuncByCat.getAbsPathToHtmlFiles()
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function txt = getAbsPathToHtmlFiles()
  
  txt = createFuncByCat.getAbsPathToHelp();
  txt = fullfile(txt, 'funcbycat', 'html');
  
end