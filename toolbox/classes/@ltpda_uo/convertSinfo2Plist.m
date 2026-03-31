% CONVERTSINFO2PLIST Converts the 'old' sinfo structure to a PLIST-object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CONVERTSINFO2PLIST Converts the 'old' sinfo structure to a
%              PLIST-object.
%              The information in the structure will overwrite the
%              information in the PLIST-object.
%
% CALL:        pl = convertSinfo2Plist(pl, sinfo);
%
% INPUTS:      pl    - plist
%              sinfo - structure with the submission information
%
% INFO:        The submission information are:
%
%                 'experiment_title'       - a title for the submission (Mandatory, >4 characters)
%                 'experiment_description' - a description of this submission (Mandatory, >10 characters)
%                 'analysis_description'   - a description of the analysis performed  (Mandatory, >10 characters));
%                 'quantity'               - the physical quantity represented by the data);
%                 'keywords'               - a comma-delimited list of keywords);
%                 'reference_ids'          - a string containing any reference object id numbers
%                 'additional_comments'    - any additional comments
%                 'additional_authors'     - any additional author names
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pl = convertSinfo2Plist(pl, sinfo)
  
  fields = {...
    'experiment_title', ...
    'experiment_description', ...
    'analysis_description', ...
    'quantity', ...
    'keywords', ...
    'reference_ids', ...
    'additional_comments', ...
    'additional_authors', ...
    'conn'};
  
  for ii = 1:numel(fields)
    if isfield(sinfo, fields{ii})
      pl.pset(strrep(fields{ii}, '_', ' '), sinfo.(fields{ii}));
    end
  end
  
end

