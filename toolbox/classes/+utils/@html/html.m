% HTML helper class for helpful utility functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HTML is a helper class for helpful html functions.
%
% To see the available static methods, call
%
% >> methods utils.html
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef html

  %------------------------------------------------
  %--------- Declaration of Static methods --------
  %------------------------------------------------
  methods (Static)


    %-------------------------------------------------------------
    % List other methods
    %-------------------------------------------------------------
    
    varargout = pageHeader(varargin)
    varargout = pageFooter(varargin)
    varargout = beginBody(mark)
    varargout = endBody(mark)
    varargout = table(varargin)
    varargout = beginItemize()
    varargout = endItemize()
    varargout = item(text)
    varargout = title(text,level)
    varargout = paragraph(varargin)
    varargout = figure(filename,varargin)
    varargout = label(text)
    varargout = reference(label,caption)
    varargout = link(url,caption)
    varargout = lineBreak()
    varargout = center(text)
    varargout = bold(text)
    varargout = color(text,color)
    varargout = comment(text)
    varargout = lineSeparator()


    
    %-------------------------------------------------------------
    %-------------------------------------------------------------

  end % End static methods


end

% END
