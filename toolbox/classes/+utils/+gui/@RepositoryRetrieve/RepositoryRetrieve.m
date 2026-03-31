% RepositoryRetrieve — legacy Java-Swing retrieval dialog for LTPDA repository.
%
% This class is no longer used. Object retrieval is now handled directly
% inside the LTPDARepositoryQuery uifigure ("Retrieve selected to workspace").
% Retained as a stub for compilation compatibility.
%

classdef RepositoryRetrieve < utils.gui.BaseGUI

  properties
    conn = [];
  end

  methods
    function obj = RepositoryRetrieve(varargin) %#ok<VANUS>
      % No-op stub.
    end
  end

  methods (Access = protected)
    function cb_guiClosed(varargin) %#ok<VANUS>
    end
  end

end
