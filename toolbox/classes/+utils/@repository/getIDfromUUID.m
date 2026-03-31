% getIDfromUUID returns the UUID for given database IDs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: getIDfromUUID returns the UUID for given database IDs.
%
% CALL:        IDs = utils.repository.getIDfromUUID(pl)
%
% INPUTS:      pl - Parameter-List Object (PLIST) with the keys:
%
%                hostname - Database server hostname.
%                database - Database name.
%                username - User name to use when connecting to the database. Leave blank to be prompted.
%                password - Password to use when connecting to the database. Leave blank to be prompted.
%                uuids    - Cell-Array of UUIDs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outIDs = getIDfromUUID(plIn)
  
  % Get the IDs from the input PLIST
  uuids = plIn.find('uuids');
  if isempty(uuids)
    error('Please define UUIDs in the input PLIST.');
  end
  uuids = cellstr(uuids);
  
  % Get a connection to the database.
  conn = LTPDADatabaseConnectionManager().connect(plIn);
  
  q = 'SELECT objs.ID FROM objs WHERE objs.uuid LIKE ?';
  oncleanup = onCleanup(@()conn.close());
  
  outIDs = zeros(numel(uuids),1);
  for ii=1:numel(uuids)
    ids = cell2mat(utils.mysql.execute(conn, q, uuids{ii}));
    if numel(ids) > 1
      warning('I found for some reason multiple IDs [%s] for the given UUID [%s]', utils.helper.val2str(ids), uuids{ii});
    end
    outIDs(ii) = ids(1);
  end
  
end
