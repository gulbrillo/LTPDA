% cb_guiClosed callback for closing the LTPDARepositoryQuery GUI
%
% Parameters:
%       first  - LTPDARepositoryQuery object
%       second - Source object (here: RepositoryQueryDialog)
%       third  - Event Object  (here: WindowEvent)
%

function cb_guiClosed(varargin)
  mainGUI = varargin{1};
  
  if ~isempty(mainGUI) && isvalid(mainGUI)
    
    % Call super class
    cb_guiClosed@utils.gui.BaseGUI(varargin{:});
    
    % Close connection and remove it from the GUI
    mainGUI.gui.getRepoConnection().close();
    mainGUI.gui.setRepoConnection([]);
    
    %--- It is also necessary to destroy the GUI with the destructor 'delete'
    delete(mainGUI);
    
  end
end
