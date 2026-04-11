% LTPDAprefs is a graphical user interface for editing LTPDA preferences.
%
% CALL: LTPDAprefs
%       LTPDAprefs(h) % build the preference panel in the figure with handle, h.
%
%       LTPDAprefs(cat, property, value) % Set the temporary value of a property
%
% Category and property names are case sensitive.
%
% The properties that can be set are
%
%  Category    |    Property         | Description
% -------------------------------------------------------------------------
%  display     |  'verboseLevel'       | Set the level of terminal output from LTPDA
%              |                       | (see "help utils.const.msg" for
%              |                       | supported levels).
% -------------------------------------------------------------------------
%              |  'wrapstrings'        | Set the point where strings are wrapped in
%              |                       | some methods of LTPDA.
% -------------------------------------------------------------------------
%              |  'key action'         | Set the supported key action.
%              |                       | Possible values are:
%              |                       | 'NONE', 'WARNING', 'ERROR'
% -------------------------------------------------------------------------
%  plot        |  'axesFontSize'       | Set the font size for new plot axes
% -------------------------------------------------------------------------
%              |  'axesFontWeight'     | Set the font weight for new plot axes
% -------------------------------------------------------------------------
%              |  'axesLineWidth'      | Set the line width for new plot axes
% -------------------------------------------------------------------------
%              |  'gridStyle'          | Set the grid line style for new axes
% -------------------------------------------------------------------------
%              |  'minorGridStyle'     | Set the minor-grid line style for new axes
% -------------------------------------------------------------------------
%              |  legendFontSize'      | Set the font size for the legend
% -------------------------------------------------------------------------
%              |  'includeDescription' | Set the description of an object to the plot
% -------------------------------------------------------------------------
%  extensions  |  'add paths'          | Installs the toolbox extensions
%              |                       | found under the given directory.
% -------------------------------------------------------------------------
%              |  'remove paths'       | Uninstalls the toolbox extensions
%              |                       | found under the given directory.
% -------------------------------------------------------------------------
%  time        |  'timezone'           | Set the timezone used to display time
%              |                       | objects. (>> time.getTimezones)
% -------------------------------------------------------------------------
%              |  'timeformat'         | Set the format for displaying time objects
% -------------------------------------------------------------------------
%  misc        |  'default_window'     | The default spectral window object for
%              |                       | use by LTPDA's spectral analysis tools
% -------------------------------------------------------------------------
%
% Example: to set the verbose level of LTPDA from the command-line:
%
% >> LTPDAprefs('Display', 'verboseLevel', 3)
%
% The value of all properties in the table can also be retrieved by:
%
% >> LTPDAprefs.<property_name>
%
% for example,
%
% >> vl = LTPDAprefs.verboseLevel;
%
%

