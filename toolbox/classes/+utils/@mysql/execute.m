% EXECUTE Execute the given QUERY with optional parameters VARARGIN
% substituted for the '?' placeholders through connection CONN. In the
% case of data manupulation queries returns the update count. In case
% of data retrival queries returns a 2D cell array with the query
% results and optionally a cell array with column names.
%
% CALL:
%
%          [rows] = utils.mysql.execute(conn, query, varargin)
%   [names, rows] = utils.mysql.execute(conn, query, varargin)
%
% PARAMETERS:
%
%      conn -  an object implementing the java.sql.Connection interface
%     query -  SQL query string. ? are substituted with PARAMS values
%  varargin -  query parameters
%
% RETURNS:
%
%      rows -  update count in the case of data manipulation queries
%              or 2D cell array with query resutls in the case of
%              data retrival queries
%     names -  names of the columns in the result set
%

function varargout = execute(conn, query, varargin)
  
  % check parameters
  if nargin < 2
    error('### incorrect usage');
  end
  if ~isa(conn, 'java.sql.Connection')
    error('### invalid connection');
  end
  
  % build query
  stmt = conn.prepareStatement(query);
  for kk = 1:numel(varargin)
    stmt.setObject(kk, matlab2sql(varargin{kk}));
  end
  
  % execute query
  rv = stmt.execute();
  
  switch rv
    case 0
      % we have an update count
      varargout{1} = stmt.getUpdateCount();
    case 1
      % we have a result set
      rs = stmt.getResultSet();
      
      % get results into a cell array
      md = rs.getMetaData();
      nc = md.getColumnCount();
      row = 1;
      
      if isa(rs, 'com.mysql.jdbc.JDBC4ResultSet')
        % Get size of the output cell
        rs.beforeFirst();
        rs.last();
        nRows = rs.getRow();
        nCol  = nc;
        % Set the pointer back before the first record
        rs.beforeFirst();
        
        % Pre-define
        rows = cell(nRows, nCol);
      else
        rows = {};
      end
      
      names = cell(1, nc);
      while rs.next()
        for kk = 1:nc
          % convert to matlab objects
          rows{row, kk} = java2matlab(rs.getObject(kk));
          if row == 1 
            names{kk} = char(md.getColumnName(kk));
          end
        end
        row = row + 1;
      end
      
      % assign output
      switch nargout
        case 0
          varargout{1} = rows;
        case 1
          varargout{1} = rows;
        case 2
          varargout{1} = names;
          varargout{2} = rows;
        otherwise
          error('### too many output arguments');
      end
      
    otherwise
      erorr('### error');
  end
end


function val = matlab2sql(val)
  switch class(val)
    case 'char'
      % matlab converts length one strings to the wrong java type
      val = java.lang.String(val);
    case 'time'
      % convert time objects to strings
      val = val.format('yyyy-mm-dd HH:MM:SS', 'UTC');
  end
end


function val = java2matlab(val)
  % matlab converts all base types. just add a conversion for datetime columns
  switch class(val)
    case 'java.sql.Timestamp'
      val = time(plist('time', char(val), 'timezone', 'UTC'));
  end
end
