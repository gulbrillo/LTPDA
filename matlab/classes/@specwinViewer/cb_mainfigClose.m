% CB_MAINFIGCLOSE close callback for LTPDA Specwin Viewer.
%

function cb_mainfigClose(varargin)
  
  mainfig = varargin{end};
  
  disp('* Goodbye from the LTPDA Specwin Viewer *')
  delete(mainfig.handle)
  delete(mainfig)
  % delete 'ans' variable associated with this specwinViewer object
  evalin('base', 'if exist(''ans'', ''var'') && isa(ans, ''specwinViewer''), clear(''ans''); end');
  
end