classdef LTPDAprefs < handle

  properties (Constant = true)
    oldpreffile = fullfile(prefdir, 'ltpda_prefs.xml');
    preffile = fullfile(prefdir, 'ltpda_prefs2.xml');
  end

  properties
    gui = [];   % handle to uifigure (when GUI is open)
  end


  methods
    function obj = LTPDAprefs(varargin)

      if nargin == 3 && ischar(varargin{1}) && ischar(varargin{2})

        %--- set preference by command-line
        category  = lower(varargin{1});
        property  = varargin{2};
        value     = varargin{3};
        LTPDAprefs.setPreference(category, property, value);

      else
        % -- load GUI
        prefs = getappdata(0, 'LTPDApreferences');
        if isempty(prefs)
          error('### No LTPDA Preferences found in memory. Please run ltpda_startup.');
        end
        obj.gui = buildPrefGUI(prefs);
      end

    end % End constructor

    function disp(~)
    end

  end % End public methods

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Methods (static)                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  methods (Static=true)

    %------------ add here the prototypes

    varargout = loadPrefs(varargin)
    varargout = upgradeFromPlist(varargin)
    varargout = setApplicationData(varargin)

    %------------ quick accessors for preferences

    % display
    function val = verboseLevel
      prefs = LTPDAprefs.getPreferences;
      val = double(prefs.getDisplayPrefs.getDisplayVerboseLevel);
    end

    function val = wrapStrings
      prefs = LTPDAprefs.getPreferences;
      val = double(prefs.getDisplayPrefs.getDisplayWrapStrings);
    end

    % plot
    function val = axesFontSize
      prefs = LTPDAprefs.getPreferences;
      val = double(prefs.getPlotPrefs.getPlotDefaultAxesFontSize);
    end

    function val = axesFontWeight
      prefs = LTPDAprefs.getPreferences;
      val = char(prefs.getPlotPrefs.getPlotDefaultAxesFontWeight);
    end

    function val = axesLineWidth
      prefs = LTPDAprefs.getPreferences;
      val = double(prefs.getPlotPrefs.getPlotDefaultAxesLineWidth);
    end

    function val = gridStyle
      prefs = LTPDAprefs.getPreferences;
      val = char(prefs.getPlotPrefs.getPlotDefaultAxesGridLineStyle);
    end

    function val = minorGridStyle
      prefs = LTPDAprefs.getPreferences;
      val = char(prefs.getPlotPrefs.getPlotDefaultAxesMinorGridLineStyle);
    end

    function val = legendFontSize
      prefs = LTPDAprefs.getPreferences;
      val = double(prefs.getPlotPrefs.getPlotDefaultLegendFontSize);
    end

    function val = includeDescription
      prefs = LTPDAprefs.getPreferences;
      val = prefs.getPlotPrefs.getPlotDefaultIncludeDescription().booleanValue();
    end

    % extensions
    function val = extensionPaths
      prefs = LTPDAprefs.getPreferences;
      val = cell(prefs.getExtensionsPrefs.getSearchPaths.toArray);
    end

    % time
    function val = timezone
      prefs = LTPDAprefs.getPreferences;
      val = char(prefs.getTimePrefs.getTimeTimezone);
    end

    function val = timeformat
      prefs = LTPDAprefs.getPreferences;
      val = char(prefs.getTimePrefs.getTimestringFormat);
    end

    % misc
    function val = default_window
      prefs = LTPDAprefs.getPreferences;
      val = char(prefs.getMiscPrefs.getDefaultWindow);
    end

  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, private)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Access = private, Static=true)

    prefs = getPreferences()
    setPreference(category, property, value)

  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private)                                 %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  methods (Access = private)

    cb_guiClosed(varargin)
    cb_verboseLevelChanged(varargin)
    cb_addExtensionPath(varargin)
    cb_removeExtensionPath(varargin)
    cb_plotPrefsChanged(varargin)
    cb_timeformatChanged(varargin)
    cb_timezoneChanged(varargin)

  end

end

% END

% =========================================================================
% Local (file-scope) GUI builder — not a class method
% =========================================================================

function fig = buildPrefGUI(prefs)
% Build the LTPDA Preferences uifigure with five tabs.

  fig = uifigure('Name', 'LTPDA Preferences', ...
                 'Position', [200 150 560 475], ...
                 'Resize', 'off');
  try
    set(fig, 'Theme', 'light');
  catch
  end

  tg = uitabgroup(fig, 'Position', [8 55 544 412]);

  buildDisplayTab   (uitab(tg, 'Title', 'Display'),    prefs);
  buildPlotTab      (uitab(tg, 'Title', 'Plot'),        prefs);
  buildExtensionsTab(uitab(tg, 'Title', 'Extensions'), prefs, fig);
  buildTimeTab      (uitab(tg, 'Title', 'Time'),        prefs);
  buildMiscTab      (uitab(tg, 'Title', 'Misc'),        prefs);
  buildConnectionTab(uitab(tg, 'Title', 'Connection'), prefs, fig);
  buildSSHTab       (uitab(tg, 'Title', 'SSH Tunnel'));

  uibutton(fig, 'Text', 'Close', ...
    'Position', [455 14 90 28], ...
    'ButtonPushedFcn', @(~,~) delete(fig));
end


function buildDisplayTab(tab, prefs)
  dp  = prefs.getDisplayPrefs;
  row = 355;  dy = 40;

  uilabel(tab, 'Text', 'Verbose level:', 'Position', [15 row 165 22]);
  vlItems = {'0','1','2','3','4','5'};
  vlVal   = num2str(double(dp.getDisplayVerboseLevel));
  if ~any(strcmp(vlItems, vlVal)), vlVal = '0'; end
  uidropdown(tab, ...
    'Items', vlItems, ...
    'Value', vlVal, ...
    'Position', [190 row 100 22], ...
    'ValueChangedFcn', @(src,~) LTPDAprefs.setPreference('display','verboseLevel',str2double(src.Value)));

  row = row - dy;
  uilabel(tab, 'Text', 'Wrap strings at column:', 'Position', [15 row 175 22]);
  uieditfield(tab, 'numeric', ...
    'Value', double(dp.getDisplayWrapStrings), ...
    'RoundFractionalValues', 'on', ...
    'Position', [190 row 100 22], ...
    'ValueChangedFcn', @(src,~) LTPDAprefs.setPreference('display','wrapstrings',round(src.Value)));

  row = row - dy;
  uilabel(tab, 'Text', 'Key action:', 'Position', [15 row 165 22]);
  kaMap = {'NONE','WARNING','ERROR'};
  kaIdx = max(1, min(3, double(dp.getDisplayKeyAction) + 1));
  uidropdown(tab, ...
    'Items', kaMap, ...
    'Value', kaMap{kaIdx}, ...
    'Position', [190 row 130 22], ...
    'ValueChangedFcn', @(src,~) LTPDAprefs.setPreference('display','key action',lower(src.Value)));
