% SAVEOBJ saves an object to a file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SAVEOBJ saves an object to a file.
%
% CALL:      saveobj(obj, pl)
%
% INPUTS:     obj  - an object (for example, an AO)
%             pl   - parameter list with a 'filename' parameter
%
% Supported file types are '.mat' and '.xml'.
%
% OUTPUTS:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = saveobj(a, pl)
  
  % get filename
  filename = find(pl, 'filename');
  
  % Inspect filename
  [path,name,ext] = fileparts(filename);
  
  switch ext
    case '.mat'
      
      save(filename, 'a');
      
    case '.xml'
      
      % convert object to xml
      xml = com.mathworks.xml.XMLUtils.createDocument('ltpda_object');
      parent = xml.getDocumentElement;
      
      utils.xml.xmlwrite(a, xml, parent, '');    % Save the XML document.
      xmlwrite(filename, xml);
      
    otherwise
      error('### unknown file extension.');
  end
end
