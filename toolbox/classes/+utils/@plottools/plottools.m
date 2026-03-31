% PLOTTOOLS class for tools to manipulate the current object/figure/axis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLOTTOOLS class for tools to manipulate the current
%              object/figure/axis.
%
% PLOTTOOLS METHODS:
%
%     Static methods:
%       yticks      - Set the input vector as the y-ticks of the current axis
%       xticks      - Set the input vector as the x-ticks of the current axis
%
%       zscale      - Set the Z scale of the current axis
%       yscale      - Set the Y scale of the current axis
%       xscale      - Set the X scale of the current axis
%
%       zaxis       - Set the Z axis range of the current figure
%       yaxis       - Set the Y axis range of the current figure
%       xaxis       - Set the X axis range of the current figure
%
%       msuptitle   - Puts a title above all subplots
%       islinespec  - Checks a string to the line spec syntax
%       label       - makes the input string into a suitable string
%                     for using on plots.
%
%       legendAdd   - Add a string to the current legend
%       cscale      - Set the color range of the current figure
%
%       allyscale   - Set all the Y scales on the current figure
%       allylabel   - Set all the y-axis labels on the current figure
%       allyaxis    - Set all the yaxis ranges on the current figure
%       allxscale   - Set all the x scales on the current figure
%       allxlabel   - Set all the x-axis labels on the current figure
%       allxaxis    - Set all the x scales on the current figure
%       allgrid     - Set all the grids to ['on'|'off']
%
% HELP:        To see the available static methods, call
%              >> methods utils.plottools
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef plottools
  
  %------------------------------------------------
  %--------- Declaration of Static methods --------
  %------------------------------------------------
  methods (Static)
    
    %-------------------------------------------------------------
    % List other methods
    %-------------------------------------------------------------
    
    yticks(v) % Set the input vector as the y-ticks of the current axis
    xticks(v) % Set the input vector as the x-ticks of the current axis
    
    zscale(scale) % Set the Z scale of the current axis
    yscale(scale) % Set the Y scale of the current axis
    xscale(scale) % Set the X scale of the current axis
    
    zaxis(x1,x2) % Set the Z axis range of the current figure
    yaxis(y1,y2) % Set the Y axis range of the current figure
    xaxis(x1,x2) % Set the X axis range of the current figure
    
    hout = msuptitle(str)       % Puts a title above all subplots
    varargout = islinespec(str) % Checks a string to the line spec syntax
    s = label(si)               % makes the input string into a suitable string
    % for using on plots.
    
    legendAdd(varargin) % Add a string to the current legend
    cscale(y1,y2) % Set the color range of the current figure
    
    allyscale(scale) % Set all the Y scales on the current figure
    allylabel(label) % Set all the y-axis labels on the current figure
    allyaxis(y1, y2) % Set all the yaxis ranges on the current figure
    allxscale(scale) % Set all the x scales on the current figure
    allxlabel(label) % Set all the x-axis labels on the current figure
    allxaxis(x1, x2) % Set all the x scales on the current figure
    allgrid(state)   % Set all the grids to ['on'|'off']
    varargout = allMarkers(varargin)
    varargout = allLines(varargin)
    
    output_txt = datacursormode(obj, event_obj)
    
    backupDefaultPlotSettings()
    restoreDefaultPlotSettings()
    
    varargout = convertXunits(varargin)
    
    varargout = getLegends(varargin)
    varargout = getAxes(varargin)
    varargout = hold(varargin)
    varargout = box(varargin)
    varargout = xlim(varargin)
    varargout = ylim(varargin)
    varargout = fixAxisLabel(varargin)
    varargout = errorbarxy(varargin)
    varargout = adjustErrorbarTick(varargin)
    varargout = allowedLinestyles(varargin)
    varargout = allowedMarkers(varargin)
    varargout = setLegendLocation(varargin) % set legend location for the given figure
    
    varargout = addPlotProvenance(varargin)
    varargout = addRepositoryPatch(varargin)  
    varargout = consolidatePlot(varargin)
    
    varargout = makeDraft(varargin)
    
    varargout = cacheObjectInUserData(varargin)
    varargout = submitFigure(varargin)
    varargout = retrieveFigure(varargin)
    
    varargout = verticalLine(varargin)
    varargout = horizontalLine(varargin)
    
  end % End static methods
  
end

