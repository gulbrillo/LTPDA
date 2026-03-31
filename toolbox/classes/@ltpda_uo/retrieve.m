% RETRIEVE retrieves a collection of objects from an LTPDA repository.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: This static method retrieves a collection of objects from an
%              LTPDA repository.
%
% CALL:    objs    = retrieve(conn, obj_id_1, obj_id_2)
%          [o1,o2] = retrieve(conn, obj_id_1, obj_id_2)
%          [o1,o2] = retrieve(conn, 'binary', obj_id_1, obj_id_2)
%          objs    = retrieve(conn, 'Collection', coll_id)
%          objs    = retrieve(conn, 'binary', 'Collection', coll_id)
%
% INPUTS:
%          conn       - database connection object
%          obj_id_N   - an object ID
%          coll_id    - a collection ID
%          'binary'   - to retrieve a binary representation of the object
%                       (if stored)
%
% OUTPUTS:
%          objs          - the retrieved object(s) as a cell array.*
%          o1,o2,...,oN  - returns the first N objects
%
%
% If more than one object is retrieved and only one output is specified
% then the output is a cell array of objects.
%
% If only a single object is requested, it is returned as an object,
% not packed in a cell array.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = retrieve(conn, varargin)

  persistent ltpda_version
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  if nargin < 2
    error('### invalid usage');
  end

  % connection
  if ~isa(conn, 'java.sql.Connection')
    error('### the first argument should be a java.sql.Connection object');
  end

  binary = false;
  if ischar(varargin{1}) && strcmpi(varargin{1}, 'binary')
    % binary
    binary = true;
    varargin = varargin(2:end);
    utils.helper.msg(msg.PROC1, 'binary retrieve');
  end

  if ischar(varargin{1}) && strcmpi(varargin{1}, 'collection')
    % collection
    cid = varargin{2};
    if isempty(cid)
      error('### please indicate a valid Collection ID');
    end
    varargin = varargin(3:end);
    if ~isempty(varargin)
      error('### wrong number of arguments');
    end
    utils.helper.msg(msg.PROC1, 'retrieving collection %d', cid);

    % get list of object IDs from the collection ID
    ids = utils.repository.getCollectionIDs(conn, cid);

  else
    % IDs list
    if isnumeric([varargin{:}])
      ids = [varargin{:}];
    else
      error('### invalid usage: the IDs must be numeric');
    end
  end

  utils.helper.msg(msg.PROC1, ['retrieving object(s) ID' sprintf(' %d', ids)]);

  % output vector
  objs = [];

  try
    
    if isempty(ltpda_version)
      ltpda_version = ver('LTPDA');
    end
    
    for jj = 1:length(ids)

      rows = utils.mysql.execute(conn, 'SELECT version, obj_type FROM objmeta WHERE obj_id = ?', ids(jj));
      if isempty(rows)
        error('### object %d not found', ids(jj));
      end
      objver = rows{1};
      objtype = rows{2};

      % it is only possible to download the object if the object in the
      % database was submitted with the same or lower LTPDA version as
      % the current version
      if utils.helper.ver2num(ltpda_version.Version) < utils.helper.ver2num(objver)
        warning(['### object %d was submitted with newer LTPDA version (%s) '...
               'than this one (%s). Please update'], ids(jj), objver, ltpda_version.Version);
      end

      if binary
        % binary download

        % Retrieve the bytes
        rows = utils.mysql.execute(conn, 'SELECT mat FROM bobjs WHERE obj_id = ?', ids(jj));
        if isempty(rows)
          error('### failed to get binary data for object %d', ids(jj));
        end
        dd = rows{1};

        % Write bytes out to a temp MAT file
        fname = [tempname '.mat'];
        fd = fopen(fname, 'w+');
        fwrite(fd, dd, 'int8');
        fclose(fd);
        % Load the MAT data to a structure
        obj = load(fname);
        % Delete temp file
        delete(fname);
        % Get the struct out
        obj = obj.objs;

        % Check if the retrieved object is a struct
        if isstruct(obj)
          % Call the constructor with this struct
          fcn_name   = [objtype '.update_struct'];
          obj = feval(fcn_name, obj, obj.tbxver);
          obj = feval(objtype, obj);
        end
        % Add tyo object array
        objs = [objs {obj}];

      else
        % xml download

        % get xml
        rows = utils.mysql.execute(conn, 'SELECT xml FROM objs WHERE id = ?', ids(jj));
        if isempty(rows)
          error('### failed to get data for object %d', ids(jj));
        end

        % check xml
        if strcmp(rows{1}(1:13), 'binary submit')
          error('### object %d has binary representation only', ids(jj));
        end

        % parse xml
        stream = java.io.StringBufferInputStream(java.lang.String(rows{1}));
        builder = javax.xml.parsers.DocumentBuilderFactory.newInstance.newDocumentBuilder();
        xdoc = builder.parse(stream);
        obj = utils.xml.xmlread(xdoc);

        % add to output array
        objs = [objs {obj}];

      end
      
    end

  catch ex
    utils.helper.msg(msg.PROC1, '### retrieve error');
    rethrow(ex)
  end

  % Set outputs
  if nargout == 1
    if length(objs) == 1
      varargout{1} = objs{1};
    else
      varargout{1} = objs;
    end
  else
    for k=1:nargout
      varargout{k} = objs{k};
    end
  end
end
