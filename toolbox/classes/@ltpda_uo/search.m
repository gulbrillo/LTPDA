% SEARCH select objects that match the given name.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SEARCH select objects that match the given name using a
%              regular expression (help regexp).
%
% CALL:        out = search(in, 'foo')  % get all objects from <in> called 'foo'
%              out = search(in, 'foo*') % get all objects from <in> with a name like 'foo'
%              out = search(in, pl)
%
% This function returns the handles of the objects that match the regular
% expression. No object copying is done.
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uo', 'search')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = search(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  % Check output
  if nargout == 0
    error('### The search method can not be used as a modifier.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all objects and plists
  [inObjs, objs_invars, rest] = utils.helper.collect_objects(varargin(:), '', in_names);
  [pl, ~, rest]               = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % Combine PLISTs
  pl = applyDefaults(getDefaultPlist, pl);
  
  % Always a deep copy because the method cannot be used as a modifier
  % (see line 31)
  inObjs = copy(inObjs, 1);
  
  % Build a cell array of the input object names
  objNames = {inObjs.name};
  
  %----- Get expression
  % first look in direct inputs
  expr = '';
  if ~isempty(rest)
    expr = rest{1};
  end
  
  % then in plist
  if isempty(expr)
    expr = find_core(pl, 'regexp');
  end
  
  if isempty(expr)
    error('### Please specify an expression to match.');
  end

  % Ensure a string. This allows us to support any object which implements
  % a char method.
  if isobject(expr)
    expr = char(expr);    
    exact = true; % if we have an object then this is an exact search
    % Make sure that the search expression is in the history PLIST
    pl.pset('regexp', expr);
    pl.pset('exact', exact);
  else
    exact = pl.find_core('exact');
  end
  
  if exact
    res = strcmp(objNames, expr);
  else
    res = regexp(objNames, expr);
  end
  
  % Make sure that the search expression is in the history PLIST
  pl.pset('regexp', expr);
  
  % Get indices
  outObjs = [];
  for j=1:numel(res)
    if exact
      if res(j)
        inObjs(j).addHistory(getInfo('None'), pl, objs_invars(j), inObjs(j).hist);
        outObjs = [outObjs inObjs(j)];
      end
    else
      if ~isempty(res{j})
        % Append history
        inObjs(j).addHistory(getInfo('None'), pl, objs_invars(j), inObjs(j).hist);
        outObjs = [outObjs inObjs(j)];
      end
    end
  end
  
  if isempty(outObjs)
    warning('LTPDA:ltpda_uo:search', 'No objects found matching search string [%s]', expr);
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, outObjs);
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
  ii.setModifier(false);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist();
  
  % regexp
  p = param({'regexp', 'A string specifying the regular expression'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % exact
  p = param({'exact', 'A boolean specifying to look for an exact match or not'}, paramValue.FALSE_TRUE);
  pl.append(p);
   
end

