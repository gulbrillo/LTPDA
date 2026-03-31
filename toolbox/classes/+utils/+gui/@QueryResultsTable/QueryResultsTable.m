% QueryResultsTable — legacy Java-Swing results table for LTPDA repository queries.
%
% This class is no longer used. Query results are now displayed directly
% inside the LTPDARepositoryQuery uifigure via a uitable.
% Retained as a stub for compilation compatibility.
%

classdef QueryResultsTable < utils.gui.BaseGUI

  methods
    function obj = QueryResultsTable(varargin) %#ok<VANUS>
      % No-op stub.
    end
  end

  methods (Access = protected)
    function cb_guiClosed(varargin) %#ok<VANUS>
    end
    function cb_retrieveObjectsFromTable(varargin) %#ok<VANUS>
    end
  end

end
