% GETABSPATHTOXMLFILE returns the absolute path where we create the XML file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETABSPATHTOXMLFILE returns the absolute path where we
%              create the XML file.
%
% CALL:        path = createFuncByCat.getAbsPathToXmlFile()
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function txt = getAbsPathToXmlFile()
  
  txt = createFuncByCat.getAbsPathToHelp();
  txt = fullfile(txt, 'funcbycat');
  
end