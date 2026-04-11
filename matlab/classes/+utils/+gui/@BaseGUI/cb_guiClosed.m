% cb_guiClosed callback for closing the BaseGUI class
%
% Parameters:
%       first  - BaseGUI object
%       second - Source object (java Event Object e.g. JButton)
%       third  - Event Object  (java Event e.g. ActionListener)
%

function cb_guiClosed(varargin)
  mainGUI = varargin{1};
  
  if ~isempty(mainGUI) && isvalid(mainGUI)
    fprintf('*** Goodbye from %s\n', class(mainGUI));
    
    for ii=1:numel(mainGUI.javaObjs)
      h = handle(mainGUI.javaObjs(ii), 'callbackproperties');
      set(h, mainGUI.javaEventNames{ii}, []);
    end
    
    % Destroy java objects
    mainGUI.javaObjs = {};
    mainGUI.javaEventNames = {};
    
    %--- It is also necessary to destroy the GUI with the destructor 'delete'
    if mainGUI.baseDelOnExit
      delete(mainGUI);
    end
    
  end
end

