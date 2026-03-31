% CSVGENERATEDATA Default method to convert a ltpda_uoh-object into csv data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    csvGenerateData
%
% DESCRIPTION:
%
% CALL:        [data, pl] = csvGenerateData(ltpda_uoh)
%
% INPUTS:      ltpda_uoh: Input objects
%
% OUTPUTS:     data: Cell array with the data which should should be
%                    written to the file.
%              pl:   Parameter list which contains the description of the
%                    data. The parameter list must contain the following
%                    keys:
%                'DESCRIPTION':   Description for the file
%                'COLUMNS':       Meaning of each column seperated by a
%                                 comma. For additional information add
%                                 this name as a key and a description as
%                                 the value. For example:
%                                 |  key  |    value
%                                 -----------------------
%                                 |COLUMNS| 'X1, X2'
%                                 |   X1  | 'x-axis data'
%                                 |   X2  | 'y-axis data'
%
%                'NROWS':         Bumber of rows
%                'NCOLS':         Number of columns
%                'OBJECT IDS':    UUID of the objects seperated by a comma
%                'OBJECT NAMES':  Object names seperated by a comma
%                'CREATOR':       Creator of the objects
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data, pl] = csvGenerateData(objs)
  error('### If it is necessary to export a %s-object then add a change request to MANTIS. https://ed.fbk.eu/ltpda/mantis/login_page.php', class(objs));  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plo = getDefaultPlist()
  plo = plist(...
    'DESCRIPTION', '', ...
    'COLUMNS', '', ...
    'NROWS', -1, ...
    'NCOLS', -1, ...
    'OBJECT IDS', '', ...
    'OBJECT NEAMES', '', ...
    'CREATOR', '');
end


