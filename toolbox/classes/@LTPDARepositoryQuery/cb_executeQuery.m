% cb_executeQuery callback for executing the query
%
% Parameters:
%       first  - LTPDARepositoryQuery object
%       second - Source object (here: JButton)
%       third  - Event Object  (here: ActionEvent)
%

function cb_executeQuery(varargin)
  mainGUI = varargin{1};
  
  % Get query from the query text field
  jQuery = mainGUI.gui.getQueryTxtField().getText();
  
  % Get used connection from the GUI
  conn = mainGUI.gui.getRepoConnection;
  
  jStmt = conn.createStatement();
  
  utils.gui.QueryResultsTable(mainGUI.gui.getParent, jStmt, jQuery);
  
end
