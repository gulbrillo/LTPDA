classdef credentials

  properties

    hostname = [];
    database = [];
    username = [];
    password = [];
    expiry = 0;

  end % properties

  methods

    function obj = credentials(hostname, database, username, password)
    % CREDENTIALS Constructor for credentials objects.
    %
    % Those are simple container objects to hold credentials required for
    % establishing a connection to a database server, in addition to an
    % expiry time.
    %
    % CREDENTIALS(hostname, database, username, password) The constructor can
    % be called with any number of arguments. The default value for the object
    % properties is the empty vector.

      switch nargin
        case 1
          obj.hostname = hostname;
        case 2
          obj.hostname = hostname;
          obj.database = database;
        case 3
          obj.hostname = hostname;
          obj.database = database;
          obj.username = username;
        case 4
          obj.hostname = hostname;
          obj.database = database;
          obj.username = username;
          obj.password = password;
      end
    end

    function str = char(obj, mode)
    % CHAR Convert a credentials object to string representation.
    %
    % It takes an optional second argument that defines the representation to
    % use. The default is to replace the password, if present, with the YES
    % string, other possible modes are SHORT where password is omitted, or FULL
    % where the password is shown at it is.

      if nargin < 2
        mode = '';
      end
      
      % compute expiry time
      now = double(time());
      expiry = '';
      if obj.expiry
        expiry = sprintf('expiry=%d', round(obj.expiry - now));
      end
      
      switch mode
        case 'short'
          % do not show password
          frm = 'mysql://%s/%s username=%s';
          str = sprintf(frm, obj.hostname, obj.database, obj.username);
        case 'full'
          % show password
          frm = 'mysql://%s/%s username=%s password=%s %s';
          str = sprintf(frm, obj.hostname, obj.database, obj.username, obj.password, expiry);
        otherwise
          % by default only show if a password is known
          passwd = [];
          if ischar(obj.password)
            passwd = 'YES';
          end
          frm = 'mysql://%s/%s username=%s password=%s %s';
          str = sprintf(frm, obj.hostname, obj.database, obj.username, passwd, expiry);
      end
    end

    function disp(objs)
    % DISP Overloaded display method for credentials objects.
    %
    % Uses the default string representation of the char() method where the
    % password, if present, is replaced with the string YES.

      for obj = objs
        disp(['    ' char(obj) char(10)]);
      end
    end

    function len = length(obj)
    % LENGTH Returns the number of not null fields in the object.

      len = 0;
      if ~isempty(obj.hostname)
        len = len + 1;
      end
      if ~isempty(obj.database)
        len = len + 1;
      end
      if ~isempty(obj.username)
        len = len + 1;
      end
      if ~isempty(obj.password)
        len = len + 1;
      end
    end

    function rv = complete(obj)
    % COMPLETE Checks if the credentials are complete.
    %
    % Credentials object are complete when they contains all the required
    % information to connect to a database. Namely the HOSTNAME, DATABASE
    % and USERNAME properties should not be empty, the PASSWORD property is
    % allowed to be an empty string '' but not [].

      info = {'hostname', 'database', 'username'};
      for kk = 1:numel(info)
        if isempty(obj.(info{kk}))
          rv = false;
          return;
        end
      end
      if ~ischar(obj.password)
        rv = false;
        return;
      end
      rv = true;
    end

    function rv = expired(obj)
    % EXPIRED Checks if the credentials are expired.
    %
    % Credential objects expire when their expiry time is smaller than the
    % current time in seconds since the epoch, as obtained by the time()
    % function. Credentials with zero or negative expiry time never expire.

      rv = false;
      if obj.expiry > 0 && double(time()) > obj.expiry
        rv = true;
      end
    end

    function rv = match(obj, hostname, database, username)
    % MATCH Check if the credentials object matches the given information.
    %
    % MATCH(obj, hostname) Returns true when HOSTANAME parameter match
    % the object properties.
    %
    % MATCH(obj, hostname, database) Returns true when HOSTANAME and
    % DATABASE parameters match the object properties.
    %
    % MATCH(obj, hostname, database, username) Returns true when
    % HOSTANAME, DATABASE, and USERNAME parameters match the object
    % properties.

      % default arguments
      switch nargin
        case 4
        case 3
          username = [];
        case 2
          username = [];
          database = [];
        otherwise
          error('### wrong number of parameters');
      end

      % default return value
      rv = true;

      if ~strcmp(obj.hostname, hostname)
        rv = false;
        return;
      end
      if ischar(database) && ~strcmp(obj.database, database)
        rv = false;
        return;
      end
      if ischar(username) && ~strcmp(obj.username, username)
        rv = false;
        return;
      end
    end

  end % methods

end