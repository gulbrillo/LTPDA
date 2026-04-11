% OBJ2XML Converts an object to an XML representation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Converts an object to XML representation.
%
% CALL:       xml = utils.prog.obj2xml(obj)
%
% INPUTS:     obj - the object to be converted
%
% OUTPUTS:    xml - the converted object
%
% EXAMPLE:    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = obj2xml(obj)
            
  % make pointer to xml document
  xml = com.mathworks.xml.XMLUtils.createDocument('ltpda_object');

  % extract parent node
  parent = xml.getDocumentElement;
  
  % add an 'ltpda_version' attribute to the root node
  ltpda_version = getappdata(0, 'ltpda_version');
  parent.setAttribute('ltpda_version', ltpda_version);
  
  % write obj into xml
  utils.xml.xmlwrite(obj, xml, parent, '');
  
  % convert into a string
  str = xmlwrite(xml);
end
