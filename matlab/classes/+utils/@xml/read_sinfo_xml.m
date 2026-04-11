% READ_SINFO_XML reads a submission info struct from a simple XML file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% READ_SINFO_XML reads a submission info struct from a simple XML file.
% 
%  CALL:   sinfo = utils.helper.read_sinfo_xml(file)
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

function pl = read_sinfo_xml(file)
  
  xdoc = xmlread(file);
  
  fields = {'experiment_title', ...
    'experiment_description', ...
    'analysis_description', ...
    'quantity', ...
    'keywords', ...
    'reference_ids', ...
    'additional_comments',...
    'additional_authors'};
  
  pl = plist();
  % Look for a submission info node
  for ii=1:xdoc.getLength
    item = xdoc.item(ii-1);
    if strcmp(char(item.getNodeName), 'submission_info')      
      % Now get all the fields
      for kk=1:item.getLength
        node = item.item(kk-1);        
        name = char(node.getNodeName);
        if any(strcmp(name, fields))
          pl.append(name, strtrim(char(node.getTextContent)));
        end
      end
    end
  end
  
end
