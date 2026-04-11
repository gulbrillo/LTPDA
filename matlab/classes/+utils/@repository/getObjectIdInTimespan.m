% GETOBJECTIDINTIMESPAN returns the object ID for a given timespan which fits into the timespan of the metadata.keywords.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETOBJECTIDINTIMESPAN returns the object ID for a given
%              timespan which fits into the timespan of the
%              metadata.keywords. Since December 2015 can each LTPDA object
%              define a timespan. This information will go into the meta
%              data table (objmeta) as a XML string like:
%              <ltpda_uoh>
%                <timespan>
%                  <start>2016-01-15 22:00:00</start>
%                  <stop>2016-01-15 22:16:40</stop>
%                </timespan>
%              </ltpda_uoh>
%
% CALL:        result = getObjectIdInTimespan(conn, ts)
%              result = getObjectIdInTimespan(conn, ts, name)
%              result = getObjectIdInTimespan(conn, ts, name, constraints)
%
% INPUTS:      conn      - A java.sql.Connection
%                          It is possible to get a connection with the command:
%                          conn = LTPDADatabaseConnectionManager().connect(pl);
%              ts        - Timespan object
%              name      - A String to look for the 'name' in the table objmeta
%              name      - UUID String to look for the 'uuid' in the table
%                          objs. The UUID string must have the format:
%                          xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
%                          with x = [a-zA-Z0-9] (optional)
%              constrain - String with additional constrain(s) for the query (optional)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = getObjectIdInTimespan(conn, ts, varargin)
  
  % Check inputs
  if nargin < 2
    error('Not enough input arguments.');
  end
  if nargin < 4
    constraints = '';
  else
    constraints = varargin{2};
  end
  if nargin < 3
    name = '';
  else
    name = strtrim(varargin{1});
  end
  % Check inputs
  if  ~isa(conn, 'java.sql.Connection')
    error('The first input must be a java.sql.Connection but it is from type [%s]', class(conn));
  end
  if ~isa(ts, 'timespan') || numel(ts) ~= 1
    error('The second input must be a single timespan object but it is from type [%s]', class(ts));
  end
  
  % Define query for timepsan
  qTimespan = ['SELECT objmeta.obj_id FROM objmeta LEFT JOIN objs ON objs.id = objmeta.obj_id WHERE ', ...
    '    CASE WHEN (@start:=STR_TO_DATE(ExtractValue(objmeta.keywords, "/ltpda_uoh/timespan/start"), "%Y-%m-%d %H:%i:%s")) IS NULL THEN false ELSE @start END ',  ... % Get start time from the XML
    'AND CASE WHEN (@stop:=STR_TO_DATE(ExtractValue(objmeta.keywords,  "/ltpda_uoh/timespan/stop"),  "%Y-%m-%d %H:%i:%s")) IS NULL THEN false ELSE @stop  END ',  ... % Get start time from the XML
    'AND (   (@start >= ? AND @start <= ?) ', ...
    '     OR (@stop  >= ? AND @stop  <= ?) ', ...
    '     OR (@start <  ? AND @stop  > ?)) '];
  
  % Define query for either name or UUID
  if ~isempty(name)
    expression  = '^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$';
    if ~isempty(regexp(name, expression, 'match', 'once'))
     qName = sprintf('AND objs.uuid LIKE    ''%s'' ', name);
    else
     qName = sprintf('AND objmeta.name LIKE ''%s'' ', name);
    end
  else
    qName = ' ';
  end
  
  % Define query for constrain
  if ~isempty(constraints)
    % Check if the constraints have already an 'AND'
    if isempty(regexpi(strtrim(constraints), '^AND'))
      qConstraints = [' AND ' constraints];
    else
      qConstraints = constraints;
    end
  else
    qConstraints = ' ';
  end
  
  % Define start stop time string.
  startStr = ts.startT.format('yyyy-mm-dd HH:MM:SS', 'UTC');
  stopStr  = ts.endT.format('yyyy-mm-dd HH:MM:SS',   'UTC');
  
  % Create entire query
  q = [qTimespan, qName, qConstraints];
  
  % Ger the results
  result = utils.mysql.execute(conn, q, startStr, stopStr, startStr, stopStr, startStr, stopStr);
  
end
