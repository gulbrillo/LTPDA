% MODELS helper class for built-in model utility functions.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MODELS is a helper class for built-in model utility functions.
%
% To see the available static methods, call
%
% >> methods utils.models
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef models
  
  %------------------------------------------------
  %--------- Declaration of Static methods --------
  %------------------------------------------------
  methods (Static)
    
    
    %-------------------------------------------------------------
    % List other methods
    %-------------------------------------------------------------
    varargout = processModelInputs(varargin)
    varargout = getDefaultPlist(varargin)
    varargout = functionForVersion(varargin)
    varargout = getDescription(varargin)
    varargout = getInfo(varargin)
    varargout = getBuiltinModelSearchPaths(varargin);
    varargout = displayModelOverview(varargin);
    varargout = mainFnc(varargin)
    varargout = makeBuiltInModel(varargin)
    
    %-------------------------------------------------------------
    %-------------------------------------------------------------
    
  end % End static methods
  
  
end

% END