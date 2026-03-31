% HTMLADDHELP returns the help of an function as a HTML text.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HTMLADDHELP returns the help of an function as a HTML text
%              and highlight the method name in red.
%
% CALL:        html = docHelper.htmlAddHelp(cl, fcn)
%         or
%              docHelper.htmlAddHelp(fid, cl, fcn)
%
% INPUTS:      cl  - String of the class name
%              fcn - Strin of the function name
%              fid - integer file identifier
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function html = htmlAddHelp(varargin)
  
  if nargin==3
    fid       = varargin{1};
    className = varargin{2};
    fcnName   = varargin{3};
  elseif nargin == 2
    fid       = [];
    className = varargin{1};
    fcnName   = varargin{2};
  else
    error('### Unknown number of inputs');
  end
  
  html = help(sprintf('%s/%s', className, fcnName));
  
  % Replace
  [~, filename, fileExt]  = fileparts(fopen(fid));
  reg = sprintf('matlab:utils.helper.displayMethodInfo\\(''\\w*''\\s*,\\s*''%s''\\)', fcnName);
  html = regexprep(html, reg, strcat(filename, fileExt, '#down'));
  
  % Replace special characters
  html = docHelper.htmlRepSpecChar(html);
  
  % cover a link if the method name is inside the link. For example:
  % <a href="matlab:web('http://www.gnuplot.info/','-browser')">http://www.gnuplot.info/</a>
  % <a href="matlab:utils.helper.displayMethodInfo('ao', 'ao')">parameter list</a>
  exp = '<a[^>]*>[^<]*</a>';
  hits = regexp(html, exp, 'match');
  html = regexprep(html, exp, '@@@');
  
  % highlight the method in red
  html = regexprep(html, sprintf('\\<%s\\>', fcnName), sprintf('<span class="helptopic">%s</span>', fcnName), 'preservecase');
  
  % recover the link
  for ii=1:numel(hits)
    html = regexprep(html, '@@@', hits{ii}, 1);
  end
  
  % Add the html <pre> tag around the help
  html = sprintf('<pre>%s</pre>\n', html(1:end-1));
  
  if ~isempty(fid);
    fprintf(fid, '%s', html);
  end
  
end
