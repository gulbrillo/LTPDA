% cb_removeExtensionPath callback for removing a extensions path
%
% Parameters:
%       first  - LTPDAprefs object
%       second - Source object (here: JButton)
%       third  - Event Object (here: ActionEvent)
%

function cb_removeExtensionPath(varargin)
  disp('removing path');
  ltpdaPrefs  = varargin{1};
  removePaths = char(ltpdaPrefs.gui.getPrefsTabPane().getExtensionsPanel().getRemovePaths());
  if ~isempty(removePaths)
    for ii =1:size(removePaths,1)
      p = strtrim(removePaths(ii,:));
      utils.modules.uninstallExtensionsForDir(p);
    end
  end
end
