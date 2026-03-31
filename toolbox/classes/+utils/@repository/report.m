% UTILS.REPOSITORY.REPORT Dumps the records of a database to a file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: UTILS.REPOSITORY.REPORT Dumps the records of a database to a file
%
% CALL:      utils.repository.report(pl)
%
% PARAMETER: HOSTNAME           - Database server hostname.
%            DATABASE           - Database name.
%            USERNAME           - User name to use when connecting to the database. Leave blank to be prompted.
%            PASSWORD           - Password to use when connecting to the database. Leave blank to be prompted.
%            OUTPUT FILE
%            FILENAME           - Filename for the report
%            MAXRECORDS         - Define the maximum number of records for the file
%            SUBMITTED TIMESPAN - Define the time span of the submitted objects.
%
% <a href="matlab:utils.helper.displayMethodInfo(utils.repository.report([], 'INFO', ''))">Parameter Sets</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = report(varargin)
  
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo();
    return
  end
  
  % Check number of inputs
  error(nargchk(1, 1, nargin, 'struct'));
  
  % Get inputs
  pl = combine(varargin{1}, getDefaultPlist());
  
  % Get connection from database manager
  conn = LTPDADatabaseConnectionManager().connect(pl);
  % Register cleanup handler to close the database connection
  oncleanup1 = onCleanup(@()conn.close());
  
  % Display the number of record we found
  utils.helper.msg(utils.const.msg.USER , '*** Get number of records');
  q = sprintf('SELECT COUNT(*) FROM objs;');
  tic();
  allRecords = utils.mysql.execute(conn, q);
  utils.helper.msg(utils.const.msg.USER , '*** Found %d records overall (%.2f seconds)', allRecords{:}, toc());
  
  % Check if the user have defined a 'submitted' timespan
  sts = pl.find_core('submitted timespan');
  if ~isempty(sts) && ~isa(sts, 'timespan')
    error('### The parameter ''submitted timespan'' must be a timespan object but it is a ''%s'' object', class(sts))
  end
  
  if ~isempty(sts)
    % Get a list of IDs, object-class and where applicable the data type
    % <id>, <class>, <data type>
    t1 = sts.startT.format('yyyy-mm-dd HH:MM:SS', 'UTC');
    t2 = sts.endT.format('yyyy-mm-dd HH:MM:SS', 'UTC');
    q = sprintf('SELECT objmeta.obj_id, objmeta.obj_type, ao.data_type FROM objmeta LEFT JOIN ao ON objmeta.obj_id=ao.obj_id WHERE (objmeta.submitted > ''%s'') AND (objmeta.submitted < ''%s'')', t1, t2);
  else
    % <id>, <class>, <data type>
    q = sprintf('SELECT objmeta.obj_id, objmeta.obj_type, ao.data_type FROM objmeta LEFT JOIN ao ON objmeta.obj_id=ao.obj_id');
  end
  tic();
  allIds = utils.mysql.execute(conn, q);
  utils.helper.msg(utils.const.msg.USER , '*** Use %d records in defined time span (%.2f seconds)', size(allIds,1), toc());
  
  % Open file for the output
  file = pl.find_core('output file');
  if isempty(file)
    file = sprintf('%s_%s.csv', pl.find_core('database'), time().format('yyyymmdd'));
  end
  fid = fopen(file, 'w');
  % Register cleanup handler to close the file
  oncleanup2 = onCleanup(@() fclose(fid));
  
  % Write header of the file
  fprintf(fid, '%% DATE:     %s\n', time().format('HH:MM:SS dd-mm-yyyy'));
  fprintf(fid, '%% HOSTNAME: %s\n', pl.find_core('hostname'));
  fprintf(fid, '%% DATABASE: %s\n', pl.find_core('database'));
  fprintf(fid, '%%\n');
  fprintf(fid, '<id>; <uuid>; <class>; <name>; <description>; <experiment title>; <experiment description>; <analysis description>; <yunits>; <xunits>; <fs>; <nsecs>; <t0>\n');
  
  numRecords = min(pl.find_core('maxRecords'), size(allIds,1));
  utils.helper.msg(utils.const.msg.USER , '*** Write %d records in file (%s)', numRecords, file);
  
  % for each ID we print info
  tic();
  for ll= 1:numRecords
    
    if mod(ll,100) == 1
      utils.helper.msg(utils.const.msg.USER, '*** Writing %d records.', min(numRecords, ll+99));
    end
    if mod(ll,100) == 0 && ll~=numRecords
      fprintf('\b - done -\n');
    end
    
    id = allIds{ll,1};
    
    % Get general Info
    q = sprintf('SELECT objs.id, objs.uuid, objmeta.obj_type, objmeta.name, ao.description, objmeta.experiment_title, objmeta.experiment_desc, objmeta.analysis_desc FROM objs LEFT JOIN ao AS ao ON objs.id=ao.obj_id LEFT JOIN objmeta AS objmeta ON objs.id=objmeta.obj_id WHERE objs.id=%d', id);
    generalInfo = utils.mysql.execute(conn, q);
    
    % Write general Info to file
    fprintf(fid, '%d; %s; %s; %s; %s; %s; %s; %s;', generalInfo{:});
    
    objClass = allIds{ll, 2};
    
    % get object class
    switch objClass
      case 'ao'
        
        dataClass = allIds{ll, 3};
        switch dataClass
          case 'tsdata'
            q = sprintf('SELECT tsdata.yunits, tsdata.xunits, tsdata.fs, tsdata.nsecs, tsdata.t0 FROM tsdata WHERE tsdata.obj_id=%d', id);
            tsdataInfo = utils.mysql.execute(conn, q);
            fprintf(fid, '%s; %s; %.17g; %.17g; %s;', tsdataInfo{1:end-1}, char(tsdataInfo{end}));
          case 'fsdata'
            q = sprintf('SELECT fsdata.yunits, fsdata.xunits, fsdata.fs FROM fsdata WHERE fsdata.obj_id=%d', id);
            fsdataInfo = utils.mysql.execute(conn, q);
            fprintf(fid, '%s; %s; %.17g;', fsdataInfo{:});
          case 'xydata'
            q = sprintf('SELECT xydata.yunits, xydata.xunits FROM xydata WHERE xydata.obj_id=%d', id);
            xydataInfo = utils.mysql.execute(conn, q);
            fprintf(fid, '%s; %s;', xydataInfo{:});
          case 'cdata'
            q = sprintf('SELECT cdata.yunits FROM cdata WHERE cdata.obj_id=%d', id);
            cdataInfo = utils.mysql.execute(conn, q);
            fprintf(fid, '%s;', cdataInfo{:});
          case 'xyzdata'
          otherwise
        end
        
      otherwise
        % generic output
    end
    fprintf(fid, '\n');
  end
  fprintf('\b - done -\n');
  
end

function ii = getInfo(varargin)
  sets = {'Default'};
  pl   = getDefaultPlist();
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end

function pl = getDefaultPlist()
  
  % Plist for connecting to a database.
  pl = copy(plist.DATABASE_CONNECTION_PLIST, 1);
  
  % Add alternative name to 'database'
  pl.addAlternativeKeys('database', 'repository');
  
  % Remove the 'conn' parameter
  pl.remove('conn');
  
  % Add 'output file' parameter
  p = param({'output file', 'Filename for the report'}, paramValue.EMPTY_STRING);
  p.addAlternativeKey('filename');
  pl.append(p);
  
  % Add maximum number of records
  p = param({'maxRecords', 'Define the maximum number of records'}, paramValue.DOUBLE_VALUE(1000));
  pl.append(p);
  
  % Submitted time
  p = param({'submitted timespan', 'Define the time span of the submitted objects.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end

