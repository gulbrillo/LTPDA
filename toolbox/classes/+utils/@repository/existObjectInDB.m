% existObjectInDB checks if a given name exist in the database table objmeta.name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: existObjectInDB checks if a given name exist in the database
%              table objmeta.name. It is also possible to specify for AOs
%              with time-series a time-span.
%              If the object(s) exist then this method returns the object
%              ID(s) of the objects(s).
%
% CALL:        result = existObjectInDB(conn, name, ts, constraints)
%
% INPUTS:      conn        - A java.sql.Connection
%                            It is possible to get a connection with the command:
%                            conn = LTPDADatabaseConnectionManager().connect(pl);
%              name        - String to look for in the table objmeta
%                            It could be a 'name' string or a UUID String
%                            The UUID string must have the format:
%                            xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
%                            with x = [a-zA-Z0-9]
%              ts          - Timespan object (optional)
%              constraints - String with additional constrain(s) for the query (optional)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = existObjectInDB(conn, name, ts, constraints, varargin)
  
  % Check inputs
  if nargin < 4
    constraints = '';
  end
  if nargin < 3
    ts = [];
  end
  if nargin < 2
    error('Not enough input arguments.');
  end
  
  % Check typ of inputs
  if  ~isa(conn, 'java.sql.Connection')
    error('The first input must be a java.sql.Connection but it is a %s', class(conn));
  end
  if ~ischar(name)
    error('The second input must be a String but it is a %s', class(name));
  end
  
  % Check if 'name' is a UUID string
  uuid        = false;
  expression  = '^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$';
  if ~isempty(regexp(name, expression, 'match'))
    uuid = true;
  end
  
  if isempty(ts)
    
    % Define query without a time span
    if ~uuid
      % Look for a name
      q = sprintf('SELECT objmeta.obj_id FROM objmeta WHERE objmeta.name like ?');
      q = addConstraints(q, constraints);
    else
      % Look for a UUID
      q = sprintf('SELECT objs.id FROM objs WHERE objs.uuid like ?');
      q = addConstraints(q, constraints);
    end
    
    result = utils.mysql.execute(conn, q, name);
  else
    
    % Make a query to get the info if we have the old or new database structure
    q = 'SHOW COLUMNS FROM ao LIKE ''data_id''';
    newDBschema = isempty(utils.mysql.execute(conn, q));
    
    % Define query with a time span
    if newDBschema
      if ~uuid
        % Look for name
        q = ['SELECT objmeta.obj_id FROM objmeta, tsdata ' ...
          'WHERE objmeta.obj_id=tsdata.obj_id ' ...
          'AND objmeta.name LIKE ? ' ...
          'AND tsdata.t0+INTERVAL tsdata.nsecs SECOND >= ? ' ...
          'AND tsdata.t0 <= ? ' ];
      else
        % Look for UUID
        q = ['SELECT objs.id FROM objs, tsdata ' ...
          'WHERE objs.id=tsdata.obj_id ' ...
          'AND objs.uuid LIKE ? ' ...
          'AND tsdata.t0+INTERVAL tsdata.nsecs SECOND >= ? ' ...
          'AND tsdata.t0 <= ? ' ];
      end
    else
      % Old database structure
      q = ['SELECT objmeta.obj_id FROM objmeta, ao, tsdata ' ...
        'WHERE objmeta.obj_id=ao.obj_id AND ao.data_id=tsdata.id ' ...
        'AND objmeta.name LIKE ? ' ...
        'AND tsdata.t0+INTERVAL tsdata.nsecs SECOND >= ? ' ...
        'AND tsdata.t0 <= ? '];
    end
    q = addConstraints(q, constraints);
    result = utils.mysql.execute(conn, q, ...
      name, ...
      format(ts.startT, 'yyyy-mm-dd HH:MM:SS', 'UTC'), ...
      format(ts.endT,   'yyyy-mm-dd HH:MM:SS', 'UTC'));
  end
  
end

function q = addConstraints(q, constraints)
  if ~isempty(constraints)
    q = [ q ' AND ' constraints ];
  end
end













