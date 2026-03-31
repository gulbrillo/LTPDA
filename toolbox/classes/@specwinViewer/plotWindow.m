function plotWindow(varargin)
  
  if nargin == 2
    mainfig  = varargin{end-1};
    plotType = varargin{end};
    ax       = getappdata(mainfig.handle, 'axes');
  elseif nargin == 3
    ax       = varargin{1};    
    mainfig  = varargin{2};
    plotType = varargin{3};
  end
  
  
  info    = findobj(mainfig.handle, 'Tag', 'InfoDisplay');
  
  % get window type
  winTxt = findobj(mainfig.handle, 'Tag', 'WindowSelect');
  wins   = get(winTxt, 'String');
  win    = wins{get(winTxt, 'Value')};
  
  % Get window size
  sizeTxt = findobj(mainfig.handle, 'Tag', 'WindowSize');
  winlen  = str2num(get(sizeTxt, 'String'));
  
  if strcmpi(win, 'Kaiser')
    % get psll
    psllTxt = findobj(mainfig.handle, 'Tag', 'WindowPSLL');
    psll    = str2num(get(psllTxt, 'String'));
    w = specwin(win, winlen, psll);
    cstr = sprintf('specwin(''%s'', %d, %f)', win, winlen, psll);
  else
    w = specwin(win, winlen);
    cstr = sprintf('specwin(''%s'', %d)', win, winlen);
  end
  
  consTxt = findobj(mainfig.handle, 'Tag', 'ConstructorDisplay');
  set(consTxt, 'String', cstr);
  
  
  titleStr  = '';
  legendStr = '';
  
  switch plotType
    case 'Time-domain'
      hl = plot(ax, 1:length(w.win), w.win);
      xlabel('sample');
      ylabel('amplitude');
    case 'Freq-domain'
      % Freq response
      f = linspace(-30,30,1000);
      r = zeros(size(f));
      N = length(w.win);
      
      % do dft
      for j=1:length(f)
        k = [0:N-1].';
        r(j) = (w.win * exp(-2*pi*1i*f(j)*k/N) )./w.ws;
      end
      
      % convert to dB
      dbr = 20*log10(abs(r));    hl = plot(ax, f, dbr);
      xlabel('bin');
      ylabel('amplitude [dB]');
  end
  
  col = [0.8 0.1 0.1];
  set(hl, 'Color', col);
  titleStr = [titleStr, utils.plottools.label(w.type), ', '];
  titleStr = titleStr(1:end-2);
  title(sprintf('Window: %s', titleStr));
  axis tight
  grid on
  
  
  % Info string
  lstr = [sprintf('alpha = %g\n', w.alpha)...
    sprintf('psll = %g\n', w.psll)...
    sprintf('rov = %g\n', w.rov)...
    sprintf('nenbw = %g\n', w.nenbw)...
    sprintf('w3db = %g\n', w.w3db)...
    sprintf('flatness = %g\n', w.flatness)];
  legendStr = [legendStr cellstr(lstr)];
  set(info, 'String', legendStr);
  
  
end
