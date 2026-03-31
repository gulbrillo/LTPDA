% FIND particular samples that satisfy the input query and return a new AO.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FIND particular samples that satisfy the input query and return a new AO.
%
% CALL:        b = find(a, 'x > 10 & x < 100')
%              b = find(a, plist)
%
% PROCINFO:    For the 'values' mode, the selected indexes are stored in
%              the procinfo of the output AO. You can get these indexes
%              with:
%                     b.procinfo.find('index').
%              For the 'indices' mode, the selected values are stored in
%              the procinfo of the output AO. You can get these values
%              with:
%                     b.procinfo.find('values')
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'find')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = find(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
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
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pl, pl_invars, rest] = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % initialise queries
  queries = '';
  % extract any from inputs
  for jj = 1:numel(rest)
    if ischar(rest{jj})
      queries = [queries ' & ' rest{jj}];
    end
  end
  
  % Get sample selection from plist
  queries = [queries ' & ' find_core(pl, 'query')];
  
  % We may have pre or trailing '&' now
  queries = strtrim(queries);
  if queries(1) == '&'
    queries = queries(2:end);
  end
  if queries(end) == '&'
    queries = queries(1:end-1);
  end
  
  % store for history
  queries = strtrim(queries);
  pl.pset_core('query', queries);
  
  % mode
  outMode = pl.find_core('mode');
  
  % Loop over input AOs
  for jj = 1:numel(bs)
    
    % The user uses the variables x and y so we need
    % to put them in the workspace.
    clear x
    if ~isa(bs(jj).data, 'cdata')
      x = bs(jj).data.getX;
    end
    y = bs(jj).data.getY;
    
    idx = [];
    cmd = sprintf('idx = find(%s);', queries);
    try
      eval(cmd);
    catch ME
      error('%s\n\n### please use x or y for the queries.', ME.message);
    end
    
    % set data
    switch lower(outMode)
      case 'values'
        
        if ~isa(bs(jj).data, 'cdata')
          
          % cache and clear errors to avoid warnings when setting shorter x
          % and y vectors
          dx = bs(jj).data.dx;
          dy = bs(jj).data.dy;
          bs(jj).data.setDx([]);
          bs(jj).data.setDy([]);
          
          %%% tsdata, fsdata, xydata
          bs(jj).data.setXY(x(idx), y(idx));
          
          % Set 'dx' and 'dy' and 'enbw'
          if numel(dx) > 1
            bs(jj).data.setDx(dx(idx));
          end
          if numel(dy) > 1
            bs(jj).data.setDy(dy(idx));
          end
          if isprop_core(bs(jj).data, 'enbw')
            if numel(bs(jj).data.enbw) > 1
              bs(jj).data.setEnbw(bs(jj).data.enbw(idx));
            end
          end
          
        else % Handle cdata
          
          bs(jj).data.setY(y(idx));
          if numel(bs(jj).data.dy) > 1
            bs(jj).data.setY(bs(jj).data.dy(idx));
          end
          
        end
        
      case 'indices'
        
        bs(jj) = ao(idx);
        
      otherwise
        error('Unsupported output mode [%s]', outMode);
    end
    
    %%% Set special properties for 'tsdata' objects
    if isa(bs(jj).data, 'tsdata')
      % drop x
      bs(jj).data.collapseX();
    end
    
    if ~callerIsMethod
      % set name
      bs(jj).name = sprintf('find(%s)', ao_invars{jj});
      % add history
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
    end
    
    % again, the procinfo depends on the mode
    switch outMode
      case 'values'
        % additional information are stored in the object
        pi = plist('index', idx);
        pi.addAlternativeKeys('index', 'indexes', 'indices');
        bs(jj).procinfo = pi;
      case 'indices'
        bs(jj).procinfo = plist('values', y(idx));
    end
    
  end % end loop over inputs
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls  = [];
  else
    sets = {'Default'};
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pls);
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
  
  % query
  p = param({'query', 'A search string specifying a query on ''x'' or ''y'' (or ''vals'' for cdata). <br>For example, <tt>''x>3 & x<5''</tt>'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % mode
  p = param({'mode', 'Output an AO containing either the values found, or the indices of the values found.'}, {1, {'values', 'indices'}, paramValue.SINGLE});
  pl.append(p);
  
end


