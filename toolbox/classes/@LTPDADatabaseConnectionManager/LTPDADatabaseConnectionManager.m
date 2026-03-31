classdef LTPDADatabaseConnectionManager < handle

  properties(SetAccess=private)

    connections = {};
    credentials = {};
    userMessage = [];

  end % private properties

  properties(Dependent=true)

    credentialsExpiry; % seconds
    cachePassword; % 0=no 1=yes 2=ask
    maxConnectionsNumber;
    knownRepositories; % known repositories stored into prefereces

  end % dependent properties

  methods(Static)

    function reset()
    % RESET Resets the state of the connection manager.
    %
    % This static method removes the LTPDADatabaseConnectionManager
    % instance data from the appdata storage. Causes the reset of the
    % credentials cache and the removal of all the connections from
    % the connection pool.

      rmappdata(0, LTPDADatabaseConnectionManager.appdataKey);
    end


    function key = appdataKey()
    % APPDATAKEY Returns the key used to store instance data in appdata.
    %
    % This is defined as static method, and not has an instance constant
    % property, to to be accessible by the reset static method.

      key = 'LTPDADatabaseConnectionManager';
    end

  end % static methods

  methods

    function cm = LTPDADatabaseConnectionManager()
    % LTPDACONNECTIONMANAGER Manages credentials and database connections.
    %
    % This constructor returns an handler to a LTPDADatabaseConnectionManager
    % class instance. Database connections can be obtained trough the
    % obtained object with the connect() method.
    %
    % The purpose of this class it to keep track of open database connections
    % and to cache database credentials. It must be used in all LTPDA toolbox
    % functions that required to obtain database connections. Its behaviour can
    % be configured via LTPDA toolbox user preferences. The object status is
    % persisted trough the appdata matlab facility.

      % import credentials class
      import utils.credentials

      % load state from appdata
      acm = getappdata(0, cm.appdataKey());

      if isempty(acm)
        % store state in appdata
        setappdata(0, cm.appdataKey(), cm);

        import utils.const.*
        utils.helper.msg(msg.PROC1, 'new connection manager');
      else
        cm = acm;
      end

      % add known repositories from preferences
      repos = cm.knownRepositories;
      for kk = 1:numel(repos)
        repo = repos{kk};
        for jj = 1:3
          % null empty parameters
          if isempty(repo{jj})
            repo{jj} = [];
          end
        end
        cm.add(utils.credentials(repo{:}));
      end

      % reset user message
      cm.userMessage = [];
    end


    function str = disp(cm)
      disp(sprintf('%s()\n', class(cm)));
    end


    function varargout = getCredentials(cm)
      switch nargout
        case 0
          for kk = 1:numel(cm.credentials)
            fprintf('id=%02d %s\n', kk, char(cm.credentials{kk}));
          end
        case 1
          varargout{1} = cm.credentials;
      end
    end


    function val = get.credentialsExpiry(cm)
      % obtain from user preferences
      p = getappdata(0, 'LTPDApreferences');
      val = double(p.getRepoPrefs().getExpiry());
    end


    function val = get.cachePassword(cm)
      % obtain from user preferences
      p = getappdata(0, 'LTPDApreferences');
      val = double(p.getRepoPrefs().getCachePassword());
    end


    function val = get.maxConnectionsNumber(cm)
      % obtain from user preferences
      p = getappdata(0, 'LTPDApreferences');
      val = double(p.getRepoPrefs().getMaxConnectionsNumber());
    end


    function val = get.knownRepositories(cm)
      % obtain from user preferences
      p = getappdata(0, 'LTPDApreferences');
      val = cell(p.getRepoPrefs().getRepositories().toArray());
    end


    function n = count(cm)
    % COUNT Returns the number of open connections in the connections pool.
    %
    % This method has the side effect of removing all closed connections from
    % the connections pool, so that the underlying objects can be garbage
    % collected.

      import utils.const.*

      % find closed connections in the pool
      mask = false(numel(cm.connections), 1);
      for kk = 1:numel(cm.connections)
        if cm.connections{kk}.isClosed()
          utils.helper.msg(msg.PROC1, 'connection id=%d closed', kk);
          mask(kk) = true;
        end
      end

      % remove them
      cm.connections(mask) = [];

      % count remainig ones
      n = numel(cm.connections);
    end

    function clear(cm, ids)
    % CLEAR Removes cached credentials from the connection manager.
    %
    % Spcify the ID of the credentials to clear as reported by
    % getCredentials() method. If no credentials ID is specified all
    % credentials are cleared.

      switch nargin
        case 1
          cm.credentials = {};
        otherwise
          for id = ids
            cm.credentials(id) = [];
          end
      end
    end


    function conn = connect(cm, varargin)
    % CONNECT Uses provided credential to establish a database connection.
    %
    % CONNECT(hostname, database, username, password) Returns an object
    % implementing the java.sql.Connection interface handing a connection to
    % the specified database. Any of the parameter is optional. The user will
    % be queried for the missing information.
    %
    % The returned connection are added to a connections pool. When the number
    % of connections in the pool exceeds a configurable maximum, no more
    % connection are instantiated. Closed connections are automatically
    % removed from the pool.
    %
    % CONNECT(pl) Works as the above but the parameters are obtained from the
    % plist object PL. If the 'connection' parameter in the plist contains an
    % object implementing the java.sql.Connection interface, this object is
    % returned instead that opening a new connection. In this case the
    % connection in not added to the connection pool.

      import utils.const.*

      % save current credentials cache
      cache = cm.credentials;

      % count open connections in the pool
      count = cm.count();

      % check parameters
      if numel(varargin) == 1 && isa(varargin{1}, 'plist')

        % extract parameters from plist
        pl = varargin{1};

        % check if we have a connection parameter
        conn = find(pl, 'conn');
        if ~isempty(conn)
          % check that it implements java.sql.Connection interface
          if ~isa(conn, 'java.sql.Connection')
            error('### connection is not valid database connection');
          end
          % return this connection
          return;
        end

        % otherwise
        hostname = find(pl, 'hostname');
        database = find(pl, 'database');
        username = find(pl, 'username');
        password = find(pl, 'password');

        % if there is no hostname ignore other parameters
        if ~ischar(hostname) || isempty(hostname)
          varargin = {};
        % if there is no database ignore other parameters
        elseif ~ischar(database) || isempty(database)
          varargin = {hostname};
        % if there is no username ignore other parameters
        elseif ~ischar(username) || isempty(username)
          varargin = {hostname, database};
        % password can not be null but can be an empty string
        elseif ~ischar(password)
          varargin = {hostname, database, username};
        else
          varargin = {hostname, database, username, password};
        end
      end

      % check number of connections
      if count > cm.maxConnectionsNumber
        error('### too many open connections');
      end

      % connect
      try
        conn = cm.getConnection(varargin{:});

        % add connection to pool
        utils.helper.msg(msg.PROC1, 'add connection to pool');
        cm.connections{end+1} = conn;

      catch ex
        % restore our copy of the credentials cache
        utils.helper.msg(msg.PROC1, 'undo cache changes');
        cm.credentials = cache;

        % hide implementation details
        ex.throw();
      end
    end


    function close(cm, ids)
    % CLOSE Forces connections to be closed.
    %
    % In the case bugs in other routines working with database connections
    % produce orphan connections, this method can be used to force the close
    % of those connections.
    %
    % CLOSE(ids) Closes the connections with the corresponding IDs in the
    % connections pool. If no ID is given all connections in the pool are
    % closed.

      if nargin < 2
        ids = 1:numel(cm.connections);
      end
      cellfun(@close, cm.connections(ids));

      % remove closed connections from pool
      cm.count();
    end


    function add(cm, c)
    % ADD Adds credentials to the credentials cache.
    %
    % This method can be used to initialize or add to the cache, credentials
    % that will be used in subsequent connections attempts. This method accepts
    % only credentials in the form of utils.credentials objects.

      % check input arguments
      if nargin < 2 || ~isa(c, 'utils.credentials')
        error('### invalid call');
      end

      % add to the cache
      cm.cacheCredentials(c);
    end

  end % methods

  methods(Access=private)

    function conn = getConnection(cm, varargin)
    % GETCONNECTION Where the implementation of the connect method really is.

      import utils.const.*

      % handle variable number of arguments
      switch numel(varargin)
        case 0
          % find credentials
          [hostname, database, username] = cm.selectDatabase([cm.credentials{:}]);
          conn = cm.getConnection(hostname, database, username);

        case 1
          % find credentials
          cred = cm.findCredentials(varargin{:});
          if numel(cred) == 0
            cred = utils.credentials(varargin{:});
          end
          [hostname, database, username] = cm.selectDatabase(cred);
          conn = cm.getConnection(hostname, database, username);

        case 2
          % find credentials
          cred = cm.findCredentials(varargin{:});
          switch numel(cred)
            case 0
              conn = cm.getConnection(varargin{1}, varargin{2}, []);
            case 1
              conn = cm.getConnection(cred.hostname, cred.database, cred.username);
            otherwise
              [hostname, database, username] = cm.selectDatabase(cred);
              conn = cm.getConnection(hostname, database, username);
          end

        case 3
          % find credentials
          cred = cm.findCredentials(varargin{1}, varargin{2}, varargin{3});
          if numel(cred) == 0
            % no credentials found
            usernames = { varargin{3} };
            if isempty(varargin{3})
              % use usernames for same hostname
              tmp = cm.findCredentials(varargin{1});
              if ~isempty(tmp)
                usernames = { tmp(:).username };
              end
            end
            % build credentials objects
            tmp = {};
            for kk = 1:numel(usernames)
              tmp{kk} = utils.credentials(varargin{1}, varargin{2}, usernames{kk});
            end
            % convert from cell array to array
            cred = [tmp{:}];
          else
            % credentials in cache
            utils.helper.msg(msg.PROC1, 'use cached credentials');
          end

          cache = true;
          if (numel(cred) > 1) || ~cred.complete
            % ask for password
            [username, password, cache] = cm.inputCredentials(cred, cm.userMessage);

            % cache credentials
            cred = utils.credentials(varargin{1}, varargin{2}, username);
            cm.cacheCredentials(cred);

            % add password to credentials
            cred.password = password;
          end

          % try to connect
          try
            conn = utils.mysql.connect(cred.hostname, cred.database, cred.username, cred.password);
          catch ex
            % look for access denied errors
            if strcmp(ex.identifier, 'utils:mysql:connect:AccessDenied')
              % ask for new new credentials
              utils.helper.msg(msg.IMPORTANT, ex.message);
              cm.userMessage = 'Authentication error!';
              conn = cm.getConnection(varargin{1}, varargin{2}, varargin{3});
            else
              % error out
              throw(ex);
            end
          end

          % cache password
          if cache
            utils.helper.msg(msg.PROC1, 'cache password');
            cm.cacheCredentials(cred);
          end

        case 4
          
          if isempty(varargin{4})
            conn = cm.getConnection(varargin{1}, varargin{2}, varargin{3});
          else
            % connect
            conn = utils.mysql.connect(varargin{1}, varargin{2}, varargin{3}, varargin{4});
            
            if cm.cachePassword == 1
              % cache credentials with password
              cred = utils.credentials(varargin{1}, varargin{2}, varargin{3}, varargin{4});
            else
              % cache credentials without password
              cred = utils.credentials(varargin{1}, varargin{2}, varargin{3});
            end
            cm.cacheCredentials(cred);
          end
        otherwise
          error('### invalid call')
      end

    end


    function ids = findCredentialsId(cm, varargin)
    % FINDCREDENTIALSID Find credentials in the cache and returns their IDs.

      import utils.const.*
      ids = [];

      for kk = 1:numel(cm.credentials)
        % invalidate expired passwords
        if expired(cm.credentials{kk})
          utils.helper.msg(msg.PROC1, 'cache entry id=%d expired', kk);
          cm.credentials{kk}.password = [];
          cm.credentials{kk}.expiry = 0;
        end

        % match input with cache
        if match(cm.credentials{kk}, varargin{:})
          ids = [ ids kk ];
        end
      end
    end


    function cred = findCredentials(cm, varargin)
    % FINDCREDENTIALS Find credentials in the cache and returns them in a list.

      % default
      cred = [];

      % search
      ids = findCredentialsId(cm, varargin{:});

      % return a credentials objects array
      if ~isempty(ids)
        cred = [cm.credentials{ids}];
      end
    end


    function cacheCredentials(cm, c)
    % CACHECREDENTIALS Adds to or updates the credentials cache.

      import utils.const.*

      % find entry to update
      ids = findCredentialsId(cm, c.hostname, c.database, c.username);

      % set password expiry time
      if ischar(c.password)
        c.expiry = double(time()) + cm.credentialsExpiry;
      end

      if isempty(ids)
        % add at the end
        utils.helper.msg(msg.PROC1, 'add cache entry %s', char(c));
        cm.credentials{end+1} = c;
      else
        for id = ids
          % update only if the cached informations are less than the one we have
          if length(c) > length(cm.credentials{id})
            utils.helper.msg(msg.PROC1, 'update cache entry id=%d %s', id, char(c));
            cm.credentials{id} = c;
          else
            % always update expiry time
            if c.expiry
              cm.credentials{id}.expiry = c.expiry;
            end
          end
        end
      end
    end


    function [username, password, cache] = inputCredentials(cm, cred, msg)
    % INPUTCREDENTIALS Queries the user for database username and password.

      % msg is an optional argument
      if nargin < 3
        msg = [];
      end

      % build a cell array of usernames
      users = {};
      for id = 1:numel(cred)
        if ~isempty(cred(id).username)
          users = [ users { cred(id).username } ];
        end
      end
      users = sort(unique(users));

      parent = com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame;
      dialog = javaObjectEDT('connectionmanager.CredentialsDialog', ...
          parent, cred(1).hostname, cred(1).database, users, cm.cachePassword, msg);
      dialog.show();
      if dialog.cancelled
        throw(MException('utils:mysql:connect:UserCancelled', '### user cancelled'));
      end
      username = char(dialog.username);
      password = char(dialog.password);
      cache    = logical(dialog.cache);
    end


    function [hostname, database, username] = selectDatabase(cm, credentials)
    % SELECTDATABASE Makes the user choose to which database connect to.

      parent = com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame;
      dialog = javaObjectEDT('connectionmanager.DatabaseSelectorDialog', parent);
      for c = credentials
        dialog.add(c.hostname, c.database, c.username);
      end
      dialog.show();
      if dialog.cancelled
        throw(MException('utils:mysql:connect:UserCancelled', '### user cancelled'));
      end
      hostname = char(dialog.hostname);
      database = char(dialog.database);
      username = char(dialog.username);
      if isempty(username)
        username = [];
      end
    end

  end % private methods

end % classdef
