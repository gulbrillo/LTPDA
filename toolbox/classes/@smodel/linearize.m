% LINEARIZE output the derivatives of the model relative to the parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LINEARIZE output the derivatives of the model relative to
% the parameters. Output is a collection of models corresponding to the
% derivative of input model for each parameter
%
% CALL:        dmod = linearize(imod)
%              
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'linearize')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = linearize(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all smodels and plists
  [as, smodel_invars, rest] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
  [pl, pl_invars, rest]     = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % Combine input plists and default plist
  pl = applyDefaults(getDefaultPlist(), pl);

  % run over input smodels
  dmod(numel(as),1) = collection;
  for jj = 1:numel(as)
    imod = as(jj);
    [mpars,idx] = sort(imod.params);
    mvals = imod.values(idx);
    imod.setParams(mpars, mvals);

    pars = imod.params;

    for ii = 1:numel(pars)
      tmod = diff(imod, pars{ii}); % do symbolic derivative for smodel
      % set the name of the parameter to the matrix, this is important to
      % identify automatically to what derivatives we are referring
      tmod.setName(pars{ii});
      dmod(jj).addObjects(tmod);
    end
     dmod(jj).setName(sprintf('linearize(%s)', imod.name));
  end
  
  if ~callerIsMethod
    % Add history
    dmod.addHistory(getInfo('None'), pl, smodel_invars, [as(:).hist]);  
  end
  
  if nargout == 1
    varargout{1} = dmod;
  elseif nargout == numel(as)
    % List of outputs
    for jj = 1:numel(as)
      varargout{jj} = dmod.index(jj);
    end
  else
    error('Set at least one output value')
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
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end
