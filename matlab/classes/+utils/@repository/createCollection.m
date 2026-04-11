function cid = createCollection(conn, ids)
% CREATECOLLECTION  Creates a new collection.
%
%   cid = utils.repository.createCollection(conn, ids)
%
% Create a new collection constituted by object with id IDS and
% returns the newly created collection id CID. CONN must be a
% database connection object implementing java.sql.Connection.

  import utils.const.*

  % ensure we have a row vector
  ids = ids(:)';

  utils.helper.msg(msg.PROC1, 'creating collection for objects %s', num2str(ids, '%d '));

  cols = utils.mysql.execute(conn, 'SHOW COLUMNS FROM collections');
  if utils.helper.ismember('obj_ids', cols(:,1))
    % use old database schema
    utils.helper.msg(msg.PROC2, 'using old collections representation');

    % insert record into collections table
    stmt = conn.prepareStatement(...
        'INSERT INTO collections (nobjs, obj_ids) VALUES (?, ?)');
    stmt.setObject(1, length(ids));
    stmt.setObject(2, java.lang.String(utils.prog.csv(ids)));
    stmt.executeUpdate();

    % obtain new collection id
    rs = stmt.getGeneratedKeys();
    rs.next();
    cid = rs.getInt(1);
    rs.close();
    stmt.close();

  else
    % use new database schema

    % obtain new collection id
    stmt = conn.prepareStatement(...
        'INSERT INTO collections () VALUES ()');
    stmt.executeUpdate();
    rs = stmt.getGeneratedKeys();
    rs.next();
    cid = rs.getInt(1);
    rs.close();
    stmt.close();

    % insert object ids
    stmt = conn.prepareStatement(...
      'INSERT INTO collections2objs (id, obj_id) VALUES (?, ?)');
    stmt.setObject(1, cid);
    for oid = ids
      stmt.setObject(2, oid);
      stmt.executeUpdate();
    end
    stmt.close();

  end

end