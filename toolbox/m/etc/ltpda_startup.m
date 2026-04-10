% This is the startup file for ltpda. It should be run once in the MATLAB
% session before using any features of ltpda. The best way to ensure this
% is to create a file called startup.m and put this somewhere in your
% MATLAB path. In this file you should have the command 'ltpda_startup'.
%
% M Hewitson 16-03-07
%
% $Id$
%
function ltpda_startup
  
  
  % For the case that the user calls 'ltpda_startup' in his current MATLAB
  % session again it is necessary to destroy ALL java objects.
  try
    rmappdata(0, 'LTPDApreferences');
  end
  
  % Remove the database connection manager
  try
    rmappdata(0, 'LTPDADatabaseConnectionManager');
  end
  
  % Note: 'clear java' is intentionally omitted.
  % In R2025a it refuses to run when any Java objects are alive and prints
  % spurious warnings. The dynamic classpath is managed by addJarIfNeeded
  % below, which skips JARs already on the path.
  
  %--------------------------------------------------------------------------
  % If the mex files of LTPDA are not working on your system, you can
  % recompile them by setting this flag to 1 then run ltpda_startup. After
  % compilation, set it back to 0.
  %
  % This is often required on Linux machines due to the difficulties of
  % distributing mex files on Linux.
  COMPILE_MEX = 0;
  
  %-----------------------------------------------------------------------
  % Decide if using or not the LTPDA print and plot settings
  USE_LTPDA_PLOT = true;
  USE_LTPDA_PRINT = true;
  
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  
  
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  % NO NEED TO EDIT BELOW HERE
  %--------------------------------------------------------------------------
  %--------------------------------------------------------------------------
  
  v = ltpda_ver();
  
  %--------------------------------------------------------------------------
  % format of numbers on MATLAB terminal
  format long g
  
  % ------------------------------------------------------------------------
  % MySQL LTPDA Repository Server Settings
  %
  
  DBDRIVER = 'com.mysql.jdbc.Driver';   % Set LTPDA Repository database driver
  
  %------------------------------------------------------------------------
  % JAVA extensions
  
  
  
  % Add all jar files in 'ltpda_toolbox/ltpda/jar' to path
  jardir = fullfile(fileparts(which('ltpda_startup')), '..', '..', 'jar');
  jars = dir(jardir);
  for c = 1:numel(jars)
    s = jars(c);
    [path, name, ext] = fileparts(s.name);
    if strcmp(ext, '.jar')
      addJarIfNeeded(fullfile(jardir, s.name));
    end
  end
  % Add all jar files in 'ltpda_toolbox/ltpda/jar/lib' to path
  jardir = fullfile(fileparts(which('ltpda_startup')), '..', '..', 'jar', 'lib');
  jars = dir(jardir);
  for c = 1:numel(jars)
    s = jars(c);
    [path, name, ext] = fileparts(s.name);
    if strcmp(ext, '.jar')
      addJarIfNeeded(fullfile(jardir, s.name));
    end
  end

  % add all jar files in ltpda_toolbox/extensions
  extdir = fullfile(fileparts(which('ltpda_startup')), '..', '..', '..', 'extensions');
  jars = utils.prog.filescan(extdir, '.jar');
  for c = 1:numel(jars)
    s = jars(c);
    addJarIfNeeded(s);
  end
 
  % Add all jar files in extension modules to path
  installExtensionJarFiles;
  
  % ------------------------------------------------------------------------
  % General Variables
  setappdata(0, 'xmlsetsize', 50000); % Max size of an xml data set <Set></Set>
  
  setappdata(0, 'ltpda_default_plot_colors', { ...
    [0 0 1],     ...  % 'b'
    [1 0 0],     ...  % 'r'
    [0 1 0],     ...  % 'g'
    [0 0 0],     ...  % 'k'
    [0 1 1],     ...  % 'c'
    [1 0 1],     ...  % 'm'
    [0.565 0.247 0.667],     ...  % pink
    [0.722 0.420 0.274],     ...   % siena
    [0.659 0.541 0.000],     ...   % ocra
    [1 0.604 0.208],     ...   % orange
    [0.502 0.502 0.502],     ...   % dark grey
    [0.733 0.824 0.082],     ...   % ill green
    [0.318 0.557 0.675],     ...   % cobalto
    [0.8 0.2 0.2],     ...
    [0.2 0.2 0.8],     ...
    [0.2 0.9 0.2],     ...
    [0.37 0.9 0.83],   ...
    [0.888 0.163 0.9], ...
    [0 0 0],           ...
    [0 207 255]/255,   ...
    [255 128 0]/255,   ...
    [143 0 0]/255,     ...
    [255 207 0]/255,   ...
    [0.9 0.266 0.593]});
  
  % ------------------------------------------------------------------------
  % Version Variables
  
  NOT_INSTALLED = 'Not installed';
  matlab_version = NOT_INSTALLED;
  sigproc_version = NOT_INSTALLED;
  symbolic_math_version = NOT_INSTALLED;
  optimization_version = NOT_INSTALLED;
  database_version = NOT_INSTALLED;
  control_version = NOT_INSTALLED;
  statistics_version = NOT_INSTALLED;
  ltpda_version = NOT_INSTALLED;
  
  vs = ver;
  for jj = 1:length(vs)
    v = vs(jj);
    switch v.Name
      case 'MATLAB'
        matlab_version = [v.Version ' ' v.Release];
      case 'Signal Processing Toolbox'
        sigproc_version = [v.Version ' ' v.Release];
      case 'Symbolic Math Toolbox'
        symbolic_math_version = [v.Version ' ' v.Release];
      case 'Optimization Toolbox'
        optimization_version = [v.Version ' ' v.Release];
      case 'Database Toolbox'
        database_version = [v.Version ' ' v.Release];
      case 'Control System Toolbox'
        control_version = [v.Version ' ' v.Release];
      case 'Statistics Toolbox'
        statistics_version = [v.Version ' ' v.Release];
      case 'LTPDA Toolbox'
        vMatlab = ver('MATLAB');
        ltpda_version = [v.Version ' ' vMatlab.Release];
    end
  end
  
  setappdata(0, 'matlab_version', matlab_version);
  setappdata(0, 'sigproc_version', sigproc_version);
  setappdata(0, 'symbolic_math_version', symbolic_math_version);
  setappdata(0, 'optimization_version', optimization_version);
  setappdata(0, 'database_version', database_version);
  setappdata(0, 'control_version', control_version);
  setappdata(0, 'statistics_version', statistics_version);
  setappdata(0, 'ltpda_version', ltpda_version);
  setappdata(0, 'ltpda_required_matlab_version', '8.0');
  
  %--------------------------------------------------------------------------
  % do we need to compile mex files?
  if COMPILE_MEX
    currdir = pwd;
    [path, name, ext, vers] = fileparts(which('ltpda_startup'));
    parts = regexp(path, 'ltpda/',  'split');
    cd(fullfile(parts{1}, 'ltpda', 'src'));
    compileAll;
    cd(currdir);
  end
  
  %--------------------------------------------------------------------------
  % Start matlab pool if parallel toolbox is installed
  if exist('parfor', 'builtin')==5 && exist('matlabpool','file')==2
    %     try
    %       matlabpool open 2
    %     end
  end
  
  % -------------------------------------------------------------------------
  %  import some things
  
  import utils.const.*
  
  %--------------------------------------------------------------------------
  % Check and load user parameters
  %
  loadPrefs;
  
  
  %--------------------------------------------------------------------------
  % set page properties for printing
  if USE_LTPDA_PRINT
    set(0, 'DefaultFigurePaperOrientation','landscape');
    set(0, 'DefaultFigurePaperType','A4');
    set(0, 'DefaultFigurePaperUnits', 'centimeters');
    set(0, 'DefaultFigurePaperPositionMode', 'manual');
    set(0, 'DefaultFigurePaperPosition', [0 0 29 21]);
  end
  
  % ------------------------------------------------------------------------
  % Backup MATLAB's plot settings
  utils.plottools.backupDefaultPlotSettings();
  
  %--------------------------------------------------------------------------
  % Plot settings
  if USE_LTPDA_PLOT
    set(0, 'DefaultAxesXColor', [0 0 0]);
    set(0, 'DefaultAxesYColor', [0 0 0]);
    set(0, 'DefaultAxesColor',  [1 1 1]);
    set(0, 'defaultfigurenumbertitle', 'on');
    set(0, 'DefaultFigureColor', 'w');
    set(0, 'DefaultFigurePosition', [0 0 1200 700]);
    set(0, 'DefaultAxesPosition', [0.13 0.15 0.775 0.75]);
  end
  
  % Add user model paths
  prefs = getappdata(0, 'LTPDApreferences');
  searchPaths = prefs.getModelsPrefs.getSearchPaths;
  for jj = 1:searchPaths.size()
    addpath(genpath(char(searchPaths.get(jj-1))));
  end
  
  % Install extensions
  utils.modules.installExtensions;
  
  % Remove the VCS folders from the path
  utils.helper.remove_cvs_from_matlabpath();
  utils.helper.remove_svn_from_matlabpath();
  utils.helper.remove_git_from_matlabpath();
  
  %--------------------------------------------------------------------------
  % Check that the user uses at least the last supported MATLAB version.
  if isMATLABReleaseOlderThan('R2025a')
    error('### This fork of LTPDA requires MATLAB R2025a or later');
  end
  
  % Set LTPDA Root dir
  ltpdaroot = strrep(which('ao'), fullfile('ltpda', 'classes', '@ao', 'ao.m'), '');
  setappdata(0, 'LTPDAROOT', ltpdaroot);
  
  
  % ── Auto SSH tunnel ────────────────────────────────────────────────────
  % If the user has configured an auto-tunnel (ltpda_ssh_setup enable),
  % establish it now. Credentials are prompted via a dialog and stored in
  % memory only (never on disk). Skip silently if not configured.
  if ispref('LTPDA_SSH', 'enabled') && getpref('LTPDA_SSH', 'enabled')
    try
      ltpda_tunnel();
    catch ex
      warning('LTPDA:ssh', 'SSH tunnel failed at startup: %s', ex.message);
    end
  end

  % Show logo
  showLogo();
  
  % set LTPDA operating mode
  setappdata(0, 'LTPDA_MODE', utils.const.msg.USER);
  
  % Now we need to clear in order to register the newly install class
  % methods coming from the extensions
  mc;
  
