% Compile package within MATLAB
%
% M Hewitson 22-01-07
%
% $Id$
%
function compile(varargin)

  %% Settings

  PACKAGE_NAME = 'ltpda_polyreg';
  RELEASE      = version('-release');

  % compile variables
  src          = './ltpda_polyreg.c ';
  include      = '';

  % install these files
  files        = {sprintf('ltpda_polyreg.%s', mexext), ...
    'ltpda_polyreg.m'};


  %% Set variables for this platform

    os = computer;
    switch os
      case 'PCWIN' % Windows
        platform = 'Windows PC';
        mexPkg   = 'windows';
      case 'PCWIN64' % Windows 64-bit
        platform = 'Windows PC 64-bit';
        mexPkg   = 'windows64';
      case 'GLNX86' % Linux
        platform = 'Linux PC';
        mexPkg   = 'linux';
      case 'GLNXA64' % Linux
        platform = 'Linux PC 64-bit';
        mexPkg   = 'linux64';
      case 'MAC' % Mac PPC
        platform = 'PPC Mac';
        mexPkg   = 'macppc';
      case 'MACI' % Mac intel
        platform = 'Intel Mac';
        mexPkg   = 'macintel';
      case 'MACI64' % 64-bit Intel Mac
        platform = 'Intel Mac 64-bit';
        mexPkg = 'maci64';
      otherwise
        error('### compile: unknown platform');
    end

    disp(sprintf('* Compiling %s for %s', PACKAGE_NAME, platform));

    %% Compile ltpda_polyreg
    extras = '';
    switch os
      case 'PCWIN64'
        cmd = sprintf('mex  -f mexopts_XP64bit.bat -v %s %s %s', extras, include, src)
      case 'PCWIN'
        cmd = sprintf('mex -v %s %s %s', extras, include, src)
      case 'MACI'
        cmd = sprintf('mex  -f mexopts.sh -v %s %s %s', extras, include, src)
      case 'MACI64'
        cmd = sprintf('mex -v %s %s %s', extras, include, src)
      case 'GLNX86'
        cmd = sprintf('mex -v %s %s %s', extras, include, src)
      case 'GLNXA64'
        cmd = sprintf('mex -v %s %s %s', extras, include, src)
    end
    eval(cmd)

    if nargin==0
      return % It is not necessary to copy the mex file.
    else
      installPoint = varargin{1};
    end
    mkdir(installPoint)
    for f = files
      fi = char(f);
      disp(sprintf('  - installing %s', fi));
      copyfile(fi, installPoint);
    end
end


