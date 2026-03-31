% GNUPLOT a gnuplot interface for AOs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: IPLOT provides an intelligent plotting tool for LTPDA.
%
% CALL:               filenames = gnuplot(a,pl)
%
% INPUTS:      pl   - a parameter list
%              a    - input analysis objects
%
% OUTPUTS:     filenames - if gnuplot is configured to output files, then
%                          the filenames are returned here.
%
% 
% NOTE: this method requires gnuplot to be installed on the system. The
% path to the gnuplot binary can be set in the input plist with the key
% 'GNUPLOT'.
% 
% gnuplot: <a href="matlab:web('http://www.gnuplot.info/','-browser')">http://www.gnuplot.info/</a>
% 
% AO Plot Info
% ------------
% 
% If an input AO has a filled plotinfo plist, then the options contained in
% therein will overide any other options. The recognised keys are:
% 
%   'linestyle', 'linewidth', 'color', 'marker', 'legend_on'
% 
% The possible values are all those accepted by plot.
% 
% 
% EXAMPLES:
%
% 1) Plot two time-series AOs on the same plot and output to a PDF file
%
%      gnuplot(a1, a2, plist('terminal', 'pdf enhanced', ...
%             'output', outfile, ...
%             'preamble', {'set title "my nice plot"', 'set key outside top right'}, ...
%             'markerscale', 3))
%
% 2) Plot two time-series AOs in subplots. If the AOs have markers set in
%    the plotinfo, they will be scaled in size x3 from default.
%
%    gnuplot(a1, a2, plist('arrangement', 'subplots', 'terminal', 'pdf enhanced', ...
%            'output', outfile, ...
%            'preamble', {'set title "my nice plot"', 'set key outside top right'}, ...
%            'markerscale', 3))
%
% 3) Plot two time-series AOs, each to its own output pdf file.
%
%   gnuplot(a1, a2, plist('arrangement', 'single', 'terminal', 'pdf enhanced', ...
%          'output', outfile, 'outdir', '.', ...
%          'preamble', {'set title "my nice plot"', 'set key outside top right'}, ...
%          'markerscale', 3))
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'gnuplot')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = gnuplot(varargin)
  
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);

  % Apply defaults to plist
  usepl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Loop over input AOs and collect the different types
  [timeAOs, freqAOs, yAOs, xyAOs] = collectAOs(as);
    
  fnames = {};
  % Do time-series
  if ~isempty(timeAOs)
    fnames = [fnames plot_ao_set(timeAOs, usepl)];
  end
  % Do freq-series
  if ~isempty(freqAOs)
    fnames = [fnames plot_ao_set(freqAOs, usepl)];
  end
  
  if ~isempty(xyAOs)
    error('Plotting xy-data objects is not yet supported.');
  end

  if ~isempty(yAOs)
    error('Plotting c-data objects is not yet supported.');
  end
  
  if nargout == 1
    varargout{1} = fnames;
  end
  
  
end

function fnames = plot_ao_set(as,pl)

  fnames = {};
  
  Na = numel(as);
  
  % Parameters
  odir     = pl.find_core('OutputDir');
  output   = pl.find_core('output');
  terminal = pl.find_core('terminal');
  terminalOpts = pl.find_core('terminal options');
  gnuplotBin = pl.find_core('gnuplot');
  
  if isempty(terminal)
    runcmd(gnuplotBin, ' -e "help terminal"');
    return;
  end
  
  if isempty(output)
    output = tempname;
  else
    output = fullfile(odir, output);
  end
  
  %----------------
  % Make filenames
  %----------------
  aTmpFile = tempname;
  % One data file per AO
  tmpData = {};
  for kk = 1:Na
    tmpData  = [tmpData {sprintf('%s_%d.dat', aTmpFile, kk)}];
  end
  % One gnu file
  tmpGnu   = [aTmpFile '.gnu'];
  % Output file
  [path,name,ext] = fileparts(output);
  if isempty(ext)
    output = [output '.' terminal];
  end
  
  utils.helper.msg(utils.const.msg.PROC1, 'Output file: %s', output);
  utils.helper.msg(utils.const.msg.PROC1, 'Plotting %d time-series AOs...', numel(as));

  switch class(as(1).data)
    case 'tsdata'
      fnames = [fnames ts_plot(output, terminal, terminalOpts, tmpGnu, tmpData, as, pl)];
    case 'fsdata'
      fnames = [fnames fs_plot(output, terminal, terminalOpts, tmpGnu, tmpData, as, pl)];
    case 'xydata'
    case 'ydata'
    otherwise
  end
    
  % Clean up tmp files
  for kk = 1:numel(tmpData)
    delete(tmpData{kk});
  end
  delete(tmpGnu);
  
  
