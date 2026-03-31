% cb_retrieveObjectsFromTable callback for retrieving objects
%
% Parameters:
%       first  - QueryResultsTable object
%       second - Source object (here: JButton)
%       third  - Event Object  (here: ActionEvent)
%

function cb_retrieveObjectsFromTable(varargin)
  mainGUI = varargin{1};
  
  jResultTable = mainGUI.gui.getResultsTable();
  jColNames    = mainGUI.gui.getColNames();
  jObj_id_col  = jColNames.indexOf('obj_id');
  
  if (jObj_id_col == -1)
    msg = 'The results must contain the field ''obj_id'' in order to create constructor blocks.';
    utils.helper.errorDlg(msg, 'Fields error');
    error(msg);
  end
  
  objIDs = [];
  jRows = jResultTable.getSelectedRows();
  
  jModel = jResultTable.getModel();
  for kk = 1:numel(jRows)
    objID = jModel.getValueAt(jRows(kk), jObj_id_col);
    objIDs = [objIDs, objID];
  end
  
  utils.gui.RepositoryRetrieve(mainGUI.gui, mainGUI.gui.getUsedConn(), objIDs);
  
end
