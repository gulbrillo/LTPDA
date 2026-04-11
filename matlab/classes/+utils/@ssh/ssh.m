% UTILS.SSH  SSH tunnel management for LTPDA repository connections.
%
% This class is used as a namespace for static methods only — never instantiated.
% It manages JSch (Java Secure Channel) SSH tunnels that forward a local TCP port
% to the MySQL container inside the Docker stack, enabling MATLAB to connect to
% the LTPDA repository without PuTTY or any other external SSH client.
%
% The tunnel is stored in MATLAB's appdata (root handle 0) so it persists for
% the duration of the MATLAB session. Credentials are held in memory only and
% are never written to disk.
%
% Authentication uses com.ltpda.ssh.LTPDAUserInfo (bundled in ltpda-ssh.jar),
% a compiled Java class implementing both UserInfo and UIKeyboardInteractive.
% This supports plain password auth and keyboard-interactive MFA (e.g. Duo Push).
%
% TYPICAL USE (via ltpda_tunnel / ltpda_ssh_setup):
%
%   ltpda_ssh_setup('server', 'repo.yourdomain.com')
%   ltpda_ssh_setup enable
%   ltpda_tunnel          % establish tunnel, prompted for credentials
%
%   % If tunnel drops mid-session:
%   ltpda_tunnel          % reconnects silently using stored credentials
%
% DIRECT USE:
%
%   utils.ssh.ensureTunnel('repo.example.com', 2222, 13306, 'alice', 'secret')
%   utils.ssh.isActive('repo.example.com')   % → true
%   utils.ssh.closeAllTunnels()