end

%--------------------------------------------------------------------------
% Make freq-series plot
%

function fnames = fs_plot(output, terminal, terminalOpts, tmpGnu, tmpData, as, pl)
  
  switch pl.find_core('arrangement')
    case 'single'
      fnames = write_single_freqseries_plot(terminal, terminalOpts, output, tmpGnu, tmpData, as, pl);
    case 'stacked'
      fnames = write_stacked_freqseries_plot(terminal, terminalOpts, output, tmpGnu, tmpData, as, pl);
    case 'subplots'
      error('subplots arrangement for frequency-series is not currently supported');
    otherwise
      fnames = {};
  end  
  
end

%--------------------------------------------------------------------------
% Plots all the freq-series AOs on individual plots.
%
function fnames = write_single_freqseries_plot(terminal, terminalOpts, output, tmpGnu, tmpData, as, pl);

  fnames = {};
  gnuplotBin = pl.find_core('gnuplot');
  Na = numel(as);
  
  % Export data
  for kk=1:Na
    export(as(kk), tmpData{kk}, plist('complex format', 'absdeg'));
  end
  
  % Process each AO  
  for kk=1:Na    
    
    % Are we processing complex data?
    complexData = false;
    if ~isreal(as(kk).y) 
      complexData = true;
    end
    
    [path,name,ext] = fileparts(output);
    ofile = fullfile(path,sprintf('%s_%02d%s',name,kk,ext));
    fnames = [fnames {ofile}];
    
    % Open and write gnu file
    fd = fopen(tmpGnu, 'w+');    
    writeHeader(fd, terminal, terminalOpts, ofile);    
    
    % Need two plots for complex data
    if complexData
      fprintf(fd, 'set multiplot layout 2,1\n');
    end    
    
    
    % Line style
    [color, lwidth, style, pointType, pointScale] = lineStyle(kk, as(kk), pl);
    
    % Axis labels
    fprintf(fd, 'set xlabel "Frequency %s"\n', as(kk).xunits.char);
    fprintf(fd, 'set ylabel "Amplitude %s"\n', fixUnits(as(kk).yunits.char));
    
    % Axis scales
    fprintf(fd, 'set lmargin at screen 0.15\n');
    fprintf(fd, 'unset logscale xy\n');
    fprintf(fd, 'set logscale x\n');
    fprintf(fd, 'set logscale y\n');

    % Preamble
    preamble = pl.find_core('preamble');
    writePreamble(fd, preamble);
    
    % Write the plot line
    fprintf(fd, 'plot "%s"  using 1:2 with %s lt %s lw %d %s %s title "%s"\n', ...
      tmpData{kk}, style, color, lwidth, pointType, pointScale, as(kk).name);
    if complexData      
      fprintf(fd, 'set ylabel "Phase [deg]"\n');
      fprintf(fd, 'unset logscale xy\n');
      fprintf(fd, 'set logscale x\n');
      fprintf(fd, 'plot "%s"  using 1:3 with %s lt %s lw %d %s %s title "%s"\n', ...
        tmpData{kk}, style, color, lwidth, pointType, pointScale, as(kk).name);
    end
    fclose(fd);
    % Run gnuplot
    runcmd(gnuplotBin, tmpGnu);  
  end  
  
end