end


function buildPlotTab(tab, prefs)
  pp         = prefs.getPlotPrefs;
  lineStyles = {'-', '--', ':', '-.', 'none'};
  fwItems    = {'Plain', 'Bold', 'Italic', 'Bold Italic'};
  row = 355;  dy = 36;

  uilabel(tab, 'Text', 'Axes font size:', 'Position', [15 row 170 22]);
  uieditfield(tab, 'numeric', ...
    'Value', double(pp.getPlotDefaultAxesFontSize), ...
    'RoundFractionalValues', 'on', ...
    'Position', [190 row 80 22], ...
    'ValueChangedFcn', @(src,~) LTPDAprefs.setPreference('plot','axesFontSize',round(src.Value)));

  row = row - dy;
  uilabel(tab, 'Text', 'Axes font weight:', 'Position', [15 row 170 22]);
  curFW = char(pp.getPlotDefaultAxesFontWeight);
  if ~any(strcmp(fwItems, curFW)), curFW = fwItems{1}; end
  uidropdown(tab, 'Items', fwItems, 'Value', curFW, ...
    'Position', [190 row 130 22], ...
    'ValueChangedFcn', @(src,~) LTPDAprefs.setPreference('plot','axesFontWeight',src.Value));

  row = row - dy;
  uilabel(tab, 'Text', 'Axes line width:', 'Position', [15 row 170 22]);
  uieditfield(tab, 'numeric', ...
    'Value', double(pp.getPlotDefaultAxesLineWidth), ...
    'RoundFractionalValues', 'on', ...
    'Position', [190 row 80 22], ...
    'ValueChangedFcn', @(src,~) LTPDAprefs.setPreference('plot','axesLineWidth',round(src.Value)));

  row = row - dy;
  uilabel(tab, 'Text', 'Grid line style:', 'Position', [15 row 170 22]);
  curGS = char(pp.getPlotDefaultAxesGridLineStyle);
  if ~any(strcmp(lineStyles, curGS)), curGS = '-'; end
  uidropdown(tab, 'Items', lineStyles, 'Value', curGS, ...
    'Position', [190 row 100 22], ...
    'ValueChangedFcn', @(src,~) LTPDAprefs.setPreference('plot','gridStyle',src.Value));

  row = row - dy;
  uilabel(tab, 'Text', 'Minor grid line style:', 'Position', [15 row 170 22]);
  curMG = char(pp.getPlotDefaultAxesMinorGridLineStyle);
  if ~any(strcmp(lineStyles, curMG)), curMG = ':'; end
  uidropdown(tab, 'Items', lineStyles, 'Value', curMG, ...
    'Position', [190 row 100 22], ...
    'ValueChangedFcn', @(src,~) LTPDAprefs.setPreference('plot','minorGridStyle',src.Value));

  row = row - dy;
  uilabel(tab, 'Text', 'Legend font size:', 'Position', [15 row 170 22]);
  uieditfield(tab, 'numeric', ...
    'Value', double(pp.getPlotDefaultLegendFontSize), ...
    'RoundFractionalValues', 'on', ...
    'Position', [190 row 80 22], ...
    'ValueChangedFcn', @(src,~) LTPDAprefs.setPreference('plot','legendFontSize',round(src.Value)));

  row = row - dy;
  uilabel(tab, 'Text', 'Include description in plot:', 'Position', [15 row 200 22]);
  uicheckbox(tab, 'Text', '', ...
    'Value', logical(pp.getPlotDefaultIncludeDescription().booleanValue()), ...
    'Position', [218 row 30 22], ...
    'ValueChangedFcn', @(src,~) LTPDAprefs.setPreference('plot','includeDescription',src.Value));
end


