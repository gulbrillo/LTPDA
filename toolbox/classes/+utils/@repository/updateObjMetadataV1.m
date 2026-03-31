function id = updateObjMetadataV1(conn, obj, objid)
% an utility to update entries for various object metadata in the
% corresponding tables. uses the old v2.1 database schema.
%
% MUST BE KEPT IN SYNC WITH insertObjMetadataV1()
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

  % default return value
  id = [];
  
  % class of object
  cl = class(obj);
  utils.helper.msg(msg.PROC2, 'making meta data entry for %s object', cl);

  switch cl
    case 'ao'

      % get data type and id
      stmt = conn.prepareStatement(...
        'SELECT data_id, data_type FROM ao WHERE obj_id = ?');
      stmt.setObject(1, objid);
      rs = stmt.executeQuery();
      rs.next();
      dataid = rs.getInt(1);
      datatype = rs.getString(2);
      rs.close();
      stmt.close();
      
      % check if the data type is consistent
      if ~strcmp(datatype, class(obj.data))
        error('### cannot update an object with one having a different data type');
      end
        
      % call recursively to insert the data object info
      id = utils.repository.updateObjMetadataV1(conn, obj.data, dataid);

      % update ao description
      stmt = conn.prepareStatement(...
        'UPDATE ao SET description=? WHERE obj_id = ?');
      desc = obj.description;
      if length(desc)>65535
        warning('Object description length exceeded. Truncating to 65535 characters');
        desc = desc(1:65535);
      end
      stmt.setObject(1, desc);
      stmt.setObject(2, objid);
      stmt.execute();
      stmt.close();

    case 'cdata'

      stmt = conn.prepareStatement(...
        'UPDATE cdata SET yunits=? WHERE id = ?');
      stmt.setObject(1, char(obj.yunits));
      stmt.setObject(2, objid);
      stmt.execute();
      stmt.close();

    case 'fsdata'

      % possible bad entries
      fs = obj.fs;
      if ~isfinite(fs)
        fs = [];
      end
        
      stmt = conn.prepareStatement(...
        'UPDATE fsdata SET xunits=?, yunits=?, fs=? WHERE id = ?');
      stmt.setObject(1, char(obj.xunits));
      stmt.setObject(2, char(obj.yunits));
      stmt.setObject(3, fs);
      stmt.setObject(4, objid);      
      stmt.execute();
      stmt.close();

    case 'tsdata'

      stmt = conn.prepareStatement(...
        'UPDATE tsdata SET xunits=?, yunits=?, fs=?, t0=?, nsecs=? WHERE id = ?');
      stmt.setObject(1, char(obj.xunits));
      stmt.setObject(2, char(obj.yunits));
      stmt.setObject(3, obj.fs);
      stmt.setObject(4, format(obj.t0, 'yyyy-mm-dd HH:MM:SS', 'UTC'));
      stmt.setObject(5, obj.nsecs);
      stmt.setObject(6, objid);      
      stmt.execute();
      stmt.close();

    case 'xydata'

      stmt = conn.prepareStatement(...
        'UPDATE xydata SET xunits=?, yunits=? WHERE id = ?');
      stmt.setObject(1, char(obj.xunits));
      stmt.setObject(2, char(obj.yunits));
      stmt.setObject(3, objid);      
      stmt.execute();
      stmt.close();

    case 'mfir'

      stmt = conn.prepareStatement(...
        'UPDATE mfir SET in_file=?, fs=? WHERE obj_id = ?');
      stmt.setObject(1, obj.infile);
      stmt.setObject(2, obj.fs);
      stmt.setObject(3, objid);
      stmt.execute();
      stmt.close();

    case 'miir'

      stmt = conn.prepareStatement(...
        'UPDATE miir SET in_file=?, fs=? WHERE obj_id = ?');
      stmt.setObject(1, obj.infile);
      stmt.setObject(2, obj.fs);
      stmt.setObject(3, objid);      
      stmt.execute();
      stmt.close();

    otherwise
      utils.helper.msg(msg.PROC2, 'no meta data table for %s object', cl);

  end

end