%--------------------------------------------------------------------------
% Plots all the freq-series AOs on individual plots.
%
function fnames = write_stacked_freqseries_plot(terminal, terminalOpts, output, tmpGnu, tmpData, as, pl);

  fnames = {output};
  
  gnuplotBin = pl.find_core('gnuplot');
  plotErrorbars = pl.find_core('errorbars');
  Na = numel(as);
  
  % Check the yunits
  xlbl = as(1).xunits.char;
  ylbl = as(1).yunits.char;
  ylbl = fixUnits(ylbl);
  for kk=2:Na
    if ~strcmp(ylbl,fixUnits(as(kk).yunits.char))
      ylbl = '[mixed]';
      break;
    end
  end
  
  % Export data
  allReal = true;
  for kk=1:Na
    export(as(kk), tmpData{kk}, plist('complex format', 'absdeg'));
    if ~isreal(as(kk).y)
      allReal = false;
    end
  end
  
  % Open and write gnu file
  fd = fopen(tmpGnu, 'w+');
  
  writeHeader(fd, terminal, terminalOpts, output);

  fprintf(fd, 'set lmargin at screen 0.15\n');
  % Axis labels
  fprintf(fd, 'set xlabel "Frequency %s"\n', xlbl);
  fprintf(fd, 'set ylabel "Amplitude %s"\n', ylbl);
  
  
  % Need two plots for complex data
  if ~allReal
    fprintf(fd, 'set multiplot\n');
    fprintf(fd, 'set size 0.9,0.45\n');
    fprintf(fd, 'set origin 0.05,0.5\n');
  end
  
  fprintf(fd, 'unset logscale xy\n');
  fprintf(fd, 'set logscale x\n');
  fprintf(fd, 'set logscale y\n');
  
  % Preamble
  preamble = pl.find_core('preamble');
  writePreamble(fd, preamble);
  
  % Process real part of each AO
  fprintf(fd, 'plot\\\n');
  hasErrors = ~isempty(as(kk).dy) & plotErrorbars;
  
  for kk=1:Na        
    
    
    % Line style
    [color, lwidth, style, pointType, pointScale] = lineStyle(kk, as(kk), pl);
    % Write the plot line
    if hasErrors
      fprintf(fd, ' "%s"  using 1:2:3 with %s lt %s lw %d %s %s title "%s"', ...
        tmpData{kk}, style, color, lwidth, pointType, pointScale, as(kk).name); 
    else
      fprintf(fd, ' "%s"  using 1:2 with %s lt %s lw %d %s %s title "%s"', ...
        tmpData{kk}, style, color, lwidth, pointType, pointScale, as(kk).name);
    end
    if kk<Na
      fprintf(fd, ',\\\n');
    end
  end  
  
  fprintf(fd, '\n\n');
  
  % Need two plots for complex data
  if ~allReal
    fprintf(fd, 'set ylabel "Phase [deg]"\n');
    fprintf(fd, 'set size 0.9,0.45\n');
    fprintf(fd, 'set origin 0.05,0.1\n');
  
    fprintf(fd, 'unset logscale xy\n');
    fprintf(fd, 'set logscale x\n');
    
    % Preamble
    preamble = pl.find_core('preamble');
    writePreamble(fd, preamble);
    
    % Process real part of each AO
    fprintf(fd, 'plot\\\n');
    for kk=1:Na
      if ~isreal(as(kk).y)
        % Line style
        [color, lwidth, style, pointType, pointScale] = lineStyle(kk, as(kk), pl);
        % Write the plot line
        if hasErrors
          fprintf(fd, ' "%s"  using 1:3:4 with %s lt %s lw %d %s %s title "%s"', ...
            tmpData{kk}, style, color, lwidth, pointType, pointScale, as(kk).name);
        else
          fprintf(fd, ' "%s"  using 1:3 with %s lt %s lw %d %s %s title "%s"', ...
            tmpData{kk}, style, color, lwidth, pointType, pointScale, as(kk).name);          
        end
        if kk<Na
          fprintf(fd, ',\\\n');
        end
      end
    end
  
  end
  
  fclose(fd);
  
  % Run gnuplot
  runcmd(gnuplotBin, tmpGnu);  
  
end


%--------------------------------------------------------------------------
% Make time-series plot

function fnames = ts_plot(output, terminal, terminalOpts, tmpGnu, tmpData, as, pl)
  
  switch pl.find_core('arrangement')
    case 'single'
      fnames = write_single_timeseries_plot(terminal, terminalOpts, output, tmpGnu, tmpData, as, pl);
    case 'stacked'
      fnames = write_stacked_timeseries_plot(terminal, terminalOpts, output, tmpGnu, tmpData, as, pl);
    case 'subplots'
      fnames = write_subplot_timeseries_plot(terminal, terminalOpts, output, tmpGnu, tmpData, as, pl);
    otherwise
      fnames = {};
  end  
  
