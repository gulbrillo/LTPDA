% This will run a shell command from within MATLAB using the given
% arguments.
%
% usage: runcmd(varargin)
%
% varargin - a series of strings to be concatenated together.
%
% e.g. >> runcmd('ls', '-l', dir);
%
% M Hewitson 16-07-04
%
% $Id$
%
function runcmd(varargin)

  try
  fid = fopen('tmpcmd', 'w+');
  
  fprintf(fid, '#!/bin/bash\n');
  fprintf(fid, 'export PATH=$PATH:${HOME}/bin\n');
  for j=1:nargin
    fprintf(fid, '%s ', varargin{j});
  end
  fprintf(fid, '\n');
  
  fclose(fid);
  
  !chmod +x tmpcmd
  !./tmpcmd

  catch ex
    fprintf(2, '%s\n', ex.getReport());
    fclose(fid);
  end
  
end
