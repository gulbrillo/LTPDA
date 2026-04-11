% WARNDLG Create and open warn dialog box.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: WARNDLG Create and open warn dialog box
%
% CALL:        warnMsgDlg(msg, title)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function warnDlg(msg, title)
  
  if nargin == 1
    title = 'Warning Dialog';
  end
  
  warndlg(msg, title, 'modal');
end
