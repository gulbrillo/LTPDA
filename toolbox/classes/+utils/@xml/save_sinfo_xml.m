% SAVE_SINFO_XML saves a submission info struct to a simple XML file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SAVE_SINFO_XML saves a submission info struct to a simple XML file.
%
%  CALL:   sinfo = utils.helper.save_sinfo_xml(file)
%
% The XML file should have a main node called 'submission_info'. Then all
% sub-nodes supported by the sinfo fields will be read.
%
% For example:
%
% <submission_info>
%   <experiment_title>
%   some nice experiment we can use
%   </experiment_title>
%   <experiment_description>
%   Some nice experiment we did with some crazy results.
%   But sometimes it takes a new line to describe in detail.
%   </experiment_description>
% </submission_info>
%
% Supported fields:
%
% 'experiment_title'
% 'experiment_description'
% 'analysis_description'
% 'quantity'
% 'keywords'
% 'reference_ids'
% 'additional_comments'
% 'additional_authors'
%
% I Diepholz 022-03-10
%

function save_sinfo_xml(filename, sinfo)
  
  xml = com.mathworks.xml.XMLUtils.createDocument('submission_info');
  parent = xml.getDocumentElement;
  
  fieldNames = fieldnames(sinfo);
  for ii = 1:numel(fieldNames);
    field = fieldNames{ii};
    
    newNode = xml.createElement(field);
    parent.appendChild(newNode);
    
    
    content = xml.createTextNode(sinfo.(field));
    newNode.appendChild(content);    
    
  end

  xmlwrite(filename, xml);
  
end