function buildExtensionsTab(tab, prefs, fig)
  uilabel(tab, 'Text', 'Extension search paths:', 'Position', [15 370 220 22]);
  lb = uilistbox(tab, ...
    'Items', getExtPaths(prefs), ...
    'Position', [15 65 395 295], ...
    'Multiselect', 'on');

  uibutton(tab, 'Text', 'Add...', ...
    'Position', [420 332 110 28], ...
    'ButtonPushedFcn', @(~,~) cbAddExtPath(lb, prefs, fig));

  uibutton(tab, 'Text', 'Remove selected', ...
    'Position', [420 295 110 28], ...
    'ButtonPushedFcn', @(~,~) cbRemoveExtPath(lb, prefs));
end


function buildTimeTab(tab, prefs)
  tp  = prefs.getTimePrefs;
  row = 355;  dy = 40;

  uilabel(tab, 'Text', 'Timezone:', 'Position', [15 row 155 22]);
  uieditfield(tab, 'text', ...
    'Value', char(tp.getTimeTimezone), ...
    'Tooltip', 'Java timezone ID, e.g. UTC, Europe/Berlin, America/New_York', ...
    'Position', [175 row 295 22], ...
    'ValueChangedFcn', @(src,~) LTPDAprefs.setPreference('time','timezone',src.Value));

  row = row - dy;
  uilabel(tab, 'Text', 'Time format:', 'Position', [15 row 155 22]);
  uieditfield(tab, 'text', ...
    'Value', char(tp.getTimestringFormat), ...
    'Tooltip', 'MATLAB datestr format, e.g. yyyy-mm-dd HH:MM:SS.FFF z', ...
    'Position', [175 row 295 22], ...
    'ValueChangedFcn', @(src,~) LTPDAprefs.setPreference('time','timeformat',src.Value));
end


function buildMiscTab(tab, prefs)
  mp = prefs.getMiscPrefs;
  try
    winTypes = specwin.getTypes;
  catch
    winTypes = {'BH92', 'Hann', 'Rectangular', 'Flat Top', 'Kaiser'};
  end
  curWin = char(mp.getDefaultWindow);
  if ~any(strcmp(winTypes, curWin)), curWin = winTypes{1}; end

  uilabel(tab, 'Text', 'Default spectral window:', 'Position', [15 355 200 22]);
  uidropdown(tab, 'Items', winTypes, 'Value', curWin, ...
    'Position', [220 355 200 22], ...
    'ValueChangedFcn', @(src,~) LTPDAprefs.setPreference('misc','default_window',src.Value));
end


function paths = getExtPaths(prefs)
  try
    jArr  = prefs.getExtensionsPrefs.getSearchPaths.toArray;
    paths = cellfun(@char, cell(jArr), 'UniformOutput', false);
    if isempty(paths), paths = {}; end
  catch
    paths = {};
  end
end


function cbAddExtPath(lb, prefs, fig)
  p = uigetdir(pwd, 'Select extension directory');
  if ischar(p) && ~isequal(p, 0)
    try
      LTPDAprefs.setPreference('extensions', 'add paths', {p});
    catch ex
      uialert(fig, ex.message, 'Add extension path failed');
    end
    lb.Items = getExtPaths(prefs);
  end
end


function cbRemoveExtPath(lb, prefs)
  sel = lb.Value;
  if isempty(sel), return; end
  if ischar(sel), sel = {sel}; end
  for kk = 1:numel(sel)
    try
      LTPDAprefs.setPreference('extensions', 'remove paths', sel(kk));
    catch
    end
  end
  lb.Items = getExtPaths(prefs);
end


