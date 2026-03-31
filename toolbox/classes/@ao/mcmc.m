% MCMC estimates paramters using a Monte Carlo Markov Chain.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MCMC estimate the parameters of a given model given
%              inputs, outputs and noise using a Metropolis-Hastings algorithm.
%
%
% CALL:        b = mcmc(in,out,pl)
%
% INPUTS:      out     - analysis objects with measured outputs
%
%              pl      - parameter list
%
% OUTPUTS:     b       - pest object contatining estimated information
%
%
%              The data must be organized in AO matrices. It is assumed
%              that the channels of the system are positioned in the rows
%              of the matrices, while the experiments in the columns. For
%              more specific guidelines check the LTPDA toolbox userguide.
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'mcmc')">Parameters Description</a>
%
% References:  "Catching supermassive black holes binaries without a net"
%               N.J. Cornish, E.K. Porter, Phys.Rev.D 75, 021301, 2007
%
% TODO: multiple chain option not implemented yet
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mcmc(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### mcmc cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs smodels and plists
  [aos_in, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl                  = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % Throw warning: out of date
  warning('### The ao/mcmc method is outdated and will be deprecated soon. Please use the MCMC algorithm class instead...')
  
  % copy input aos
  aos = copy(aos_in,1);
  
  m = MCMC(pl);
  
  % Do a MCMC run
  m.setModel(pl.find_core('MODEL'));
  m.setInputs(pl.find_core('INPUT'));
  m.setNoise(pl.find_core('NOISE'));
  
  mproc = m.process(aos);
  
  % Extract the pest out
  p = mproc.getPest();
  
  % add the history of the matrix objects
  p = addHistory(p,getInfo('None'), pl, ao_invars(:), [aos_in(:).hist]);
  
  % Set output
  varargout{1} = p;
  
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

function pl = buildplist()
  
  pl = MCMC.getDefaultPlist;
  
end
