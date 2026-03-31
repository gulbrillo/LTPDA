% A built-in model of class ao called retrieve_in_timespan
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Retrieves tsdata AOs from an LTPDA repository. The repository
% is searched for AOs that match the given names and span the given time range.
% The names can contain the % wildcard to widen the search range.
%
% If more than one object is found matching the search criteria for each name
% the retrieved objects are joined together. The resulting time series are
% truncated to span only the given time range. The name of the output objects
% is set to match the name used for the repository query.
%
% CALL:
%           mdl = ao(plist('built-in', 'retrieve_in_timespan'));
%
% INPUTS:
%
%
% OUTPUTS:
%           mdl - an object of class ao
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('ao_model_retrieve_in_timespan')">Model Information</a>
%
%
% REFERENCES:
%
%
% HISTORY:
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% YOU SHOULD NOT NEED TO EDIT THIS MAIN FUNCTION
function varargout = ao_model_retrieve_in_timespan(varargin)
  
  varargout = utils.models.mainFnc(varargin(:), ...
    mfilename, ...
    @getModelDescription, ...
    @getModelDocumentation, ...
    @getVersion, ...
    @versionTable, ...
    @getPackageName);
  
end


%--------------------------------------------------------------------------
% AUTHORS EDIT THIS PART
%--------------------------------------------------------------------------

function desc = getModelDescription
  desc = 'A built-in model that retrieves tsdata AOs from an LTPDA repository.';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'The repository is searched for AOs that match the given names and span the given time range.\n'...
    'The names can contain the %% wildcard to widen the search range.\n'...
    '<br><br>\n'...
    'If more than one object is found matching the search criteria for each name\n'...
    'the retrieved objects are joined together. The resulting time series are\n'...
    'truncated to span only the given time range. The name of the output objects\n'...
    'is set to match the name used for the repository query.\n'...
    ]);
end

function package = getPackageName
  package = 'ltpda';
end

% default version is always the first one
function vt = versionTable()
  
  vt = {...
    'Version 1', @version1, ...
    };
  
end

