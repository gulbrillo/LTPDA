function insertObjMetadata(conn, obj, objid)
% an utility to insert entries for various object metadata in the
% corresponding tables. differs from insertObjMetadataV1() by
% the use of the new v3.0 database structure
%
% MUST BE KEPT IN SYNC WITH updateObjMetadata()
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
      utils.repository.insertObjMetadata(conn, obj.data, objid);

      % insert the AO info
      stmt = conn.prepareStatement(...
        'INSERT INTO ao (obj_id, data_type, description) VALUES (?, ?, ?)');
      stmt.setObject(1, objid);
      if ~isempty(obj.data)
        stmt.setObject(2, java.lang.String(class(obj.data)));
      else
        stmt.setObject(2, java.lang.String('cdata'));
      end
      
      desc = obj.description;
      if length(desc)>65535
        warning('Object description length exceeded. Truncating to 65535 characters');
        desc = desc(1:65535);
      end
      stmt.setObject(3, java.lang.String(desc));
      stmt.execute();
      stmt.close();

    case 'cdata'

      stmt = conn.prepareStatement(...
        'INSERT INTO cdata (obj_id, yunits) VALUES (?, ?)');
      stmt.setObject(1, objid);
      stmt.setObject(2, java.lang.String(char(obj.yunits)));
      stmt.execute();
      stmt.close();

    case 'fsdata'

      % possible bad entries
      fs = obj.fs;
      if ~isfinite(fs)
        fs = [];
      end
        
      stmt = conn.prepareStatement(...
        'INSERT INTO fsdata (obj_id, xunits, yunits, fs) VALUES (?, ?, ?, ?)');
      stmt.setObject(1, objid);
      stmt.setObject(2, java.lang.String(char(obj.xunits)));
      stmt.setObject(3, java.lang.String(char(obj.yunits)));
      stmt.setObject(4, fs);
      stmt.execute();
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
        'INSERT INTO tsdata (obj_id, xunits, yunits, fs, t0, nsecs, toffset) VALUES (?, ?, ?, ?, ?, ?, ?)');
      stmt.setObject(1, objid);
      stmt.setObject(2, java.lang.String(char(obj.xunits)));
      stmt.setObject(3, java.lang.String(char(obj.yunits)));
      stmt.setObject(4, obj.fs);
      stmt.setObject(5, java.lang.String(format(t0, 'yyyy-mm-dd HH:MM:SS', 'UTC')));
      stmt.setObject(6, obj.nsecs);
      stmt.setObject(7, toffset);
      stmt.execute();
      stmt.close();

    case 'xydata'

      stmt = conn.prepareStatement(...
        'INSERT INTO xydata (obj_id, xunits, yunits) VALUES (?, ?, ?)');
      stmt.setObject(1, objid);
      stmt.setObject(2, java.lang.String(char(obj.xunits)));
      stmt.setObject(3, java.lang.String(char(obj.yunits)));
      stmt.execute();
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
