% SIMPLIFY each model in the matrix.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SIMPLIFY each model in the matrix.
%
% CALL:        dmod = simplify(imod)
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'simplify')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = simplify(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  % Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin
    in_names{ii} = inputname(ii);
  end

  % Collect all smodels and plists
  [as, matrix_invars, rest] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  [pl, pl_invars, rest]     = utils.helper.collect_objects(rest(:), 'plist', in_names);

  % Merge with default plist
  pl = applyDefaults(getDefaultPlist, pl);

  bs = copy(as, nargout);
  
  % loop over input matrices
  for ww=1:numel(bs)
    imod=bs(ww);
    for ss=1:numel(imod.objs)
      if strcmpi(class(imod.objs(ss)),'smodel')
        simplify(imod.objs(ss));
      end      
    end
  end

  if nargout == 1
    varargout{1} = bs;
  elseif nargout == numel(bs)
    % List of outputs
    for ii = 1:numel(bs)
      varargout{ii} = bs(ii);
    end
  end

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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pls);
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
  pl = plist.EMPTY_PLIST;
end