end

function addJarIfNeeded(jarPath)
% ADDJARIFNEEDED  Add a JAR to the dynamic Java classpath only if not already present.
% Prevents "already specified on java path" warnings when ltpda_startup is called
% more than once in a session (e.g. from startup.m and manually), since clear java
% no longer resets the dynamic classpath in R2025a.
  cp = javaclasspath('-dynamic');
  if ~any(strcmp(cp, jarPath))
    javaaddpath(jarPath);
  end
end


function installExtensionJarFiles
  % Load JAR files from any user extension modules listed in preferences.
  % Silently skips if preferences are unavailable (e.g. first run or no
  % registered toolbox version).
  try
    v = ltpda_ver();
    if isempty(v)
      nv = utils.helper.ver2num('3.0.13');
    else
      nv = utils.helper.ver2num(v(1).Version);
    end
    prefs = mpipeline.ltpdapreferences.LTPDAPreferences.loadFromDisk(LTPDAprefs.preffile, nv);
    prefs.writeToDisk;
    jextPaths = prefs.getExtensionsPrefs.getSearchPaths;
    setappdata(0, 'LTPDApreferences', []);
    clear prefs;

    extPaths = {};
    for kk = 0:jextPaths.size-1
      extPaths{end+1} = char(jextPaths.get(kk)); %#ok<AGROW>
    end
    clear jextPaths;

    for kk = 1:numel(extPaths)
      p = extPaths{kk};
      files = utils.prog.filescan(p, '.jar');
      for ff = 1:numel(files)
        f = files{ff};
        [~, ~, ext] = fileparts(f);
        if strcmp(ext, '.jar')
          addJarIfNeeded(f);
        end
      end
    end
  catch ex
    fprintf('Warning: could not load extension JAR files (%s). Continuing without extensions.\n', ex.message);
  end
