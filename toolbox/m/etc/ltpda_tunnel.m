function ltpda_tunnel(username, password)
% LTPDA_TUNNEL  Establish, reconnect or check the LTPDA repository SSH tunnel.
%
% This command starts (or reconnects) the SSH tunnel that MATLAB needs to reach
% the repository MySQL database. Run it after ltpda_startup, or any time the
% tunnel drops (e.g. after a network interruption).
%
% USAGE:
%
%   ltpda_tunnel              % reconnect using stored credentials; no prompt
%   ltpda_tunnel(u, pw)       % connect/reconnect with explicit credentials
%
% If the tunnel is already active, this command does nothing and prints the
% current status.
%
% If called with no arguments and credentials are stored in memory from a
% previous connection, the tunnel is re-established silently without prompting.
%
% If no credentials are available, a login dialog is shown.
%
% CONFIGURE TUNNEL SETTINGS:
%
%   ltpda_ssh_setup('server', 'repo.yourdomain.com')
%   ltpda_ssh_setup enable
%
% See also: ltpda_ssh_setup, utils.ssh

  GROUP = 'LTPDA_SSH';

  % Read settings
  if ~ispref(GROUP, 'server')
    error('LTPDA:ssh:notConfigured', ...
      'SSH tunnel server is not configured.\nRun: ltpda_ssh_setup(''server'', ''repo.yourdomain.com'')');
  end

  server    = getpref(GROUP, 'server');
  sshPort   = getpref(GROUP, 'port',       2222);
  localPort = getpref(GROUP, 'local_port', 13306);

  % If tunnel is already active, just report and return
  if utils.ssh.isActive(server)
    fprintf('SSH tunnel to %s is active (localhost:%d → db:3306).\n', server, localPort);
    return;
  end

  % Try silent reconnect with stored credentials
  if nargin == 0
    if utils.ssh.reconnectIfNeeded(server)
      fprintf('SSH tunnel reconnected: localhost:%d → %s:2222 → db:3306\n', localPort, server);
      return;
    end
  end

  % Need credentials — use supplied ones or prompt
  if nargin < 2
    answer = inputdlg({'Username', 'Password'}, ...
      sprintf('LTPDA SSH tunnel - %s', server), ...
      [1 50], {'', ''});
    if isempty(answer) || isempty(answer{1})
      fprintf('SSH tunnel: cancelled.\n');
      return;
    end
    username = answer{1};
    password = answer{2};
  end

  % Establish tunnel
  fprintf('Connecting SSH tunnel to %s:%d ...\n', server, sshPort);
  utils.ssh.ensureTunnel(server, sshPort, localPort, username, password);
  fprintf('SSH tunnel established: localhost:%d → %s:%d → db:3306\n', ...
    localPort, server, sshPort);
  fprintf('In LTPDAprefs: Hostname=localhost, Port=%d\n', localPort);

end