function buildSSHTab(tab)
% SSH Tunnel tab — reads/writes MATLAB preferences directly (no Java prefs object).

  GROUP = 'LTPDA_SSH';

  % Read current settings with defaults
  if ispref(GROUP, 'enabled'),     enVal  = getpref(GROUP, 'enabled');     else; enVal  = false; end
  if ispref(GROUP, 'server'),      srvVal = getpref(GROUP, 'server');      else; srvVal = '';    end
  if ispref(GROUP, 'remote_host'), rhVal  = getpref(GROUP, 'remote_host'); else; rhVal  = '';    end
  portVal   = getpref(GROUP, 'port',       2222);
  lportVal  = getpref(GROUP, 'local_port', 13306);
  mysqlPVal = getpref(GROUP, 'mysql_port', 3306);

  row = 355;  dy = 44;

  % Enable / disable auto-tunnel
  uicheckbox(tab, ...
    'Text',  'Enable automatic SSH tunnel on startup', ...
    'Value', enVal, ...
    'Position', [15 row 370 22], ...
    'ValueChangedFcn', @(src,~) setpref(GROUP, 'enabled', src.Value));

  % Server hostname
  row = row - dy;
  uilabel(tab, 'Text', 'Server hostname:', 'Position', [15 row 155 22]);
  uieditfield(tab, 'text', ...
    'Value',       srvVal, ...
    'Placeholder', 'repo.yourdomain.com', ...
    'Tooltip',     'Hostname or IP of the server running the LTPDA repository', ...
    'Position', [175 row 295 22], ...
    'ValueChangedFcn', @(src,~) setpref(GROUP, 'server', strtrim(src.Value)));

  % SSH gateway port
  row = row - dy;
  uilabel(tab, 'Text', 'SSH gateway port (default 2222):', 'Position', [15 row 215 22]);
  uieditfield(tab, 'numeric', ...
    'Value',                double(portVal), ...
    'Limits',               [1 65535], ...
    'RoundFractionalValues', 'on', ...
    'ValueDisplayFormat',   '%d', ...
    'Tooltip', 'Port the SSH gateway container listens on (default: 2222)', ...
    'Position', [235 row 100 22], ...
    'ValueChangedFcn', @(src,~) setpref(GROUP, 'port', round(src.Value)));

  % Local JDBC port
  row = row - dy;
  uilabel(tab, 'Text', 'Local JDBC port (default 13306):', 'Position', [15 row 215 22]);
  uieditfield(tab, 'numeric', ...
    'Value',                double(lportVal), ...
    'Limits',               [1 65535], ...
    'RoundFractionalValues', 'on', ...
    'ValueDisplayFormat',   '%d', ...
    'Tooltip', 'Local port forwarded to remoteHost:3306 through the tunnel (default: 13306)', ...
    'Position', [235 row 100 22], ...
    'ValueChangedFcn', @(src,~) setpref(GROUP, 'local_port', round(src.Value)));

  % Remote MySQL host
  row = row - dy;
  uilabel(tab, 'Text', 'Remote MySQL host:', 'Position', [15 row 215 22]);
  uieditfield(tab, 'text', ...
    'Value',       rhVal, ...
    'Placeholder', 'db', ...
    'Tooltip',     'Docker network name/alias of the MySQL container (default: db)', ...
    'Position', [235 row 235 22], ...
    'ValueChangedFcn', @(src,~) setpref(GROUP, 'remote_host', strtrim(src.Value)));

  % MySQL port
  row = row - dy;
  uilabel(tab, 'Text', 'MySQL port (default 3306):', 'Position', [15 row 215 22]);
  uieditfield(tab, 'numeric', ...
    'Value',                double(mysqlPVal), ...
    'Limits',               [1 65535], ...
    'RoundFractionalValues', 'on', ...
    'ValueDisplayFormat',   '%d', ...
    'Tooltip',              'MySQL port on the remote host (default: 3306)', ...
    'Position', [235 row 100 22], ...
    'ValueChangedFcn', @(src,~) setpref(GROUP, 'mysql_port', round(src.Value)));

  % Hint
  row = row - dy;
  uilabel(tab, ...
    'Text',      'In LTPDAprefs connection: set Hostname = localhost, Port = local JDBC port.', ...
    'FontColor', [0.55 0.55 0.55], ...
    'WordWrap',  'on', ...
    'Position',  [15 row 470 36]);

  % Connect button
  row = row - dy - 4;
  uibutton(tab, 'Text', 'Connect tunnel now', ...
    'Position', [15 row 150 28], ...
    'Tooltip',  'Equivalent to running ltpda_tunnel in the Command Window', ...
    'ButtonPushedFcn', @(~,~) ltpda_tunnel);
end


