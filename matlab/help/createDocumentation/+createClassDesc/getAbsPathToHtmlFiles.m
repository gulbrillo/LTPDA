% GETABSPATHTOHTMLFILES returns the absolute path where we create the HTML pages.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETABSPATHTOHTMLFILES returns the absolute path where we
%              create the HTML pages.
%
% CALL:        path = createClassDesc.getAbsPathToHtmlFiles()
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function txt = getAbsPathToHtmlFiles()
  
  txt = createClassDesc.getAbsPathToHelp();
  txt = fullfile(txt, 'ug');
  
end