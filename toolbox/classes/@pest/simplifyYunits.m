% SIMPLIFYYUNITS simplifies the units of parameters in a pest
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SIMPLIFYYUNITS simplifies the units of parameters in a pest
%
% CALL:        obj = obj.simplifyYunits();
%              obj.simplifyYunits();
%
% INPUTS:      obj = a pest object or array of pest objects
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'simplifyYunits')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = simplifyYunits(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;

  if callerIsMethod
    pests     = varargin{1};
    if nargin == 2
      pls  = varargin{2};
    else
      pls  = plist();
    end
    
  else
    %%% Check if this is a call for parameters
    if utils.helper.isinfocall(varargin{:})
      varargout{1} = getInfo(varargin{3});
      return
    end
    
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Collect all pests
    [pests, pest_invars] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
        
    % Apply defaults to plist
    pls = applyDefaults(getDefaultPlist, varargin{:});
  
  end
  
  % Decide on a deep copy or a modify
  bs = copy(pests, nargout);

  % simplifyYunits plist
  spl = pls.subset(getKeys(ao.getInfo('simplifyYunits').plists));
  
  % Loop over pestss
  for jj = 1:numel(bs)
    
    % simplify the units
    for kk = 1:numel(bs(jj).yunits)
      bs(jj).yunits(kk).simplify(spl);
    end

    if ~callerIsMethod
      bs(jj).addHistory(getInfo('None'), pls, pest_invars(jj), bs(jj).hist);
    end
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
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function plo = buildplist()

  % inherit from simplifyYunits
  plo = copy(ao.getInfo('simplifyYunits').plists,1);
  
end

