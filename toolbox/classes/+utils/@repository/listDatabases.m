% LISTDATABASES returns a list of database names on the server.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: listDatabases returns a list of database names on the server.
%
% CALL:        names = utils.repository.listDatabases(pl)
%
% INPUTS:      
%
%                     pl - a valid repository plist (with hostname etc)
%    
%   additional supported keys:
% 
%                pattern - a valid regex search pattern, e.g., *_P
%
% See also: regexp
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function names = listDatabases(pl)
  
  % Get a connection to the database.
  conn = LTPDADatabaseConnectionManager().connect(pl);
  oncleanup = onCleanup(@()conn.close());
    
  % query
  q = 'show databases';
  names = utils.mysql.execute(conn, q);
  
  % filter
  pattern = pl.find('pattern');
  if ~isempty(pattern)
    matches = regexpi(names, pattern, 'match');
    names = names(~cellfun(@isempty, matches));
  end
  
end
