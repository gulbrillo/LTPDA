% BaseGUI is a base class for graphical user interface in LTPDA.
%
% CALL: BaseGUI
%

classdef BaseGUI < handle
  
  properties
    gui            = [];   % Pointer to the java GUI
    javaObjs       = {};   % Array of Java Event Objects e.g. JButton
    javaEventNames = {};   % Array of Java Event Names e.g. ActionPerformedCallback
    baseDelOnExit  = true; % Defines if the base class destroys the object
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function mainGUI = BaseGUI(varargin)
      
      % make a gui
      mainGUI.gui = javaObjectEDT(varargin{:});
      
      %--- called when window is closed
      addCallback(mainGUI, mainGUI.gui, 'WindowClosedCallback', @mainGUI.cb_guiClosed);
      
      % Make gui visible
      mainGUI.gui.setVisible(true);
      
    end % End constructor
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    
    function addCallback(obj, javaObj, javaEventName , matlabCallbackFcn)
      % Register the MATLAB fcn to the java object.
      h = handle(javaObj, 'callbackproperties');
      set(h, javaEventName, {matlabCallbackFcn});
      % Register the callbacks so that we can delete them later when the
      % user close the GUI.
      obj.javaObjs  = [obj.javaObjs,  javaObj];
      obj.javaEventNames = [obj.javaEventNames, javaEventName];
    end
    
    function display(varargin)
    end
    
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



