% MODULES helper class for LTPDA extension modules.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MODULES helper class for LTPDA extension modules.
%
% To see the available static methods, call
%
% >> methods utils.modules
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef modules
  
  %------------------------------------------------
  %--------- Declaration of Static methods --------
  %------------------------------------------------
  methods (Static)
    
    varargout = buildModule(varargin)
    varargout = moduleInfo(varargin)
    varargout = makeMethod(varargin)
    varargout = releaseModule(varargin)
    
    varargout = getExtensionDirs(varargin)
    
    varargout = installExtensions(varargin)
    varargout = installExtensionsForDir(varargin)
    varargout = uninstallExtensions(varargin)
    varargout = uninstallExtensionsForDir(varargin)
    
    varargout = generateVCSHash(varargin)
    varargout = generateHash(varargin)
    varargout = copyHashFile(varargin)
    
  end
  
end
% END
