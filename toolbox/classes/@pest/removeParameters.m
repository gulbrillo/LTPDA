% REMOVEPARAMETERS removes the named parameters from the pests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: REMOVEPARAMETERS removes the named parameters from the pest.
%
% CALL:
%          pout = removeParameters('p1', 'p2', ...);
%          pout = removeParameters({'p1', 'p2'});
%          pout = removeParameters(LPFParam, LPFParam);
%          pout = removeParameters([LPFParam, LPFParam]);
%
% Warning: this does not treat properly the covariance matrix.
% Indeed, the covariance matrix will be emptied by this operation.
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'removeParameters')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = removeParameters(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all PESTs and plists
  [ps, p_invars, rest] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
  [pls,  invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
  
  % apply defaults
  pls = applyDefaults(getDefaultPlist(), pls);
  
  names = pls.find_core('params');
  if iscellstr(names)
    % do nothing
  elseif ischar(names)
    names = {names};
  elseif isa(names, 'LTPDANamedItem')
    names = char(names);    
  else
    error('Unknown type [%s] for parameters', class(names));
  end
  
  if ~isempty(rest)
    for kk=1:numel(rest)
      if ischar(rest{kk})
        names = [names rest(kk)];
      elseif iscellstr(rest{kk})
        names = [names rest{kk}];
      elseif isa(rest{kk}, 'LTPDANamedItem')
        names = [names cellstr(char(rest{kk}))];
      else
        warning('Additional input of class [%s] ignored', class(rest{kk}));
      end
    end
  end
  
  % ensure we have a cell-array of names
  names = cellstr(names);
  
  % and ensure this goes in the history
  pls.pset('params', names);
  
  % copy if needed
  objs = copy(ps, nargout);
  
  for oo=1:numel(objs)
    obj = objs(oo);
    
    % loop over parameter names
    for kk=1:numel(names)
      
      idx = find(strcmp(names{kk}, obj.names));
      if isempty(idx)
        warning('Failed to find parameter [%s]', names{kk});
        continue;
      end
      
      obj.y(idx)     = [];
      obj.names(idx) = [];
      
      if ~isempty(obj.dy)
        obj.dy(idx) = [];
      end
      
      if ~isempty(obj.yunits)
        obj.yunits(idx) = [];
      end
      
      obj.cov = [];
      obj.corr = [];
      obj.chain = [];
      
    end % end loop over param names    
    
    % add history
    obj.addHistory(getInfo('None'), pls, p_invars(oo), obj.hist);
    
  end % End loop over objects
  
  varargout = utils.helper.setoutputs(nargout, objs);
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.converter, '', sets, pl);
  ii.setModifier(false);
  ii.setOutmin(1);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  pl = plist();
  
  % Params
  p = param({'params', 'A cell-array of parameter names to be removed.'}, paramValue.EMPTY_CELL);
  pl.append(p);
    
end

% END