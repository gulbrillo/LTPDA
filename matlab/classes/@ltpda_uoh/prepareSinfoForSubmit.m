% PREPARESINFOFORSUBMIT This method prepend the timespan as a XML-String to the submission structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PREPARESINFOFORSUBMIT This method prepend the timespan
%              property as a XML-String to the 'keywords' of the submission
%              structure. The XML will have the following format:
%
%              <ltpda_uoh>
%                <timespan>
%                  <start> ... </start>
%                  <stop> ... </stop>
%                </timespan>
%              </ltpda_uoh>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sinfo = prepareSinfoForSubmit(obj, sinfo)
  
  if ~isempty(obj.timespan)
    sinfo.keywords = sprintf('%s%s', createXML(obj), sinfo.keywords);
  end
  
  sinfo = prepareSinfoForSubmit@ltpda_uo(obj, sinfo);
  
end

function xml = createXML(obj)
  
  tFormat = 'yyyy-mm-dd HH:MM:SS';
  tZone   = 'UTC';
  tStart  = obj.timespan.startT.format(tFormat, tZone);
  tStop   = obj.timespan.endT.format(tFormat,   tZone);
  
  % Create document object
  doc = org.apache.xerces.dom.DocumentImpl();
  
  % Create root element: ltpda_uoh
  rootElement = doc.createElement('ltpda_uoh');
  doc.appendChild(rootElement);
  
  % Chreate root child: timespan
  timespanNode = doc.createElement('timespan');
  rootElement.appendChild(timespanNode);
  
  % Create timespan child: start
  startNode = doc.createElement('start');
  startNode.appendChild(doc.createTextNode(tStart));
  timespanNode.appendChild(startNode);
  
  % Create timespan child: stop
  stopNode = doc.createElement('stop');
  stopNode.appendChild(doc.createTextNode(tStop));
  timespanNode.appendChild(stopNode);
  
  % Define the format for XML (omit XML declaration)
  format = org.apache.xml.serialize.OutputFormat(doc);
  format.setOmitXMLDeclaration(true);
  
  % Write XML
  writer = java.io.StringWriter;
  serializer = org.apache.xml.serialize.XMLSerializer(writer, format);
  serializer.serialize(doc)
  
  xml = char(writer.toString);
  
end