end


%--------------------------------------------------------------------------
% Plots all time-series AOs on a single x-y plot. If the AOs have different
% yunits, then the label is set to [mixed].
function fnames = write_stacked_timeseries_plot(terminal, terminalOpts, output, tmpGnu, tmpData, as, pl)
  
  fnames = {output};
  
  gnuplotBin = pl.find_core('gnuplot');
  Na = numel(as);
  
  % Check the yunits
  xlbl = as(1).xunits.char;
  ylbl = as(1).yunits.char;
  ylbl = fixUnits(ylbl);
  for kk=2:Na
    if ~strcmp(ylbl,fixUnits(as(kk).yunits.char))
      ylbl = '[mixed]';
      break;
    end
  end
  
  % Export data
  for kk=1:Na
    export(as(kk), tmpData{kk}, plist('complex format', 'absdeg'));
  end
  
  % Open and write gnu file
  fd = fopen(tmpGnu, 'w+');
  
  writeHeader(fd, terminal, terminalOpts, output);

  % Axis labels
  fprintf(fd, 'set xlabel "Time %s"\n', xlbl);
  fprintf(fd, 'set ylabel "Amplitude %s"\n', ylbl);
  
  % Preamble
  preamble = pl.find_core('preamble');
  writePreamble(fd, preamble);
  
  % Process each AO
  fprintf(fd, 'plot\\\n');
  for kk=1:Na    
    % Line style
    [color, lwidth, style, pointType, pointScale] = lineStyle(kk, as(kk), pl);
    % Write the plot line
    fprintf(fd, ' "%s"  using 1:2 with %s lt %s lw %d %s %s title "%s"', ...
      tmpData{kk}, style, color, lwidth, pointType, pointScale, as(kk).name);
    if kk<Na
      fprintf(fd, ',\\\n');
    end
  end  
  fclose(fd);
  
  % Run gnuplot
  runcmd(gnuplotBin, tmpGnu);  
end


%--------------------------------------------------------------------------
% Plots all time-series AOs on a single x-y plot. If the AOs have different
% yunits, then the label is set to [mixed].
function fnames = write_subplot_timeseries_plot(terminal, terminalOpts, output, tmpGnu, tmpData, as, pl)
  
  fnames = {output};
  gnuplotBin = pl.find_core('gnuplot');
  Na = numel(as);

  
  % Export data
  for kk=1:Na
    export(as(kk), tmpData{kk}, plist('complex format', 'absdeg'));
  end
  
  % Open and write gnu file
  fd = fopen(tmpGnu, 'w+');
  
  writeHeader(fd, terminal, terminalOpts, output);
  
  fprintf(fd, 'set multiplot layout %d,1\n', Na);

  
  
  % Process each AO
  for kk=1:Na    
    % Line style
    [color, lwidth, style, pointType, pointScale] = lineStyle(kk, as(kk), pl);
    % Axis labels
    fprintf(fd, 'set xlabel "Time %s"\n', as(kk).xunits.char);
    fprintf(fd, 'set ylabel "Amplitude %s"\n', fixUnits(as(kk).yunits.char));
    % Preamble
    preamble = pl.find_core('preamble');
    writePreamble(fd, preamble);
    % Write the plot line
    fprintf(fd, 'plot "%s"  using 1:2 with %s lt %s lw %d %s %s title "%s"\n', ...
      tmpData{kk}, style, color, lwidth, pointType, pointScale, as(kk).name);
  end  
  fclose(fd);
  
  % Run gnuplot
  runcmd(gnuplotBin, tmpGnu);  
end

