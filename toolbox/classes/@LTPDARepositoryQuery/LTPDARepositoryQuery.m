% LTPDARepositoryQuery is a graphical user interface for query the LTPDA repository.
%
% CALL: LTPDARepositoryQuery
%

classdef LTPDARepositoryQuery < utils.gui.BaseGUI
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function mainGUI = LTPDARepositoryQuery(varargin)
      
      % Get a connection from the database connection manager
      conn = LTPDADatabaseConnectionManager().connect();

      % Make a gui with a icon on the taskbar
      frame = javaObjectEDT('javax.swing.JFrame', 'LTPDA Repository Query Dialog');
      frame.setUndecorated(true);
      frame.setVisible(true);
      frame.setLocationRelativeTo([]);
      
      % call super class
      mainGUI@utils.gui.BaseGUI('mpipeline.repository.RepositoryQueryDialog', frame, false, conn, false);
      
      % We have to remove the connection from the GUI before we can destroy
      % the GUI --> Super class can't delete the GUI.
      mainGUI.baseDelOnExit = false;
      
      %--- called when execute query (press execute button)
      addCallback(mainGUI, mainGUI.gui.getExecuteBtn(), 'ActionPerformedCallback', @mainGUI.cb_executeQuery);
      
    end % End constructor
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Methods (protected)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    
    cb_guiClosed(varargin)
    cb_executeQuery(varargin)
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (private)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
end


