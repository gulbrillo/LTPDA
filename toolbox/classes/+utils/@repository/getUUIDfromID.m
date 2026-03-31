% getUUIDfromID returns the UUID for given database IDs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: getUUIDfromID returns the UUID for given database IDs.
%
% CALL:        UUIDs = utils.repository.getUUIDfromID(pl)
%
% INPUTS:      pl - Parameter-List Object (PLIST) with the keys:
%
%                hostname - Database server hostname.
%                database - Database name.
%                username - User name to use when connecting to the database. Leave blank to be prompted.
%                password - Password to use when connecting to the database. Leave blank to be prompted.
%                ids      - Array of database IDs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outUUIDs = getUUIDfromID(plIn)
  
  % Get the IDs from the input PLIST
  ids = plIn.mfind('id', 'ids');
  if isempty(ids)
    error('Please define some IDS in the input PLIST.');
  end
  
  % Get a connection to the database.
  conn = LTPDADatabaseConnectionManager().connect(plIn);
  
  q = 'SELECT objs.UUID FROM objs WHERE objs.id=?';
  oncleanup = onCleanup(@()conn.close());
  
  outUUIDs = cell(numel(ids),1);
  for ii=1:numel(ids)
    outUUIDs(ii) = utils.mysql.execute(conn, q, ids(ii));
  end
  
end
