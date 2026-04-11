function id = insertObjMetadataV1(conn, obj, objid)
% an utility to insert entries for various object metadata in the
% corresponding tables. uses the old v2.1 database schema.
%
% MUST BE KEPT IN SYNC WITH updateObjMetadataV1()
%
% conn   - Java database connection object
% obj    - object
% objid  - unique ID of the object in the database
%

  import utils.const.*

  if nargin < 3
    error('### incorrect usage');
  end
  if ~isjava(conn)
    error('### incorrect usage');
  end

  % default output value
  id = [];

  % class of object
  cl = class(obj);
  utils.helper.msg(msg.PROC2, 'making meta data entry for %s object', cl);

  switch cl
    case 'ao'

      % call recursively to insert the data object info
      dataid = utils.repository.insertObjMetadataV1(conn, obj.data, objid);

      % insert the AO info
      stmt = conn.prepareStatement(...
        'INSERT INTO ao (obj_id, data_type, data_id, description) VALUES (?, ?, ?, ?)');
      stmt.setObject(1, objid);
      stmt.setObject(2, java.lang.String(class(obj.data)));
      stmt.setObject(3, dataid);
      desc = obj.description;
      if length(desc)>65535
        warning('Object description length exceeded. Truncating to 65535 characters');
        desc = desc(1:65535);
      end
      stmt.setObject(4, java.lang.String(desc));
      stmt.execute();
      stmt.close();

    case 'cdata'

      stmt = conn.prepareStatement(...
        'INSERT INTO cdata (yunits) VALUES (?)');
      stmt.setObject(1, java.lang.String(char(obj.yunits)));
      stmt.executeUpdate();

      % obtain generated data id
      rs = stmt.getGeneratedKeys();
      rs.next();
      id = rs.getInt(1);
      rs.close();
      stmt.close();

    case 'fsdata'

      % possible bad entries
      fs = obj.fs;
      if ~isfinite(fs)
        fs = [];
      end

      stmt = conn.prepareStatement(...
        'INSERT INTO fsdata (xunits, yunits, fs) VALUES (?, ?, ?)');
      stmt.setObject(1, java.lang.String(char(obj.xunits)));
      stmt.setObject(2, java.lang.String(char(obj.yunits)));
      stmt.setObject(3, fs);
      stmt.executeUpdate();

      % obtain generated data id
      rs = stmt.getGeneratedKeys();
      rs.next();
      id = rs.getInt(1);
      rs.close();
      stmt.close();

    case 'tsdata'

      stmt = conn.prepareStatement(...
        'INSERT INTO tsdata (xunits, yunits, fs, t0, nsecs) VALUES (?, ?, ?, ?, ?)');
      stmt.setObject(1, java.lang.String(char(obj.xunits)));
      stmt.setObject(2, java.lang.String(char(obj.yunits)));
      stmt.setObject(3, obj.fs);
      stmt.setObject(4, java.lang.String(format(obj.t0, 'yyyy-mm-dd HH:MM:SS', 'UTC')));
      stmt.setObject(5, obj.nsecs);
      stmt.executeUpdate();

      % obtain generated data id
      rs = stmt.getGeneratedKeys();
      rs.next();
      id = rs.getInt(1);
      rs.close();
      stmt.close();

    case 'xydata'

      stmt = conn.prepareStatement(...
        'INSERT INTO xydata (xunits, yunits) VALUES (?, ?)');
      stmt.setObject(1, java.lang.String(char(obj.xunits)));
      stmt.setObject(2, java.lang.String(char(obj.yunits)));
      stmt.executeUpdate();

      % obtain generated data id
      rs = stmt.getGeneratedKeys();
      rs.next();
      id = rs.getInt(1);
      rs.close();
      stmt.close();

    case 'mfir'

      stmt = conn.prepareStatement(...
        'INSERT INTO mfir (obj_id, in_file, fs) VALUES (?, ?, ?)');
      stmt.setObject(1, objid);
      stmt.setObject(2, java.lang.String(obj.infile));
      stmt.setObject(3, obj.fs);
      stmt.execute();
      stmt.close();

    case 'miir'

      stmt = conn.prepareStatement(...
        'INSERT INTO miir (obj_id, in_file, fs) VALUES (?, ?, ?)');
      stmt.setObject(1, objid);
      stmt.setObject(2, java.lang.String(obj.infile));
      stmt.setObject(3, obj.fs);
      stmt.execute();
      stmt.close();

    otherwise
      utils.helper.msg(msg.PROC2, 'no meta data table for %s object', cl);

  end
end
