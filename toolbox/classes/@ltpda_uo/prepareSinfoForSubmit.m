% PREPARESINFOFORSUBMIT With this method is it possible to modify the submission structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PREPARESINFOFORSUBMIT This method prepend the timespan
%              property as a XML-String to the 'keywords' of the submission
%              structure. The XML will have the following format:
%
%              <ltpda_uo>
%                <description>
%                </description>
%              </ltpda_uo>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sinfo = prepareSinfoForSubmit(obj, sinfo)
  
  if ~isempty(obj.description)
    sinfo.keywords = sprintf('%s%s', createXML(obj), sinfo.keywords);
  end
  
end

function xml = createXML(obj)
  
  % Create document object
  doc = org.apache.xerces.dom.DocumentImpl();
  
  % Create root element: ltpda_uoh
  rootElement = doc.createElement('ltpda_uo');
  doc.appendChild(rootElement);
  
  % Chreate root child: description
  desc = obj.description(1:min(3e4, length(obj.description)));
  descNode = doc.createElement('description');
  descNode.appendChild(doc.createTextNode(desc));
  rootElement.appendChild(descNode);
  
  % Define the format for XML (omit XML declaration)
  format = org.apache.xml.serialize.OutputFormat(doc);
  format.setOmitXMLDeclaration(true);
  
  % Write XML
  writer = java.io.StringWriter;
  serializer = org.apache.xml.serialize.XMLSerializer(writer, format);
  serializer.serialize(doc)
  
  xml = char(writer.toString);
  
end
