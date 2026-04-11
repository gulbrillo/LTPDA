function ltpda_tunnel(varargin)
% LTPDA_TUNNEL  Establish, reconnect, close, or check the LTPDA repository SSH tunnel.
%
% This command starts (or reconnects) the SSH tunnel that MATLAB needs to reach
% the repository MySQL database. Run it after ltpda_startup, or any time the
% tunnel drops (e.g. after a network interruption).
%
% USAGE:
%
%   ltpda_tunnel              % reconnect using stored credentials; no prompt
%   ltpda_tunnel close        % disconnect the active tunnel
%   ltpda_tunnel(u, pw)       % connect/reconnect with explicit credentials
%
% If the tunnel is already active, this command prints the current status.
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

  % ── Handle 'close' command ────────────────────────────────────────────────
  if nargin == 1 && ischar(varargin{1}) && strcmpi(varargin{1}, 'close')
    if ~ispref(GROUP, 'server')
      fprintf('SSH tunnel: not configured.\n');
      return;
    end
    server = getpref(GROUP, 'server');
    if utils.ssh.isActive(server)
      utils.ssh.closeTunnel(server);
      fprintf('SSH tunnel to %s closed.\n', server);
    else
      fprintf('SSH tunnel to %s is not active.\n', server);
    end
    return;
  end

  % ── Decode username / password from varargin ──────────────────────────────
  username = '';  password = '';
  if nargin >= 1, username = varargin{1}; end
  if nargin >= 2, password = varargin{2}; end

  % ── Read settings ─────────────────────────────────────────────────────────
  if ~ispref(GROUP, 'server')
    error('LTPDA:ssh:notConfigured', ...
      'SSH tunnel server is not configured.\nRun: ltpda_ssh_setup(''server'', ''repo.yourdomain.com'')');
  end

  server     = getpref(GROUP, 'server');
  sshPort    = getpref(GROUP, 'port',        2222);
  localPort  = getpref(GROUP, 'local_port',  13306);
  remoteHost = getpref(GROUP, 'remote_host', 'db');
  mysqlPort  = getpref(GROUP, 'mysql_port',  3306);

  % ── If tunnel is already active, check it matches current settings ────────
  if utils.ssh.isActive(server)
    state = utils.ssh.getState(server);
    if ~isempty(state) && state.localPort ~= localPort
      fprintf('Active tunnel uses port %d, but current settings specify port %d.\n', ...
        state.localPort, localPort);
      fprintf('Run: ltpda_tunnel close\n  then: ltpda_tunnel\nto reconnect on port %d.\n', localPort);
    else
      fprintf('SSH tunnel to %s is active (localhost:%d → %s:%d).\n', ...
        server, localPort, remoteHost, mysqlPort);
    end
    return;
  end

  % ── Try silent reconnect with stored credentials ──────────────────────────
  if nargin == 0
    if utils.ssh.reconnectIfNeeded(server)
      fprintf('SSH tunnel reconnected: localhost:%d → %s:%d → %s:%d\n', ...
        localPort, server, sshPort, remoteHost, mysqlPort);
      return;
    end
  end

  % ── Need credentials — use supplied ones or prompt ────────────────────────
  if isempty(password)
    answer = sshCredentialsDialog(server);
    if isempty(answer)
      fprintf('SSH tunnel: cancelled.\n');
      return;
    end
    username = answer{1};
    password = answer{2};
  end

  % ── Establish tunnel ──────────────────────────────────────────────────────
  fprintf('Connecting SSH tunnel to %s:%d ...\n', server, sshPort);
  try
    utils.ssh.ensureTunnel(server, sshPort, localPort, username, password, remoteHost, mysqlPort);
  catch ex
    switch ex.identifier
      case 'LTPDA:ssh:disconnected'
        fprintf('%s\n', ex.message);
      case 'LTPDA:ssh:portBusy'
        fprintf('Port conflict: local port %d is already in use.\n', localPort);
        fprintf('Pick a free port and reconfigure:\n');
        fprintf('  ltpda_ssh_setup(''local_port'', 13307)\n');
        fprintf('Then update LTPDAprefs: Port = 13307\n');
      case 'LTPDA:ssh:timeout'
        fprintf('%s\n', ex.message);
      case 'LTPDA:ssh:authFailed'
        fprintf('%s\n', ex.message);
      otherwise
        fprintf('SSH tunnel error: %s\n', ex.message);
    end
    return;
  end
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
  fig.UserData = struct('raw', '');          % holds raw password between events
  pField.ValueChangingFcn = @(~, evt) trackPassword(evt, fig, pField);

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
    answer = {uField.Value, fig.UserData.raw};
  end
  delete(fig);
end


function setOkAndResume(fig)
  fig.Tag = 'ok';   % flag that Connect was pressed (Tag starts as '')
  uiresume(fig);
end


function trackPassword(evt, fig, pField)
% TRACKPASSWORD  Track raw password on each keystroke; replace with bullets after event.
%
% ValueChangingFcn fires on each keystroke but prohibits synchronous Value writes.
% A 0-delay timer fires at the next event-loop iteration (after the event is processed),
% at which point it is safe to replace the visible text with bullet characters.
  state    = fig.UserData;
  newVal   = evt.Value;
  nBullets = sum(double(newVal) == 8226);
  raw      = state.raw;
  if numel(newVal) > nBullets
    raw = [raw, newVal(nBullets+1:end)];
  elseif numel(newVal) < numel(raw)
    raw = raw(1:numel(newVal));
  end
  state.raw    = raw;
  fig.UserData = state;
  n = numel(raw);
  t = timer('ExecutionMode', 'singleShot', 'StartDelay', 0, ...
            'TimerFcn', @(t,~) maskField(t, pField, n));
  start(t);
end


function maskField(t, pField, n)
% MASKFIELD  Replace field text with n bullet characters; clean up timer.
  stop(t); delete(t);
  if isvalid(pField)
    pField.Value = repmat(char(8226), 1, n);
  end
end
