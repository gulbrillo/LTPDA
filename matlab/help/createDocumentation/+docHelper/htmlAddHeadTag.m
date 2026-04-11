% HTMLADDHEADTAG returns the head tag <HEAD> and its content for a HTML page.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HTMLADDHEADTAG returns the head tag <HEAD> and its content
%              for a HTML page.
%
% CALL:        html = docHelper.htmlAddHeadTag(title)
%              html = docHelper.htmlAddHeadTag(title, relPathToDocStyle)
%          or
%              docHelper.htmlAddHeadTag(fid, title)
%              docHelper.htmlAddHeadTag(fid, title, relPathToDocStyle)
%
% INPUTS:      title             - String for the title
%              relPathToDocStyle - String of the relative path to the
%              fid               - integer file identifier
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function html = htmlAddHeadTag(varargin)
  
  fid               = [];
  relPathToDocStyle = '';
  if nargin == 1
    htmlTitle = varargin{1};
  elseif nargin == 2
    if isnumeric(varargin{1}) && ~isempty(fopen(varargin{1}))
      fid = varargin{1};
      htmlTitle = varargin{2};
    elseif ischar(varargin{1}) && ischar(varargin{2})
      htmlTitle = varargin{1};
      relPathToDocStyle = varargin{2};
    else
      error('### Please use:\nhtml = docHelper.htmlAddHeadTag(title, relPathToDocStyle)\ndocHelper.htmlAddHeadTag(fid, title)');
    end
  elseif nargin == 3
    fid = varargin{1};
    htmlTitle = varargin{2};
    relPathToDocStyle = varargin{3};
  else
    error('### Unknown number of inputs');
  end
  
  docStyleFile = strcat(relPathToDocStyle, 'docstyle.css');
  
  html = '';
  html = sprintf('%s  <head>\n', html);
  html = sprintf('%s    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n', html);
  html = sprintf('%s    <link rel="stylesheet" href="%s">\n', html, docStyleFile);
  html = sprintf('%s    <title>%s</title>\n', html, htmlTitle);
  html = sprintf('%s  </head>\n', html);
  
  % Add to file
  if ~isempty(fid)
    fprintf(fid, '%s', html);
  end
  
end
