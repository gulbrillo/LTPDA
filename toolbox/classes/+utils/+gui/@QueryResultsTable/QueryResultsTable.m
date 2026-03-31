% QueryResultsTable is a graphical user interface for query the LTPDA repository.
%
% CALL: QueryResultsTable
%

classdef QueryResultsTable < utils.gui.BaseGUI
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function mainGUI = QueryResultsTable(parent, jStmt, jQuery)
      
      jResult = jStmt.executeQuery(jQuery);
      
      % call super class
      mainGUI@utils.gui.BaseGUI('mpipeline.repository.QueryResultsTableDialog', parent, false, jResult, jQuery, false);
      mainGUI.gui.setUsedConn(jStmt.getConnection());
      
      % We have to remove the Connection, the Result and the Query String
      % from the GUI before we can destroy the GUI. --> Super class can't
      % delete the GUI.
      mainGUI.baseDelOnExit = false;
      
      %--- called when create constructor(s) (press Create Constructors Button)
      addCallback(mainGUI, mainGUI.gui.getCreateConstructors(), 'ActionPerformedCallback', @mainGUI.cb_retrieveObjectsFromTable);
      
    end % End constructor
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Methods (protected)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    
    cb_guiClosed(varargin)
    cb_retrieveObjectsFromTable(varargin)
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (private)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
end



