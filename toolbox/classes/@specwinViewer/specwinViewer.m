% SPECWINVIEWER is a graphical user interface for viewing specwin objects.
%
% CALL: specwinViewer
%       specwinViewer(h) % build the model viewer in the figure with handle, h.
%

classdef specwinViewer < handle

  properties
    handle      = [];
    signals     = [];
  end
  properties (SetAccess=private, GetAccess=private)
    Gproperties = [];
    SigSelected = [];
  end
  
  methods
    function mainfig = specwinViewer(varargin)
      % Build the main figure
      mainfig = buildMainfig(mainfig, varargin{:});      
      % Make the GUI visible.
      set(mainfig.handle,'Visible','on')
    end
  end % End public methods

  methods (Static=true)
    % Main figure
    varargout = cb_mainfigClose(varargin)  
    varargout = cb_selectWindow(varargin)
    varargout = cb_plotTime(varargin)
    varargout = cb_plotFreq(varargin)
    varargout = plotWindow(varargin)
    varargout = cb_plot(varargin)
  end
  
  methods (Access = private)    
    varargout = buildMainfig(varargin);
  end
  
  methods (Access = public)
  end
  
end

% END
