% RECREATEPLOT given a 'script' plist resulting from a call to
% utils.plottools.consolidatePlot, this will extract the plot script and
% execute it to recreate a plot.
% 
% CALL:
%                   recreatePlot(pl);
%               c = recreatePlot(pl);
%       [c, hfig] = recreatePlot(pl);
% 
% INPUTS:
%           pl - the script plist
% 
% OUTPUTS:
%             c - the original collection object which contains the plotted
%                 objects
%          hfig - the figure handle of the new figure
% 
% 
function [c, hfig] = recreatePlot(pl)
  
  script = pl.find('PLOT_SCRIPT');
  
  if isempty(script)
    error('This collection is not the result of a plot consolidation.');
  end
  
  now = time();
  fcnName = sprintf('reproducePlot%s', now.format('HHMMSS'));
  outdir  = tempdir;
  
  outfile = writeScript(fcnName, outdir, script);
  
  cpath = pwd();
  try
    [path, name, ext] = fileparts(outfile);
    cd(path);
    [c, hfig] = feval(name);
  catch
    cd(cpath);
  end
  
  cd(cpath);
  delete(outfile);
  
end

% Write script to file in the given directory
function outfile = writeScript(fcnName, outdir, script)
  
  outfile = fullfile(outdir, sprintf('%s.m', fcnName));
  
  fd = fopen(outfile, 'w+');
  if fd < 0
    error('Failed to open %s for writing', outfile);
  end
  
  try
    
    fprintf(fd, '%s', script);
    
  catch Me
    fclose(fd);
    rethrow(Me);
  end
  
  fclose(fd);
  
end