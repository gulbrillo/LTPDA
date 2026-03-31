function ltpda_specwin_viewer_close(varargin)
% Callback executed when the GUI is closed

disp('* Goodbye from the LTPDA Spectral Window Viewer *')
delete(varargin{1})

end

