function fnames = fields2list(fields)
% FIELDS2LIST splits a string containing fields seperated by ','
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FIELDS2LIST splits a string containing fields seperated by
%              ',' and returns a cell array.
%
% CALL:       fnames = fields2list(fields)
%
% INPUTS:     string - a string seperated by ','
%
% OUTPUTS:    fnames - cell array
%
% EXAMPLE:    >> fields = 'field1, field2, field3, field4';
%             >> ltpda_fields2list(fields)
%             ans =
%                   'field1'    ' field2'    ' field3'    ' field4'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fnames = [];
[f,r] = strtok(fields, ',');
fnames = [fnames  cellstr(f)];
while ~isempty(r)
  [f,r] = strtok(r, ',');
  fnames = [fnames  cellstr(f)];
end


% END