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
  
  warning('off', 'MATLAB:JavaEDTAutoDelegation')
  javax.swing.JOptionPane.showMessageDialog('', msg, title, javax.swing.JOptionPane.WARNING_MESSAGE)
  warning('on', 'MATLAB:JavaEDTAutoDelegation')
end
