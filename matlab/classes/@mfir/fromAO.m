% create FIR filter from magnitude of input AO/fsdata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    mfirFromAO
%
% DESCRIPTION: create FIR filter from magnitude of input AO/fsdata
%
% CALL:        f = mfirFromAO(a, pli, version, algoname)
%
% PARAMETER:   a:        Analysis object
%              pli:      Parameter list object
%              version:  cvs version string
%              algoname: The m-file name (use the mfilename command)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function filt = fromAO(filt, pli)
  
  import utils.const.*
  
  ii = mfir.getInfo('mfir', 'From AO');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  
  % Get parameters
  a      = find_core(pl, 'AO');
  N      = find_core(pl, 'N');
  win    = find_core(pl, 'Win');
  method = find_core(pl, 'method');
  
  if ischar(win)
    name = win;
    wlen = pl.find_core('length');
    % if the plist contains a window length (like history plists do), use
    % it; otherwise use the filter order N.
    if isempty(wlen)
      wlen = N;
    end
    
    if strcmpi(name, 'kaiser')
      psll = pl.find_core('psll');
      win = specwin(name, wlen, psll);
    else
      win = specwin(name, wlen);
    end
  end
  
  % Check that a.data is a fsdata object
  if ~isa(a.data, 'fsdata')
    error('### Please use an analysis object with a fsdata data object to create a mfir object.');
  end
  
  fs = a.data.fs;
  f  = a.data.getX;
  xx = abs(a.data.getY);
  
  ffm = f/(fs/2);
  switch lower(method)
    case 'frequency-sampling'
      % check window
      if ischar(win)
        if strcmpi(win, 'kaiser')
          win = specwin(win, N+1, win.psll);
        else
          win = specwin(win, N+1);
        end
      end
      
      if length(win.win) ~= N+1
        warning('!!! resizing window function to match desired filter order.');
        if strcmpi(win.type, 'Kaiser')
          win = specwin(win.type, N+1, win.psll);
        else
          win = specwin(win.type, N+1);
        end
      end
      utils.helper.msg(msg.OPROC2, 'designing filter using frequency-sampling method [help fir2]');
      mtaps = fir2(N, ffm, xx, win.win);
    case 'least-squares'
      error('### this design method is not working properly yet.');
      if mod(length(ffm),2)
        ffm = ffm(1:end-1);
        xx  = xx(1:end-1);
      end
      utils.helper.msg(msg.OPROC2, 'designing filter using least-squares method [help firls]');
      mtaps = firls(N, ffm, xx);
    case 'parks-mcclellan'
      error('### this design method is not working properly yet.');
      utils.helper.msg(msg.OPROC2, 'designing filter using Parks-McClellan method [help firpm]');
      mtaps = firpm(N, ffm, xx);
    otherwise
      error('### unknown filter design method.');
  end
  
  % Make mfir object
  filt.fs      = fs;
  filt.a       = mtaps;
  filt.gd      = (filt.ntaps+1)/2;
  filt.histout = zeros(1,filt.ntaps-1);
  
  % Override some properties of the input plist
  if isempty(pl.find_core('name'))
    pl.pset('name', sprintf('fir(%s)', a.name));
  end
  if isempty(pl.find_core('description'))
    pl.pset('description', a.description);
  end
  
  % Add history
  pl.remove('AO'); % because the input AO goes in the history
  filt.addHistory(ii, pl, [], a.hist);
  
  % Set object properties
  filt.setObjectProperties(pl);
  
end % function f = mfirFromAO(a, pli, version, algoname)
