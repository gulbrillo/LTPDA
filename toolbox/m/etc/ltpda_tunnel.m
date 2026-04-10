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

  server     = getpref(GROUP, 'server');
  sshPort    = getpref(GROUP, 'port',        2222);
  localPort  = getpref(GROUP, 'local_port',  13306);
  remoteHost = getpref(GROUP, 'remote_host', 'db');
  mysqlPort  = getpref(GROUP, 'mysql_port',  3306);

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
    answer = sshCredentialsDialog(server);
    if isempty(answer)
      fprintf('SSH tunnel: cancelled.\n');
      return;
    end
    username = answer{1};
    password = answer{2};
  end

  % Establish tunnel
  fprintf('Connecting SSH tunnel to %s:%d ...\n', server, sshPort);
  utils.ssh.ensureTunnel(server, sshPort, localPort, username, password, remoteHost, mysqlPort);
  fprintf('SSH tunnel established: localhost:%d → %s:%d → %s:%d\n', ...
    localPort, server, sshPort, remoteHost, mysqlPort);
  fprintf('In LTPDAprefs: Hostname=localhost, Port=%d\n', localPort);

end


function answer = sshCredentialsDialog(server)
% SSHCREDENTIALSDIALOG  Modal uifigure dialog for SSH username/password.
%   Always rendered with the light theme so it looks correct in Windows dark mode.
%   Returns {username, password} or {} if cancelled.
%
%   Uses uiwait/uiresume so that typing in the fields does not accidentally
%   unblock the wait loop (a known pitfall with waitfor + UserData).

  answer = {};

  fig = uifigure('Name',    sprintf('LTPDA SSH tunnel — %s', server), ...
                 'Position', [0 0 340 168], ...
                 'Resize',   'off', ...
                 'WindowStyle', 'modal');
  try                                % R2025a+; silently ignored on older versions
    set(fig, 'Theme', 'light');
  catch
  end
  movegui(fig, 'center');

  % ── Labels ───────────────────────────────────────────────────────────────
  uilabel(fig, 'Text', 'Username', 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'right', 'Position', [14 110 80 22]);
  uilabel(fig, 'Text', 'Password', 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'right', 'Position', [14 76 80 22]);

  % ── Fields ───────────────────────────────────────────────────────────────
  uField = uieditfield(fig, 'text', 'Position', [102 110 220 22]);

  pField = uieditfield(fig, 'text', 'Position', [102 76  220 22]);
  fig.UserData = '';                                 % stores raw password
  pField.ValueChangedFcn = @(src,~) maskPassword(src, fig);

  % ── Buttons ──────────────────────────────────────────────────────────────
  uibutton(fig, 'Text', 'Cancel', ...
    'Position', [102 30 100 28], ...
    'ButtonPushedFcn', @(~,~) uiresume(fig));

  uibutton(fig, 'Text', 'Connect', 'FontWeight', 'bold', ...
    'Position', [212 30 110 28], ...
    'ButtonPushedFcn', @(~,~) setOkAndResume(fig));

  fig.CloseRequestFcn = @(~,~) uiresume(fig);

  focus(uField);
  uiwait(fig);   % blocks until uiresume() is called by any button or window close

  if ~isvalid(fig)
    return;
  end

  % 'Connect' stores the username in Tag before resuming; Cancel leaves it empty.
  if ~isempty(fig.Tag)
    answer = {uField.Value, fig.UserData};
  end
  delete(fig);
end


function setOkAndResume(fig)
  fig.Tag = 'ok';   % flag that Connect was pressed (Tag starts as '')
  uiresume(fig);
end


function maskPassword(src, fig)
  % Replace displayed text with bullets; keep raw password in fig.UserData (string).
  raw      = fig.UserData;           % plain string stored in UserData
  val      = src.Value;
  nBullets = sum(double(val) == 8226);
  if numel(val) > nBullets
    % Characters typed after the existing bullets
    raw = [raw, val(nBullets+1:end)];
  elseif numel(val) < numel(raw)
    raw = raw(1:numel(val));
  end
  fig.UserData = raw;
  src.Value = repmat(char(8226), 1, numel(raw));
end
