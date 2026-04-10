function ltpda_ssh_setup(varargin)
% LTPDA_SSH_SETUP  Configure automatic SSH tunnel for LTPDA repository connections.
%
% The automatic SSH tunnel lets MATLAB connect to the LTPDA repository without
% PuTTY or any other external SSH tool, on both Windows and Mac.
%
% USAGE:
%
%   ltpda_ssh_setup status                             % print current settings
%   ltpda_ssh_setup enable                             % enable auto-tunnel
%   ltpda_ssh_setup disable                            % disable auto-tunnel
%   ltpda_ssh_setup('server',     'repo.example.com')  % set server hostname
%   ltpda_ssh_setup('port',       2222)                % SSH gateway port (default 2222)
%   ltpda_ssh_setup('local_port', 13306)               % local JDBC port (default 13306)
%
% Multiple key-value pairs can be combined:
%
%   ltpda_ssh_setup('server', 'repo.example.com', 'port', 2222)
%   ltpda_ssh_setup enable
%
% AFTER SETUP:
%
%   In LTPDAprefs set:  Hostname = localhost,  Port = <local_port>  (default 13306)
%   Then run ltpda_tunnel to establish the tunnel.
%
% See also: ltpda_tunnel, utils.ssh

  GROUP = 'LTPDA_SSH';

  % Handle single-word commands
  if nargin == 1 && ischar(varargin{1})
    switch lower(varargin{1})
      case 'enable'
        setpref(GROUP, 'enabled', true);
        fprintf('SSH tunnel enabled. Run ltpda_tunnel to connect.\n');
        printSettings(GROUP);
        return;
      case 'disable'
        setpref(GROUP, 'enabled', false);
        fprintf('SSH tunnel disabled.\n');
        return;
      case 'status'
        printSettings(GROUP);
        return;
    end
  end

  % Handle key-value pairs
  if mod(numel(varargin), 2) ~= 0
    error('LTPDA:ssh:setup', ...
      'Arguments must be key-value pairs or a single command (enable/disable/status).');
  end

  for kk = 1:2:numel(varargin)
    key = lower(varargin{kk});
    val = varargin{kk+1};
    switch key
      case 'server'
        if ~ischar(val) || isempty(val)
          error('LTPDA:ssh:setup', 'server must be a non-empty string.');
        end
        setpref(GROUP, 'server', val);
        fprintf('SSH tunnel server set to: %s\n', val);
      case 'port'
        setpref(GROUP, 'port', double(val));
        fprintf('SSH gateway port set to: %d\n', double(val));
      case 'local_port'
        setpref(GROUP, 'local_port', double(val));
        fprintf('SSH local port set to: %d\n', double(val));
      case 'remote_host'
        if ~ischar(val) || isempty(val)
          error('LTPDA:ssh:setup', 'remote_host must be a non-empty string.');
        end
        setpref(GROUP, 'remote_host', val);
        fprintf('SSH remote MySQL host set to: %s\n', val);
      case 'mysql_port'
        setpref(GROUP, 'mysql_port', double(val));
        fprintf('MySQL port set to: %d\n', double(val));
      otherwise
        error('LTPDA:ssh:setup', ...
          'Unknown setting: ''%s''. Valid keys: server, port, local_port.', key);
    end
  end

end


function printSettings(GROUP)
  enabled    = getpref(GROUP, 'enabled',     false);
  server     = getpref(GROUP, 'server',      '(not set)');
  port       = getpref(GROUP, 'port',        2222);
  localPort  = getpref(GROUP, 'local_port',  13306);
  remoteHost = getpref(GROUP, 'remote_host', 'db');
  mysqlPort  = getpref(GROUP, 'mysql_port',  3306);

  if enabled, enStr = 'yes'; else, enStr = 'no'; end

  fprintf('\nLTPDA SSH tunnel configuration:\n');
  fprintf('  Enabled:      %s\n', enStr);
  fprintf('  Server:       %s\n', server);
  fprintf('  SSH port:     %d\n', port);
  fprintf('  Local port:   %d\n', localPort);
  fprintf('  Remote host:  %s\n', remoteHost);
  fprintf('  MySQL port:   %d\n', mysqlPort);
  fprintf('\nIn LTPDAprefs, set: Hostname=localhost, Port=%d\n', localPort);

  if ~strcmp(server, '(not set)')
    if utils.ssh.isActive(server)
      fprintf('  Tunnel status: connected\n');
    else
      fprintf('  Tunnel status: not connected (run ltpda_tunnel)\n');
    end
  end
  fprintf('\n');
end