end


function loadPrefs
  if exist(LTPDAprefs.preffile, 'file') == 2
    
    % we just go ahead
    LTPDAprefs.loadPrefs;
    
  else
    
    % Check for old prefs file
    if exist(LTPDAprefs.oldpreffile, 'file') == 2
      
      % load it
      pl = plist(LTPDAprefs.oldpreffile);
      
      % Now make a new preferences file
      LTPDAprefs.loadPrefs;
      prefs = getappdata(0, 'LTPDApreferences');
      prefs = LTPDAprefs.upgradeFromPlist(prefs, pl);
      
      prefs.writeToDisk;
      
    else
      
      % Copy the default preferences file to MATLAB's preference directory.
      defPrefsFile = fullfile(fileparts(which('ltpda_startup')), 'ltpda_prefs2.xml');
      copyfile(defPrefsFile, prefdir() );
      
      % Build the default prefs
      LTPDAprefs.loadPrefs;
      
      % Show a GUI to allow the user to edit the prefs for the first time
      LTPDAprefs;
      
    end
  end
end

function showLogo()
  
  v = ltpda_ver();

logo = {...
    '                                    ',...
    '                ****                ',...
    '                 **                 ',...
    '            ------------            ',...
    '        ////     //     \\\\        ',...
    '     ///        ///         \\\     ',...
    '    |          ///             |    ',...
    '** |  +----+  ////      +----+  | **',...
    '***|  |    | ////////// |    |  |***',...
    '** |  +----+      ////  +----+  | **',...
    '    |             ///          |    ',...
    '     \\\         ///        ///     ',...
    '        \\\\     //     ////        ',...
    '            ------------            ',...
    '                 **                 ',...
    '                ****                ',...
    '                                    ',...
    };    
  

  l1 = '+------------------------------------------------+';
  ll = length(l1);
  
  disp(l1);
  for jj = 1:length(logo)
    disp([utils.prog.strpad(sprintf('|      %s      |', char(logo{jj})), ll-1) ' ']);
  end
  try
    ltpdaHash = [];
    ltpdaHash = gitHash();
    ltpdaHash = ltpdaHash.ltpda(1:7);
  catch
  end
  if ~ischar(ltpdaHash), ltpdaHash = 'unknowh'; end
  
  disp([utils.prog.strpad(sprintf('|          Welcome to the %s', v.Name), ll-1) '|'])
  disp([utils.prog.strpad('|             ', ll-1) '|'])
  disp([utils.prog.strpad(sprintf('|               Version: %s', v.Version), ll-1) '|'])
  disp([utils.prog.strpad(sprintf('|                   %s', v.Date), ll-1) '|'])
  disp([utils.prog.strpad('|', ll-1) '|'])
  disp(l1);
  disp([utils.prog.strpad('|    LTPDAprefs: open LTPDA settings dialog', ll-1) '|'])
  disp([utils.prog.strpad('|    ltpda_tunnel: connect repository server', ll-1) '|'])

  disp(l1);

  
end


% END
