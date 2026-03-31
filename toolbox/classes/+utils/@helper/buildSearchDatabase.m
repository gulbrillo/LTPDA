% BUILDSEARCHDATABASE Build LTPDA documentation search database.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    buildSearchDatabase
%
% DESCRIPTION: BUILDSEARCHDATABASE Build LTPDA documentation search database.
%
% CALL:        utils.helper.buildSearchDatabase();
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function buildSearchDatabase(varargin)
  
  builddocsearchdb(utils.helper.getHelpPath);
  
end
