function ltpda_specwin_viewer_wintype(varargin)
% Callback executed when the user selects a window


etxt = findobj('Tag', 'LTPDA_specwin_viewer_PSLL');
wsel = findobj('Tag', 'LTPDA_specwin_viewer_WinType');

idx  = get(wsel, 'Value');
wins = get(wsel, 'String');
win  = wins{idx};


if strcmpi(win, 'Kaiser')
  set(etxt, 'Enable', 'on');
else
  set(etxt, 'Enable', 'off');
end



end

