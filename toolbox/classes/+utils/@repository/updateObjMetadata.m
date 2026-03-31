function updateObjMetadata(conn, obj, objid)
% an utility to update entries for various object metadata in the
% corresponding tables. differs from insertObjMetadataV1() by
% the use of the new v3.0 database structure
%
% MUST BE KEPT IN SYNC WITH insertObjMetadata()
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

  % class of object
  cl = class(obj);
  utils.helper.msg(msg.PROC2, 'making meta data entry for %s object', cl);

  switch cl
    case 'ao'

      % call recursively to insert the data object info
      utils.repository.updateObjMetadata(conn, obj.data, objid);

      % insert the AO info
      stmt = conn.prepareStatement(...
        'UPDATE ao SET data_type=?, description=? WHERE obj_id = ?');
      stmt.setObject(1, java.lang.String(class(obj.data)));
      desc = obj.description;
      if length(desc)>65535
        warning('Object description length exceeded. Truncating to 65535 characters');
        desc = desc(1:65535);
      end
      stmt.setObject(2, java.lang.String(desc));
      stmt.setObject(3, objid);
      stmt.executeUpdate();
      stmt.close();

    case 'cdata'

      stmt = conn.prepareStatement(...
        'UPDATE cdata SET yunits=? WHERE obj_id = ?');
      stmt.setObject(1, java.lang.String(char(obj.yunits)));
      stmt.setObject(2, objid);
      stmt.executeUpdate();
      stmt.close();

    case 'fsdata'

      % possible bad entries
      fs = obj.fs;
      if ~isfinite(fs)
        fs = [];
      end
        
      stmt = conn.prepareStatement(...
        'UPDATE fsdata SET xunits=?, yunits=?, fs=? WHERE obj_id = ?');
      stmt.setObject(1, java.lang.String(char(obj.xunits)));
      stmt.setObject(2, java.lang.String(char(obj.yunits)));
      stmt.setObject(3, fs);
      stmt.setObject(4, objid);
      stmt.executeUpdate();
      stmt.close();

    case 'tsdata'

      % Store t0 as the time of the first sample
      if ~isempty(obj.x)
        x0 = obj.x(1);
      else
        x0 = 0;
      end
      t0 = obj.t0 + obj.toffset / 1000.0 + x0;
      
      % Unfortunately MySQL is capable only of seconds resolution for
      % DATETIME fields. We store toffset with seconds resolution as
      % well but rounded so that consistent reference times may be
      % computed in the database: objects with the same reference time
      % are stored in the database in a way so that the reconstructed
      % reference time is the same and equal to the real one within
      % the permitted seconds resolution.
      toffset = floor(t0.double()) - floor(obj.t0.double());

      stmt = conn.prepareStatement(...
        'UPDATE tsdata SET xunits=?, yunits=?, fs=?, t0=?, nsecs=?, toffset=? WHERE obj_id = ?');
      stmt.setObject(1, java.lang.String(char(obj.xunits)));
      stmt.setObject(2, java.lang.String(char(obj.yunits)));
      stmt.setObject(3, obj.fs);
      stmt.setObject(4, java.lang.String(format(t0, 'yyyy-mm-dd HH:MM:SS', 'UTC')));
      stmt.setObject(5, obj.nsecs);
      stmt.setObject(6, toffset);
      stmt.setObject(7, objid);
      stmt.execute();
      stmt.close();

    case 'xydata'

      stmt = conn.prepareStatement(...
        'UPDATE xydata SET xunits=?, yunits=? WHERE obj_id = ?');
      stmt.setObject(1, java.lang.String(char(obj.xunits)));
      stmt.setObject(2, java.lang.String(char(obj.yunits)));
      stmt.setObject(3, objid);
      stmt.execute();
      stmt.close();

    case 'mfir'

      stmt = conn.prepareStatement(...
        'UPDATE mfir SET in_file=?, fs=? WHERE obj_id = ?');
      stmt.setObject(1, java.lang.String(obj.infile));
      stmt.setObject(2, obj.fs);
      stmt.setObject(3, objid);
      stmt.execute();
      stmt.close();

    case 'miir'

      stmt = conn.prepareStatement(...
        'UPDATE miir SET in_file=?, fs=? WHERE obj_id = ?');
      stmt.setObject(1, java.lang.String(obj.infile));
      stmt.setObject(2, obj.fs);
      stmt.setObject(3, objid);
      stmt.execute();
      stmt.close();

    otherwise
      utils.helper.msg(msg.PROC2, 'no meta data table for %s object', cl);

  end

end
