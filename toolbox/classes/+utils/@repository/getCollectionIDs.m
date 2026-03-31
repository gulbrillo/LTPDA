function ids = getCollectionIDs(conn, cid)
% GETCOLLECTIONIDS  Return the IDs of the objects composing a collection.
%
% CALL:
%
%   ids = utils.repository.getCollectionIDs(conn, cid)
%
% PARAMETERS:
%
%   conn  - database connection implementing java.sql.Connection
%    cid  - collection id
%

  try
    % try to use new database schema
    rows = utils.mysql.execute(conn, 'SELECT obj_id FROM collections2objs WHERE id = ?', cid);
    if isempty(rows)
      error('### collection %d not found', cid);
    end    
    ids = [ rows{:} ];
  catch
    % fall back to old one
    rows = utils.mysql.execute(conn, 'SELECT nobjs, obj_ids FROM collections WHERE id = ?', cid);
    if isempty(rows)
      error('### collection %d not found', cid);
    end
    nobjs = rows{1};
    ids = strread(rows{2}, '%d', 'delimiter', ',');
    if length(ids) ~= nobjs
      error('### inconsistent collection description');
    end
    % transform column vector in row vector
    ids = ids';
  end
  
end
