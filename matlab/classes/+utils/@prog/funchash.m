function h = funchash(fcnname)

% FUNCHASH compute MD5 hash of a MATLAB m-file.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FUNCHASH compute MD5 hash of a MATLAB m-file.
%
% CALL:       h = funchash(mfile_name)
%
% INPUTS:     fcnname - The name of an m-file.
% 
% The first file found by 'which' is hashed.
%
% OUTPUTS:    h  - the hash string
%
% PARAMETERS: None.
% 
% EXAMPLES:
% 
%     >> h = funchash('ao');
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get filename
s = which(fcnname);

% Read in file
mfile = textread(s,'%s','delimiter','\n','whitespace','');

% hash this
h = ltpda_hash(char(mfile), 'MD5');

