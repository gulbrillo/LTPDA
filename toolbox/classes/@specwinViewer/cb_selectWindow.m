function cb_selectWindow(varargin)
  
  mainfig = varargin{end};
  
  
  etxt = findobj(mainfig.handle, 'Tag', 'WindowPSLL');
  wsel = findobj(mainfig.handle, 'Tag', 'WindowSelect');
  
  idx  = get(wsel, 'Value');
  wins = get(wsel, 'String');
  win  = wins{idx};
  
  
  if strcmpi(win, 'Kaiser')
    set(etxt, 'Enable', 'on');
  else
    set(etxt, 'Enable', 'off');
  end
  
  specwinViewer.plotWindow(mainfig, 'Time-domain');
  
end
