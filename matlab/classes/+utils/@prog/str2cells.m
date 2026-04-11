function newCell = str2cells(someString)
% STR2CELLS Take a single string and separate out individual "elements" into a new cell array.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STR2CELLS Take a single string and separate out individual
%              "elements" into a new cell array. Elements are defined as non-blank characters separated by
%              spaces.
%
%              Similar to str2cell, except str2cell requires an array of strings.
%              str2cells requires only 1 string.
%
% CALL:       newCell = str2cells(aString)
%
% INPUTS:     aString - string
%
% OUTPUTS:    newCell - cell array of strings
%
% EXAMPLE:    Consider the following string in the workspace:
%
% aString = ' a  b        c  d  efgh ij      klmnopqrs t u v w xyz    '
% newCell = 'a'
%           'b'
%           'c'
%           'd'
%           'efgh'
%           'ij'
%           'klmnopqrs'
%           't'
%           'u'
%           'v'
%           'w'
%           'xyz'
%
% REMARK:  This is copied from a file found on MathWorks File Exchange.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If someString is empty then return an empty Cell
if isempty(someString)
  newCell = {};
  return
end

% Trim off any leading & trailing blanks
someString=strtrim(someString);

% Locate all the white-spaces
spaces=isspace(someString);

% Build the cell array
idx=0;
while sum(spaces)~=0
    idx=idx+1;
    newCell{idx}=strtrim(someString(1:find(spaces==1,1,'first')));
    someString=strtrim(someString(find(spaces==1,1,'first')+1:end));
    spaces=isspace(someString);
end
newCell{idx+1}=someString;

