% cb_addExtensionPath callback for adding a extensions path
%
% Parameters:
%       first  - LTPDAprefs object
%       second - Source object (here: JButton)
%       third  - Event Object (here: ActionEvent)
%

function cb_addExtensionPath(varargin)
  disp('adding path');
  ltpdaPrefs = varargin{1};
  newPath = char(ltpdaPrefs.gui.getPrefsTabPane().getExtensionsPanel().getNewPathTextField().getText());
  if ~isempty(newPath)
    utils.modules.installExtensionsForDir(newPath);
  end
end
