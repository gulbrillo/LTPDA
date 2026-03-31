% RETRIEVE retrieves LTPDA objects from an LTPDA repository with help of a LTPDANamedItem object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RETRIEVE retrieves LTPDA objects from an LTPDA repository
%              with help of a LTPDANamedItem object. The method uses the
%              name of the LTPDANamedItem object and a given timespan for
%              querying the database.
%              The name of the LTPDANamedItem object can contain a MySQL
%              wildcard [%] or it can be a UUID.
%
% CALL:    objs = retrieve(namedItem, pl)
%
% INPUTS:
%          namedItem  - LTPDANamedItem object(s)
%          pl         - Configuration PLIST
%
% OUTPUTS:
%          objs       - the retrieved object(s)
%
% <a href="matlab:utils.helper.displayMethodInfo('LTPDANamedItem', 'retrieve')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = retrieve(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  items = utils.helper.collect_objects(varargin(:), 'LTPDANamedItem');
  pl    = utils.helper.collect_objects(varargin(:), 'plist');
  
  % Apply defaults to plist
  usepl = applyDefaults(getDefaultPlist(), pl);
  
  % Check PLIST
  ts = usepl.find('timespan');
  % Special case for LPF mission databases
  % The LPF mission uses for each day a separate database and it contains
  % data from 8 a.m. to the next day 8 a.m. and the database name has the
  % format: yyyymmdd_X (e.g. 20151205_A)
  if isempty(ts)
    database = usepl.find('database');
    day = regexp(char(database), '^\d{8}', 'match', 'once');
    if ischar(database) && ~isempty(day)
      t = time(day, 'yyyymmdd'); % Day at 0 a.m.
      t = t+8*3600;              % Day at 8 a.m.
      ts = timespan(t, t+24*3600);
    end
  end
  assert(isa(ts, 'timespan'), '### Please define a timespan-object with the configuration PLSIT');
  
  % Create database connection
  conn = LTPDADatabaseConnectionManager().connect(usepl);
  oncleanup = onCleanup(@()conn.close());
  objs = {};
  
  % Check if the user wants the binary object (or XML)
  if utils.prog.yes2true(usepl.find('BINARY'))
    bin = {'binary'};
  else
    bin = {};
  end
  
  for ii=1:numel(items)
    
    allNames = items(ii).getAllParameterNames();
    
    for nn=1:numel(allNames)
      
      % Check if the objects exist
      ids = utils.repository.getObjectIdInTimespan(conn, ts, strcat('%', allNames{nn}, '%'));
      
      % Check if we found an object
      if ~isempty(ids)      
        objs = [objs ltpda_uo.retrieve(conn, bin{:}, ids{:})];
      end
      
    end
    
  end
  
  if iscell(objs) && numel(objs) > 0 && all(cellfun(@(x) isa(x, class(objs{1})), objs))
    % Combine the objects for the case that they are from the same type
    objs = [objs{:}];
  end
  
  varargout{1} = objs;
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  % General plist for retrieving objects
  pl = copy(plist.FROM_REPOSITORY_PLIST, 1);
  
  % Add a 'timespan' parameter
  p = param('timespan', []);
  p.addAlternativeKey('time span')
  pl.append(p);
  
end

