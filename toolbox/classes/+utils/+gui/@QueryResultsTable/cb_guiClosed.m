% cb_guiClosed callback for closing the QueryResultsTable GUI
%
% Parameters:
%       first  - QueryResultsTable object
%       second - Source object (here: QueryResultsTableDialog)
%       third  - Event Object  (here: WindowEvent)
%

function cb_guiClosed(varargin)
  mainGUI = varargin{1};
  
  if ~isempty(mainGUI) && isvalid(mainGUI)
    
    % Call super class
    cb_guiClosed@utils.gui.BaseGUI(varargin{:});
    
    % Remove the connection object from the GUI
    mainGUI.gui.setUsedConn([]);
    mainGUI.gui.setResults([]);
    
    %--- It is also necessary to destroy the GUI with the destructor 'delete'
    delete(mainGUI);
    
  end
end
