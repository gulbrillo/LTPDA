% GETHELPPATH return the full path of the LTPDA toolbox help
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETHELPPATH return the full path of the LTPDA toolbox help.
%
% CALL:        path = utils.helper.getHelpPath()
%
% EXCEPTION:   Throws an error if this method doesn't find the LTPDA
%              toolbox.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function helpLocation = getHelpPath()
  
  root = getappdata(0, 'LTPDAROOT');
  if ~isempty(root)
    helpLocation = fullfile(root, 'ltpda', 'help');
    return;
  else
    startupPath = fileparts(which('ltpda_startup'));
    infoLocation = strrep(startupPath, strcat('m', filesep(), 'etc'), '');
    
    infoXML = xmlread(fullfile(infoLocation, 'info.xml'));
    tbNameNode = infoXML.getElementsByTagName('name');
    tbName = tbNameNode.item(0).getFirstChild.getData;
    if strcmp(tbName, 'LTPDA')
      helpLocationNodes = infoXML.getElementsByTagName('help_location');
      helpLocation = char(helpLocationNodes.item(0).getFirstChild.getTextContent);
    else % Otherwise error out
      error('Can not find info.xml file for My Toolbox');
    end
    
    helpLocation = fullfile(infoLocation, helpLocation);
  end
end