function buildConnectionTab(tab, prefs, fig)
% Build the Connection tab: known repositories list + credential settings.

  rp = prefs.getRepoPrefs();

  % ── Credential settings (top) ──────────────────────────────────────────
  uilabel(tab, 'Text', 'Credential expiry (s):', 'Position', [15 355 155 22]);
  uieditfield(tab, 'numeric', ...
    'Value',                double(rp.getExpiry()), ...
    'Limits',               [0 86400], ...
    'RoundFractionalValues', 'on', ...
    'Tooltip', 'Seconds before cached passwords expire (0 = never expire)', ...
    'Position', [175 355 65 22], ...
    'ValueChangedFcn', @(src,~) cbSetExpiry(rp, prefs, src));

  uilabel(tab, 'Text', 'Cache password:', 'Position', [258 355 120 22]);
  cpItems = {'No', 'Yes', 'Ask'};
  cpIdx   = max(1, min(3, double(rp.getCachePassword()) + 1));
  uidropdown(tab, ...
    'Items', cpItems, ...
    'Value', cpItems{cpIdx}, ...
    'Position', [382 355 100 22], ...
    'ValueChangedFcn', @(src,~) cbSetCachePolicy(rp, prefs, src, cpItems));

  % ── Known repositories list ─────────────────────────────────────────────
  uilabel(tab, 'Text', 'Known repositories:', 'Position', [15 315 220 22]);

  lb = uilistbox(tab, 'Items', getRepoHostnames(rp), 'Position', [15 70 390 238]);

  uibutton(tab, 'Text', 'Add...', ...
    'Position', [415 281 115 28], ...
    'ButtonPushedFcn', @(~,~) cbAddRepo(lb, rp, prefs, fig));

  uibutton(tab, 'Text', 'Remove selected', ...
    'Position', [415 244 115 28], ...
    'ButtonPushedFcn', @(~,~) cbRemoveRepo(lb, rp, prefs));

  % ── Hint ────────────────────────────────────────────────────────────────
  uilabel(tab, ...
    'Text',     'For SSH tunnel: add localhost:13306 (or your configured local JDBC port).', ...
    'FontColor', [0.55 0.55 0.55], ...
    'WordWrap',  'on', ...
    'Position',  [15 30 510 32]);
end


function items = getRepoHostnames(rp)
  try
    repos = cell(rp.getRepositories().toArray());
    items = {};
    for k = 1:numel(repos)
      r = repos{k};
      if ~isempty(r) && ~isempty(r{1})
        items{end+1} = char(r{1}); %#ok<AGROW>
      end
    end
  catch
    items = {};
  end
end


function cbSetExpiry(rp, prefs, src)
  rp.setExpiry(java.lang.Integer(round(src.Value)));
  prefs.writeToDisk();
end


function cbSetCachePolicy(rp, prefs, src, items)
  rp.setCachePassword(java.lang.Integer(find(strcmp(items, src.Value), 1) - 1));
  prefs.writeToDisk();
end


function cbAddRepo(lb, rp, prefs, fig)
  host = addRepoDialog();
  if isempty(host), return; end
  try
    rp.addHostname(host);
    prefs.writeToDisk();
  catch ex
    uialert(fig, ex.message, 'Add repository failed');
  end
  lb.Items = getRepoHostnames(rp);
end


function host = addRepoDialog()
% ADDREPODIALOG  Light-themed uifigure dialog for entering a repository hostname.
%   Returns the trimmed hostname string, or '' if cancelled.

  host = '';

  dlg = uifigure('Name', 'Add repository', ...
                 'Position', [0 0 380 120], ...
                 'Resize',   'off', ...
                 'WindowStyle', 'modal');
  try
    set(dlg, 'Theme', 'light');
  catch
  end
  movegui(dlg, 'center');

  uilabel(dlg, 'Text', 'Hostname:', 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'right', 'Position', [14 68 80 22]);
  hField = uieditfield(dlg, 'text', ...
    'Placeholder', 'localhost:13306  or  repo.example.com', ...
    'Position', [102 68 260 22]);

  uibutton(dlg, 'Text', 'Cancel', ...
    'Position', [102 22 100 28], ...
    'ButtonPushedFcn', @(~,~) uiresume(dlg));
  uibutton(dlg, 'Text', 'Add', 'FontWeight', 'bold', ...
    'Position', [212 22 150 28], ...
    'ButtonPushedFcn', @(~,~) setOkAndResumeDlg(dlg));

  dlg.CloseRequestFcn = @(~,~) uiresume(dlg);

  focus(hField);
  uiwait(dlg);

  if ~isvalid(dlg), return; end
  if ~isempty(dlg.Tag)
    host = strtrim(hField.Value);
  end
  delete(dlg);
end


function setOkAndResumeDlg(dlg)
  dlg.Tag = 'ok';
  uiresume(dlg);
end


function cbRemoveRepo(lb, rp, prefs)
  sel = lb.Value;
  if isempty(lb.Items) || isempty(sel), return; end
  idx = find(strcmp(lb.Items, sel), 1);
  if isempty(idx), return; end
  try
    rp.getRepositories().remove(java.lang.Integer(idx - 1));
    prefs.writeToDisk();
  catch
  end
  lb.Items = getRepoHostnames(rp);
end
