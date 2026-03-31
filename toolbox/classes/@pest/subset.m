% SUBSET Extract a subset of parameters from a pest.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SUBSET Extract a subset of parameters from a pest.
%              Please notice that this makes the model meaningless.
%
% CALL:        obj = obj.subset('a');
%              obj = obj.subset({'a', 'b'});
%              obj = obj.subset(plist('parameters', {'a', 'b'}))
%
% INPUTS:      obj - one pest model.
%              pl  - parameter list
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'subset')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = subset(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
    
  % Collect all PESTs
  [ps, pest_invars, rest] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
  [pl, ~, rest]           = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, pl);
  
  % Get the parameters from the plist
  parameters = find(pl, 'parameters');
  if isempty(parameters)
    parameters = rest{:};
  end
  % Make sure we end up with a cell of strings
  if ~isa(parameters, 'cell')
    if ischar(parameters)
      parameters = {parameters};
    else
      error('Unsupported class %s for the parameters to extract', class(parameters));
    end
  end
  % Make sure we capture the info about the parameters in the plist, so the
  % history is correct
  pl.pset('Parameters', parameters);
  
  % Decide on a deep copy or a modify
  bs = copy(ps, nargout);
  
  % Apply method to all objects
  for kk = 1:numel(bs)
    
    names  = bs(kk).names;
    y      = bs(kk).y;
    dy     = bs(kk).dy;
    yunits = bs(kk).yunits;
    
    % find the parameters in the list
    idx = false(size(names));
    for jj = 1:numel(parameters)
      idx = idx | strcmp(names, parameters{jj});
    end
    
    % extract only the wanted parameters names
    bs.names = names(idx);
    
    % extract only the wanted parameters values
    bs.y = y(idx);
    
    % extract only the wanted parameters uncertainties
    if ~isempty(dy)
      bs.dy = dy(idx);
    end
    
    % extract only the wanted parameters units
    if ~isempty(yunits)
      bs.yunits = yunits(idx);
    end
    
    % extract only the wanted parameters covariance matrix
    if ~isempty(bs.cov)
      bs.cov  = bs.cov(idx, idx);
    end
    if ~isempty(bs.corr)
      bs.corr = bs.corr(idx, idx);
    end
    
    % update the inner model
    model = bs.models;
    if ~isempty(model) && ~isa(model, 'mfh')
      model.setParams(names(idx), y(idx));
    end
    
    % add history
    bs(kk).addHistory(getInfo('None'), pl, pest_invars(kk), ps(kk).hist);

  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function plo = buildplist()
  plo = plist({'parameters', 'Parameters to extract from the pest object.'}, []);
end
