% CONSOLIDATEPLOT creates a collection object from the objects contained
% within the specified figure handle, submits that collection, creates a
% script which will download that collection and reproduce the specified
% plot. The script is stored in a plist which is also submitted to the
% repository. Finally, the repository details and object IDs are shown on
% the figure.
% 
% CALL:
%           consolidatePlot(gcf)
%           consolidatePlot(hfig)
%           consolidatePlot(hfig, repo_pl)
%       c = consolidatePlot(hfig, repo_pl)
% 
% INPUTS:
%           hfig - a valid figure handle which was produced with ao/iplot
%        repo_pl - a repository plist (hostname, database, etc)
% 
% OUTPUTS:
%           c - the submitted collection. The procinfo also contains the
%               script to reproduce the plot as well as the submitted
%               object ID.
% 
% 
% 
function c = consolidatePlot(varargin)
  
  error(['Because of MATLAB new graphics system is this function obsolete.\n', ...
    'Please use one of the following functions:\n', ...
    ' - utils.plottools.submitFigure()\n', ...
    ' - utils.plottools.retrieveFigure()\n'], '');
  
end
