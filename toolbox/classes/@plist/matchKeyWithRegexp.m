% MATCHKEYWITHREGEXP returns a logical array with the same size of the parametes with a 1 if the input string matches to the key name(s) and a 0 if not.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MATCHKEYWITHREGEXP returns a logical array with the same
%              size of the parametes with a 1 if the input string matches
%              to the key name(s) and a 0 if not. The input string can have
%              regular expression pattern(s).
%
% CALL:        matches = matchKey(pl, 'expr')
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'matchKeyWithRegexp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = matchKeyWithRegexp(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check inputs
  if nargin ~= 2
    error('### This method needs two inputs. First argument mustbe the PLIST and second the key you want to check');
  end
  if ~isa(varargin{1}, 'plist')
    error('### The first input must be the PLIST.');
  end
  if ~ischar(varargin{2})
    error('### The second input must be the regular expression.');
  end
  
  pl   = varargin{1};
  expr = varargin{2};
  if ~isempty(pl.params)
    dkeys = {pl.params(:).key};
  else
    dkeys = {''};
  end
  
  % Get value we want
  if iscellstr(dkeys)
    % 'old' case without alternatives
    matches = localRegexpi(dkeys, expr);
  else
    matches = false(size(dkeys));
    % 'new' case with alternatives
    for ii=1:numel(dkeys)
      m = localRegexpi(dkeys{ii}, expr);
      matches(ii) = any(m);
    end
  end
  varargout{1} = matches;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function match = localRegexpi(dkeys, expr)
  dkeys = cellstr(dkeys);
  % Check that the 'expr' starts with a '^'
  if expr(1) ~= '^'
    expr = strcat('^', expr);
  end
  % Check that the 'expr' ends with a '$'
  if expr(end) ~= '$'
    expr = strcat(expr, '$');
  end
  m = regexpi(dkeys, expr, 'match');
  match = ~cellfun(@isempty, m);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.internal, '', sets, pl);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pl = getDefaultPlist()
  pl = plist();
end

