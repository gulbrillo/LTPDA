%
% DESCRIPTION: Returns a table enty for the given inputs: database table,
%              column name, object ID
%

function val = getTableEntry(utp, dbTable, tableField, objID)
  
  try
    % Get the corresponding table ID.
    objID = getTableIdFromTestObj(utp, dbTable, objID);
    
    % Check that we get only one result for the query
    assert(isequal(numel(objID), 1), sprintf('Found more than one data ID for the given object ID %d', objID));
    
    % Create query to get the field 'xunits' from the 'cdata' table
    query = sprintf('SELECT %s.%s FROM %s WHERE %s.%s = ?', dbTable, tableField, dbTable, dbTable, utp.tableId);
    val = utils.mysql.execute(utp.conn, query, objID);
  catch Me
    rethrow(Me);
  end
  
end