%--------------------------------------------------------------------------
% Plots all time-series AOs on a single x-y plot. If the AOs have different
% yunits, then the label is set to [mixed].
function fnames = write_single_timeseries_plot(terminal, terminalOpts, output, tmpGnu, tmpData, as, pl)
  
  fnames = {};
  gnuplotBin = pl.find_core('gnuplot');
  Na = numel(as);
  
  % Export data
  for kk=1:Na
    export(as(kk), tmpData{kk}, plist('complex format', 'absdeg'));
  end
  
  % Process each AO  
  for kk=1:Na    
    
    [path,name,ext] = fileparts(output);
    ofile = fullfile(path,sprintf('%s_%02d%s',name,kk,ext));
    fnames = [fnames {ofile}];
    
    % Open and write gnu file
    fd = fopen(tmpGnu, 'w+');    
    writeHeader(fd, terminal, terminalOpts, ofile);    
    

    % Line style
    [color, lwidth, style, pointType, pointScale] = lineStyle(kk, as(kk), pl);

    % Axis labels
    fprintf(fd, 'set xlabel "Time %s"\n', as(kk).xunits.char);
    fprintf(fd, 'set ylabel "Amplitude %s"\n', fixUnits(as(kk).yunits.char));
    
    % Preamble
    preamble = pl.find_core('preamble');
    writePreamble(fd, preamble);
    
    % Write the plot line
    fprintf(fd, 'plot "%s"  using 1:2 with %s lt %s lw %d %s %s title "%s"\n', ...
      tmpData{kk}, style, color, lwidth, pointType, pointScale, as(kk).name);
    fclose(fd);
    % Run gnuplot
    runcmd(gnuplotBin, tmpGnu);  
  end  
  
end


%--------------------------------------------------------------------------
% Functions for writing the GNUPLOT file.
%

function writeHeader(fd, terminal, terminalOpts, output)
  fprintf(fd, 'set terminal %s %s \n', terminal, terminalOpts);
  if ~isempty(output)
    fprintf(fd, 'set output "%s"\n', output);
  end
  fprintf(fd, 'set key outside\n');
  fprintf(fd, 'set grid xtics ytics\n');
  fprintf(fd, 'set key invert box\n');  
  
end

function writePreamble(fd, preamble)
  
  if ischar(preamble)
    preamble = {preamble};
  end
  for kk=1:numel(preamble)
    fprintf(fd, '%s\n', preamble{kk});
  end
  
end


function [color, lwidth, style, pointType, pointScale] = lineStyle(kk, as, pl)
  
  info = as.plotinfo;
  if ~isempty(info)
    color   = info.find_core('color');
    lwidth  = info.find_core('linewidth');
    marker = info.find_core('marker');
  else
    color  = [];
    lwidth = [];
    marker = [];
  end
  
  % Color for this ao
  color = mcol2gcol(kk, color);
  
  % line width
  if isempty(lwidth)
    lwidth = 2;
  end
  
  % Marker
  showErrors = ~isempty(as.dy) && pl.find_core('errorbars');  
  [style, pointType] = getMarker(marker, ~showErrors);
  pointScale = getPointScale(pl.find_core('markerscale'), pointType);
end

function [style, pointType] = getMarker(marker, noErrors)  
  if noErrors
    if isempty(marker)
      style = 'l';
      pointType = '';
    else
      style = 'lp';
      pointType = sprintf('pt %d', mmarkerTogmarker(marker));
    end
  else
    if isempty(marker)
      style = 'errorlines';
      pointType = '';
    else
      style = 'errorlines';
      pointType = sprintf('pt %d', mmarkerTogmarker(marker));
    end
  end
  
end

function pointScale = getPointScale(size, pointType)

  pointScale = '';
  if pointType > 0  
    if ~isempty(size)
      pointScale = sprintf('ps %d', size);
    end
  end
  
end


% Return a gnuplot point type based on the matlab marker.
% This is terminal dependent and so only works in some cases.
function pt = mmarkerTogmarker(mm)

  switch mm
    case '+'
      pt = 1;
    case 'x'
      pt = 2;
    case 's'
      pt = 4;
    case 'd'
      pt = 5;
    case '^'
      pt = 6;
    otherwise
      pt = 0;
  end  
  
end

% Prepare units for gnuplot
function str = fixUnits(str)
  
  str = strrep(strrep(str, '(', '{'), ')', '}');
  
end


% Returns an RGB color from a MATLAB string color
function col = mcol2gcol(kk, mcol)
  
  if isempty(mcol)
    col = num2str(kk);
    return
  end
  
  if ischar(mcol)
    str = mcol;
    switch str
      case 'r'
        col = 'red';
      case 'g'
        col = 'blue';
      case 'b'
        col = 'blue';
      case 'c'
        col = 'cyan';
      case 'm'
        col = 'magenta';
      case 'y'
        col = 'yellow';
      case 'k'
        col = 'black';
      case 'w'
        col = 'white';
      otherwise
        col = str;
    end
  else
    
    % If we have a matlab rgb vector, we need to conver to a hex for
    % gnuplot
    
    r = dec2hex(round(255*mcol(1)));
    g = dec2hex(round(255*mcol(2)));
    b = dec2hex(round(255*mcol(3)));
    
    col = ['#' r g b];
        
  end
  
  col   = sprintf('rgb "%s"', col);
  
