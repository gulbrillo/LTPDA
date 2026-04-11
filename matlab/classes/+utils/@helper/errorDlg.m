% ERRORDLG Create and open error dialog box.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ERRORDLG Create and open error dialog box
%
% CALL:        errorMsgDlg(msg, title)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function errorDlg(msg, title)
  
  if nargin == 1
    title = 'Error Dialog';
  end
  
  errordlg(msg, title, 'modal');
end
