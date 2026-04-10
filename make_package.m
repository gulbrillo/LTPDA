% make_package.m  Build LTPDA.mltbx for distribution via the MATLAB Add-On Manager.
%
% Run from the repository root:
%
%   run make_package.m
%
% Output: LTPDA.mltbx in the repository root.
%
% The toolbox identifier UUID is fixed so the Add-On Manager recognises
% successive builds as updates to the same toolbox rather than new installs.
%
% See also: toolbox/README.md (Installation section)

repoRoot    = fileparts(mfilename('fullpath'));
toolboxRoot = fullfile(repoRoot, 'toolbox');

% Need ltpda_ver on the path to read the version string
addpath(fullfile(toolboxRoot, 'm', 'etc'));
v = ltpda_ver();

opts = matlab.addons.toolbox.ToolboxOptions(toolboxRoot, ...
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890');

opts.ToolboxName          = 'LTPDA Toolbox';
opts.ToolboxVersion       = strtok(v.Version, '-');  % strip suffix, e.g. '4.0.0-PSSL' → '4.0.0'
opts.AuthorName           = 'LTPDA Community';
opts.AuthorEmail          = '';
opts.AuthorCompany        = '';
opts.Summary              = 'Accountable and reproducible data analysis (R2025a fork)';
opts.Description          = [ ...
    'Fork of LTPDA v3.0.13 updated for MATLAB R2025a. ' ...
    'Includes modern JSch (0.2.21), SSH MFA/Duo Push support, ' ...
    'and rewritten GUIs using uifigure.'];
opts.MinimumMatlabRelease = 'R2025a';
opts.MaximumMatlabRelease = '';
opts.ToolboxImageFile     = fullfile(toolboxRoot, 'help', 'ug', 'images', 'LTPDAlauncher.png');
opts.OutputFile           = fullfile(repoRoot, 'LTPDA.mltbx');


matlab.addons.toolbox.packageToolbox(opts);
fprintf('Done. Package written to:\n  %s\n', opts.OutputFile);
fprintf('Version: %s\n', opts.ToolboxVersion);
