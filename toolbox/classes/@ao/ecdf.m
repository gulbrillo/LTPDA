% ECDF calculate empirical cumulative distribution function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% 
% ECDF calculate empirical cumulative distribution function
%
% CALL:         b = ecdf(a, pl)
% 
% INPUT:       a: are real valued AO.
% 
% OUTPUT:      b: Empirical cumulative distribution
%
% 
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'ecdf')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ecdf(varargin)

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
  [as, ao_invars]     = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  if nargout == 0
    error('### ECDF cannot be used as a modifier. Please provide an output variable.');
  end
  
  
  % Collect input histories
  inhists = [as.hist];
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  bs = ao.initObjectWithSize(1, numel(as));
  % run over input aos
  for ii=1:numel(bs)
    
    [F,X] = utils.math.ecdf(as(ii).y);
    
    bs(ii) = ao(plist('xvals', X, 'yvals', F));
    bs(ii).setName(sprintf('ECDF(%s)',  as(ii).name));
    bs(ii).addHistory(getInfo('None'), pl, ao_invars(ii), inhists(ii));
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
  
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
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
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

function plo = buildplist()
  plo = plist();
  

end
