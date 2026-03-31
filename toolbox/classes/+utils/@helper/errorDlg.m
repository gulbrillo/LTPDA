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
  
  warning('off', 'MATLAB:JavaEDTAutoDelegation')
  javax.swing.JOptionPane.showMessageDialog('', msg, title, javax.swing.JOptionPane.ERROR_MESSAGE)
  warning('on', 'MATLAB:JavaEDTAutoDelegation')
end