% This version is ...
%
function varargout = version1(varargin)
  
  import utils.const.*
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        persistent defaultPlist;
        
        if isempty(defaultPlist)
          
          % The plist for this version of this model
          defaultPlist = copy(plist.FROM_REPOSITORY_PLIST, true);
          defaultPlist.remove('ID');
          defaultPlist.remove('CID');
          
          % names
          p = param({'names', 'Specify a cell-array of names to the AOs to retrieve.'}, paramValue.EMPTY_STRING);
          defaultPlist.append(p);
          
          % start time
          p = param({'start time', 'The start time'}, {1, {'1970-01-01 00:00:00.000'}, paramValue.OPTIONAL});
          p.addAlternativeKey('start_time');
          p.addAlternativeKey('start');
          p.addAlternativeKey('start-time');
          defaultPlist.append(p);
          
          % stop time
          p = param({'stop time', 'The stop time. <br>If empty, the user needs to specify a number of seconds nsecs'}, {1, {'1970-01-01 00:00:00.000'}, paramValue.OPTIONAL});
          p.addAlternativeKey('stop');
          p.addAlternativeKey('stop-time');
          p.addAlternativeKey('stop_time');
          p.addAlternativeKey('end');
          p.addAlternativeKey('end-time');
          p.addAlternativeKey('end_time');
          p.addAlternativeKey('end time');
          defaultPlist.append(p);
          
          % nsecs
          p = param({'nsecs', 'The duration in seconds. <br> Will be used if stop time parameter is empty'}, paramValue.DOUBLE_VALUE([]));
          p.addAlternativeKey('length');
          p.addAlternativeKey('duration');
          defaultPlist.append(p);
          
          % time range
          p = param({'Time range', 'The time range.<br>Will be used if the start time, stop time and number of second<br>were not set'}, paramValue.DOUBLE_VALUE([]));
          p.addAlternativeKey('time-range');
          p.addAlternativeKey('time_range');
          p.addAlternativeKey('timespan');
          defaultPlist.append(p);
          
          % constraints
          p = param({'constraints', 'An additional SQL statement that is appended.'}, paramValue.EMPTY_STRING);
          defaultPlist.append(p);
          
          % fstol, sort, zerofill
          defaultPlist.append(subset(ao.getInfo('join').plists, {'fstol', 'sort', 'zerofill', 'merge'}));
          
          % dryrun
          p = param({'dryrun', 'Description for dryrun'}, paramValue.FALSE_TRUE);
          defaultPlist.append(p);
        end
        
        % set output
        varargout{1} = defaultPlist;
        
      case 'description'
        varargout{1} = 'This version is version 1.';
      case 'info'
        % Add info calls for any other models that you use to build this
        % model. For example:
        %         varargout{1} = [ ...
        %  ao_model_SubModel1('info', 'Some Version') ...
        %  ao_model_SubModel2('info', 'Another Version') ...
        %                        ];
        %
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  % build model
  pl = varargin{1};
  
  % Get parameters
  names       = pl.find_core('names', {});
  constraints = pl.find_core('constraints');
  dryrun      = pl.find_core('dryrun');
  ts          = extractTimeSpan(pl);

  % Make sure that we have a cell array for the names
  % ATTENTION: We can't use cellstr because this function removes trailing
  %            blanks from the 'names' :(
  if ~iscell(names)
    names = {names};
  end
  
  % prepare output
  out = [];
  
  % get database connection
  conn = LTPDADatabaseConnectionManager().connect(pl);
  
  % register cleanup handler to close the database connection
  if isempty(find(pl, 'conn'))
    oncleanup = onCleanup(@()conn.close());
  end
  
  
  % loop over the channels
  for jj = 1:length(names)
    
    % this channel - with proper SQL wildcard
    name = strrep(names{jj}, '*', '%');
    
    utils.helper.msg(msg.PROC2, 'Searching for data named: %s', name);
    
    % Get IDs from the database
    rows = utils.repository.existObjectInDB(conn, name, ts, constraints);
    
    % convert results cell array into a vector of IDs
    ids = [ rows{:} ];
    
    if dryrun
      doDryRun(ids, jj, pl);
      out = ao();
      continue;
    end
    
    if numel(ids) == 0
      
      startTime = format(ts.startT, 'yyyy-mm-dd HH:MM:SS', 'UTC');
      endTime   = format(ts.endT,   'yyyy-mm-dd HH:MM:SS', 'UTC');
      warning off backtrace
      warning('LTPDA:RetrieveInTimeSpan:NoDataFound', 'No data found matching the search parameters: %s between %s and %s', name, startTime, endTime);
      warning on backtrace
      
    else

      % get the rest of the parameters we need
      binary      = utils.prog.yes2true(pl.find_core('binary'));
      fstol       = pl.find_core('fstol');
      sortOutput  = pl.find_core('sort');
      zeroFill    = pl.find_core('zerofill');
      mergeJoin   = pl.find_core('merge');
      
      % collect objects
      if binary
        objs = ltpda_uo.retrieve(conn, 'binary', ids);
      else
        objs = ltpda_uo.retrieve(conn, ids);
      end
      
      switch numel(objs)
        case 0
          error('### retrieve failed');
        case 1
          ojn = objs;
          description = ojn.description;
        otherwise
          % join these up
          objs = [objs{:}];
          ojn = join(objs, plist('fstol', fstol, 'sort', sortOutput, 'zerofill', zeroFill, 'merge', mergeJoin));
          
          descriptions = unique({objs.description});
          
          description = sprintf('%s | ', descriptions{:});
          description(end-2:end) = '';
      end
      
      % split out the bit we want
      os = split(ojn, plist('split_type', 'interval', 'timespan', ts));
      
      % rename the object, removing the wildcard '%' from the name
      os.setName(regexprep(name, '%', ''));
      
      % set the description to the first object joined
      os.setDescription(description);
      
      % add to outputs
      out = [out os];
    end
    
  end % end loop over channels
  
  % make sure we remove any connection object from the plist now since this
  % will go in the history and we can't save it!
  if pl.isparam('conn')
    pl.remove('conn');
  end
  
  varargout{1} = out;
  
end

function ts = extractTimeSpan(pl)
  
  ts    = pl.find_core('time range');
      
  if isempty(ts)
    
    start = pl.find_core('start');
    stop  = pl.find_core('stop');
    nsecs = pl.find_core('nsecs');
    
    if ~isempty(nsecs)
      start = time(start);
      stop = time(start) + nsecs;
    end
    
    ts = timespan(start, stop);    
  end
  
end


function doDryRun(ids, jj, pl)
  
  names       = cellstr(pl.find_core('names', {}));
  ts          = extractTimeSpan(pl);
  
  maxNameLength = max(cellfun(@length, names));
  
  % Output only on screan
  if jj==1
    %
    lvl = LTPDAprefs.verboseLevel();
    LTPDAprefs('Display', 'verboseLevel', -1);
    % It is necessary to define an AO as the output argument because
    % the constructor expects an AO.
    fprintf('--------------------------------------------------------------------------------\n');
    fprintf('Database: %s\n', pl.find('database'));
    fprintf('Timespan: %s - %s\n', char(ts.startT), char(ts.endT));
    fprintf('--------------------------------------------------------------------------------\n');
  end
  if isempty(ids), objExist = '(doesn''t exist)'; else objExist = sprintf('(exist %d ids)', numel(ids)); end
  fprintf('Object name: %1$-*2$s %3$s\n', names{jj}, maxNameLength, objExist);
  
  if jj==length(names)
    % Set verbose level back to previous level
    LTPDAprefs('Display', 'verboseLevel', lvl);
  end
  
end


%--------------------------------------------------------------------------
% AUTHORS SHOULD NOT NEED TO EDIT BELOW HERE
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Get Version
%--------------------------------------------------------------------------
function v = getVersion
  
  v = '';
  
end
