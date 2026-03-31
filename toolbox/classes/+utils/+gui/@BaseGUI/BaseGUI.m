% BaseGUI — legacy base class for Java-Swing-based LTPDA GUIs.
%
% This class was the base for all Java-backed LTPDA GUIs. In R2025a those
% GUIs have been rewritten using uifigure and this class is no longer used.
% It is retained as a stub so that any extension code that references it
% compiles without error.
%

classdef BaseGUI < handle

  properties
    gui            = [];
    javaObjs       = {};
    javaEventNames = {};
    baseDelOnExit  = true;
  end

  methods
    function obj = BaseGUI(varargin) %#ok<VANUS>
      % No-op stub — Java GUI backend no longer available in R2025a.
    end

    function addCallback(~, varargin) %#ok<VANUS>
    end
  end

  methods (Access = protected)
    function cb_guiClosed(varargin) %#ok<VANUS>
    end
  end

end
