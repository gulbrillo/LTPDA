% RepositoryRetrieve is a graphical user interface for query the LTPDA repository.
%
% CALL: RepositoryRetrieve
%

classdef RepositoryRetrieve < utils.gui.BaseGUI
  
  properties
    conn =  []; % Connection for retrieving objects
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function mainGUI = RepositoryRetrieve(parent, conn, objIDs)
      
      % Call super class
      mainGUI@utils.gui.BaseGUI('mpipeline.repository.RepositoryRetrieveDialog', parent, false);
      mainGUI.conn = conn;
      
      % Convert object IDs to a string (separated by a blanks)
      numberStr = sprintf('%d ', objIDs);
      numberStr = strtrim(numberStr);
      
      % We have to handle the Save and Import buttons before we can destroy
      % the GUI.
      mainGUI.baseDelOnExit = false;
      
      % Set number string to the text field.
      mainGUI.gui.getObjectIDsTextField().setText(numberStr);
      
    end % End constructor
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Methods (protected)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    
    cb_guiClosed(varargin)
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (private)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
end