classdef ssh

  methods(Static)

    function ensureTunnel(sshHost, sshPort, localPort, username, password, remoteHost, mysqlPort)
    % ENSURETUNNEL  Establish an SSH port-forwarding tunnel (or reuse existing).
    %
    %   utils.ssh.ensureTunnel(sshHost, sshPort, localPort, username, password)
    %   utils.ssh.ensureTunnel(sshHost, sshPort, localPort, username, password, remoteHost)
    %   utils.ssh.ensureTunnel(sshHost, sshPort, localPort, username, password, remoteHost, mysqlPort)
    %
    %   sshHost    — hostname of the SSH gateway (e.g. 'repo.yourdomain.com')
    %   sshPort    — SSH port on the server (typically 2222 for LTPDA gateway)
    %   localPort  — local TCP port to listen on (e.g. 13306)
    %   username   — SSH/MySQL username
    %   password   — SSH/MySQL password (same credentials as for MySQL/MATLAB)
    %   remoteHost — Docker network alias of the MySQL container (default: 'db')
    %   mysqlPort  — MySQL port on the remote host (default: 3306)
    %
    %   The tunnel forwards:
    %     127.0.0.1:localPort  →  remoteHost:mysqlPort  (via sshHost:sshPort)
    %
    %   Authentication uses the user's MySQL/MATLAB password — no separate SSH
    %   credentials are needed when using the LTPDA SSH gateway container.
    %
    %   Authentication is delegated to utils.DuoHandler, which handles both plain
    %   password and keyboard-interactive MFA (Duo Push). StrictHostKeyChecking is
    %   set to 'ask': known_hosts entries are verified; unknown hosts are auto-accepted
    %   because the server was explicitly configured by the user.

      if nargin < 6 || isempty(remoteHost)
        remoteHost = getpref('LTPDA_SSH', 'remote_host', 'db');
      end
      if nargin < 7 || isempty(mysqlPort)
        mysqlPort = getpref('LTPDA_SSH', 'mysql_port', 3306);
      end

      key   = utils.ssh.tunnelKey(sshHost);
      state = getappdata(0, key);

      % Reuse existing tunnel if still connected
      if ~isempty(state) && ~isempty(state.session) && state.session.isConnected()
        return;
      end

      % Establish new JSch session
      try
        jsch = com.jcraft.jsch.JSch();

        % Load known_hosts for fingerprint verification if the file exists
        homeDir        = char(java.lang.System.getProperty('user.home'));
        knownHostsFile = fullfile(homeDir, '.ssh', 'known_hosts');
        if exist(knownHostsFile, 'file')
          jsch.setKnownHosts(knownHostsFile);
        end

        session = jsch.getSession(username, sshHost, sshPort);

        % LTPDAUserInfo handles plain-password and keyboard-interactive MFA (Duo Push)
        session.setUserInfo(com.ltpda.ssh.LTPDAUserInfo(password));

        props = java.util.Properties();
        % StrictHostKeyChecking=ask: verifies fingerprint when known_hosts has an entry;
        % prompts (via DuoHandler.promptYesNo) for unknown hosts. The user explicitly
        % configured this server in ltpda_ssh_setup, so auto-accept is acceptable.
        props.put('StrictHostKeyChecking', 'ask');
        % Modern SHA-2 host-key algorithms — required when the server has disabled SHA-1
        props.put('server_host_key',         'rsa-sha2-256,rsa-sha2-512,ssh-rsa,ecdsa-sha2-nistp256,ssh-ed25519');
        props.put('PubkeyAcceptedAlgorithms', 'rsa-sha2-256,rsa-sha2-512,ssh-rsa,ecdsa-sha2-nistp256,ssh-ed25519');
        % Allow keyboard-interactive first (needed for Duo); fall back to password
        props.put('PreferredAuthentications', 'keyboard-interactive,password,publickey');
        session.setConfig(props);

        fprintf('Connecting to %s:%d ...  (if MFA is enabled, approve the Duo Push on your phone)\n', sshHost, sshPort);
        session.connect(30000);  % 30 s timeout — extra time for Duo Push approval
      catch ex
        % SSH_MSG_DISCONNECT carries a human-readable reason from the server —
        % extract and surface it directly (e.g. "Too many authentication failures",
        % "User not allowed", custom banners, etc.)
        tok = regexp(ex.message, 'SSH_MSG_DISCONNECT:\s*\d+\s+(.+?)(?:\s*$|\n)', 'tokens', 'once');
        if ~isempty(tok)
          error('LTPDA:ssh:disconnected', ...
            'Server %s disconnected: %s', sshHost, strtrim(tok{1}));
        end
        if contains(ex.message, 'Auth fail') || contains(ex.message, 'Authentication failed')
          error('LTPDA:ssh:authFailed', ...
            'SSH authentication failed for %s@%s.\nCheck your username and password. For MFA servers: did you approve the Duo Push?', ...
            username, sshHost);
        end
        if contains(ex.message, 'timed out') || contains(ex.message, 'ConnectException') || contains(ex.message, 'Connection refused')
          error('LTPDA:ssh:timeout', ...
            'Connection to %s:%d timed out.\nCheck that the server is reachable and that you are on the correct network (VPN may be required).', ...
            sshHost, sshPort);
        end
        error('LTPDA:ssh:connect', ...
          'SSH connection to %s:%d failed: %s\n\nCheck the server address, port, and credentials.', ...
          sshHost, sshPort, ex.message);
      end

      % Set up local port forwarding: localhost:localPort -> remoteHost:mysqlPort
      try
        session.setPortForwardingL(localPort, remoteHost, mysqlPort);
      catch ex
        session.disconnect();
        if contains(ex.message, 'Address already in use') || contains(ex.message, 'bind')
          error('LTPDA:ssh:portBusy', ...
            'Local port %d is already in use.\nRun: ltpda_ssh_setup(''local_port'', 13307)', ...
            localPort);
        end
        error('LTPDA:ssh:portForward', ...
          'Port forwarding setup failed: %s', ex.message);
      end

      % Store session and credentials in appdata (memory only — never written to disk)
      state = struct( ...
        'session',    session, ...
        'localPort',  localPort, ...
        'host',       sshHost, ...
        'remoteHost', remoteHost, ...
        'mysqlPort',  mysqlPort, ...
        'username',   username, ...
        'password',   password);
      setappdata(0, key, state);
    end


    function tf = reconnectIfNeeded(sshHost)
    % RECONNECTIFNEEDED  Silently reconnect a dropped tunnel using stored credentials.
    %
    %   tf = utils.ssh.reconnectIfNeeded(sshHost)
    %
    %   Returns true if tunnel is active (was active or was reconnected).
    %   Returns false if no stored credentials exist (caller must prompt user).

      tf = false;
      key = utils.ssh.tunnelKey(sshHost);
      state = getappdata(0, key);

      if isempty(state)
        return;  % no stored state — caller must provide credentials
      end

      if state.session.isConnected()
        tf = true;
        return;
      end

      % Session dropped — reconnect silently using stored credentials
      try
        if isfield(state, 'remoteHost')
          rh = state.remoteHost;
        else
          rh = getpref('LTPDA_SSH', 'remote_host', 'db');
        end
        if isfield(state, 'mysqlPort')
          mp = state.mysqlPort;
        else
          mp = getpref('LTPDA_SSH', 'mysql_port', 3306);
        end
        utils.ssh.ensureTunnel(state.host, ...
          getpref('LTPDA_SSH', 'port', 2222), ...
          state.localPort, ...
          state.username, ...
          state.password, ...
          rh, mp);
        tf = true;
      catch
        tf = false;
      end
    end


    function state = getState(sshHost)
    % GETSTATE  Return stored tunnel state struct for sshHost, or [] if none.
    %
    %   state = utils.ssh.getState('repo.example.com')
    %
    %   Returned struct fields: session, localPort, host, remoteHost, mysqlPort,
    %   username, password (credentials in memory only — never written to disk).

      state = getappdata(0, utils.ssh.tunnelKey(sshHost));
    end


    function tf = isActive(sshHost)
    % ISACTIVE  Returns true if there is an active tunnel to the given host.
    %
    %   tf = utils.ssh.isActive('repo.example.com')

      key = utils.ssh.tunnelKey(sshHost);
      state = getappdata(0, key);
      tf = ~isempty(state) && ~isempty(state.session) && state.session.isConnected();
    end


    function closeTunnel(sshHost)
    % CLOSETUNNEL  Disconnect the tunnel to the specified host.
    %
    %   utils.ssh.closeTunnel('repo.example.com')

      key = utils.ssh.tunnelKey(sshHost);
      state = getappdata(0, key);
      if ~isempty(state) && ~isempty(state.session)
        try
          state.session.disconnect();
        catch
        end
      end
      rmappdata(0, key);
    end


    function closeAllTunnels()
    % CLOSEALLTUNNELS  Disconnect all active LTPDA SSH tunnels.
    %
    %   utils.ssh.closeAllTunnels()

      % Find all LTPDA tunnel keys in appdata
      allKeys = fieldnames(getappdata(0));
      for kk = 1:numel(allKeys)
        if startsWith(allKeys{kk}, 'ltpda_ssh_')
          state = getappdata(0, allKeys{kk});
          if ~isempty(state) && ~isempty(state.session)
            try
              state.session.disconnect();
            catch
            end
          end
          rmappdata(0, allKeys{kk});
        end
      end
    end


    function printStatus()
    % PRINTSTATUS  Print status of all active LTPDA SSH tunnels.

      allKeys = fieldnames(getappdata(0));
      found = false;
      for kk = 1:numel(allKeys)
        if startsWith(allKeys{kk}, 'ltpda_ssh_')
          state = getappdata(0, allKeys{kk});
          if ~isempty(state)
            active = ~isempty(state.session) && state.session.isConnected();
            fprintf('  SSH tunnel: %s → localhost:%d  [%s]\n', ...
              state.host, state.localPort, ...
              utils.ssh.statusStr(active));
            found = true;
          end
        end
      end
      if ~found
        fprintf('  No active SSH tunnels.\n');
      end
    end

  end % public static methods


  methods(Static, Access=private)

    function key = tunnelKey(sshHost)
      key = ['ltpda_ssh_' matlab.lang.makeValidName(sshHost)];
    end

    function s = statusStr(active)
      if active
        s = 'connected';
      else
        s = 'disconnected';
      end
    end

  end % private static methods

end