end



%---------------------------------------------------------------------
% This will run a shell command from within MATLAB using the given
% arguments.
%
% usage: runcmd(varargin)
%
% varargin - a series of strings to be concatenated together.
%
%
% e.g. >> runcmd('ls', '-l', dir);
%

function runcmd(varargin)
 
  [fid, message] = fopen('tmpcmd', 'w+');  
  if fid == -1
    error('Failed to write gnuplot command: %s', message);
  end
  
  fprintf(fid, '#!/bin/bash\n');
  fprintf(fid, 'export PATH=$PATH:${HOME}/bin\n');
  for jj = 1:nargin
    fprintf(fid, '%s ', varargin{jj});
  end
  fprintf(fid, '\n');  
  fclose(fid);
  
  system('chmod +x tmpcmd');
  system('./tmpcmd');
  system('rm tmpcmd');
end

%--------------------------------------------------------------------------
% Collect the AOs together by data class
%
function  [timeAOs, freqAOs, yAOs, xyAOs] = collectAOs(as)
  
  timeAOs = [];
  freqAOs = [];
  yAOs    = [];
  xyAOs   = [];
  
  for jj = 1:numel(as)
    
    switch class(as(jj).data)
      case 'tsdata'
        
        timeAOs = [timeAOs as(jj)];
        
      case 'fsdata'
        
        freqAOs = [freqAOs as(jj)];
        
      case 'xydata'
        
        yAOs = [yAOs as(jj)];
        
      case 'cdata'
        
        xyAOs = [xyAOs as(jj)];
        
      otherwise
        utils.helper.warn(utils.const.msg.IMPORTANT, 'Unsupported AO data type [%s]; skipping', class(as(jj).data));
    end % End switch on data type    
  end % End loop over AOs
  
end


%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  
  % General plist for Welch-based, linearly spaced spectral estimators
  pl = plist();
  
  % Binary
  p = param({'gnuplot', ['The path to the gnuplot binary.']},...
    paramValue.STRING_VALUE('/opt/local/bin/gnuplot'));
  pl.append(p);
  
  % Output dir
  p = param({'OutputDir', ['The output directory to be used in the case of writing output files.']},...
    paramValue.STRING_VALUE(''));
  pl.append(p);
  
  % Output file
  p = param({'Output', ['The output filename for the given terminal type.\n'...
    'An empty output will result in the output being sent to the terminal.']},...
    paramValue.STRING_VALUE(''));
  pl.append(p);

  % Terminal type
  p = param({'Terminal', 'Choose one of the gnuplot supported terminal types.'},...
    paramValue.STRING_VALUE('pdf'));
  pl.append(p);
  
  % Terminal Options
  p = param({'Terminal Options', 'Additional terminal options.'},...
    paramValue.STRING_VALUE('color enhanced fsize 14 size 24cm,16cm'));
  pl.append(p);
  
  % Preamble
  p = param({'Preamble', 'A cell-array of gnuplot commands which are inserted before the plotting but after the basic commands.'},...
    paramValue.EMPTY_CELL);
  pl.append(p);
  
  % Show errorbars
  p = param({'errorbars', 'If the AO has errors, plot them as errorbars.'},...
    paramValue.FALSE_TRUE);
  pl.append(p);
  
  
  % Arrangement
  p = param({'Arrangement', ['Chose how to plot multiple AOs:\n'...
    '<ul><li> on one plot (stacked)</li><li>on separate plots (single)</li>'...
    '<li>on subplots (subplots) </li></ul><br>In the case of ''single'', if you use an<br>'...
    'output file, then each file will be appended with a number, e.g., foo_1.pdf, foo_2.pdf.']},...
    {1, {'stacked', 'single', 'subplots'}, paramValue.SINGLE});
  pl.append(p);
  
  % Marker scale
  p = param({'MarkerScale', ['Scale the size of the markers by an integer amount.']},...
    paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  
end
