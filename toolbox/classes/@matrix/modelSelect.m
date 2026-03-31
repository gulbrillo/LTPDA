% modelselect - method to compute the Bayes Factor using RJMCMC, LF, LM, SBIC methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   modelselect   - method to compute the Bayes Factor using
%                   RJMCMC, LF, LM, SBIC methods
%
%            call - Bxy = modelselect(out,pl)
%
%          inputs - out: matrix objects with measured outputs
%                   pl:  parameter list
%
%         outputs - Bxy:
%                   -RJMCMC:
%                     an array of AOs containing the evolution
%                     of the Bayes factors. (comparing each model
%                     with each other)
%
%                   -LM, LF, SBIC:
%                     An ao containing the Bayes Factor for the
%                     comparison of 2 models
%
%<a href="matlab:utils.helper.displayMethodInfo('matrix','modelSelect')">Parameters Description</a>
%
%   N. Karnesis 27/09/2011
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = modelSelect(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### modelSelect cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs smodels and plists
  [mtxs, mtxs_invars] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % Get parameters
  mtxin = find_core(pl,'input');
  nnse  = find_core(pl,'noise');
  
  % Decide on a deep copy or a modify and checking inputs
  if ~isempty(mtxin)
    in  = copy(mtxin, nargout);
  end
  
  if isempty(nnse)
    error('### A noise signal was not inserted... To change soon.')
  else
    noise  = copy(nnse, nargout);
  end
  
  out = copy(mtxs, nargout);
  
  % Create a new plist
  new_pl = copy(pl, 1);
  
  utils.helper.msg(msg.IMPORTANT, 'Reshaping matrix objects to AOs ...', mfilename('class'), mfilename);
  % checking if input or noise are ao or matrix objects and rearange them.
  if ~isempty(mtxin)
    
    if isa(in, 'matrix')
      
      % Get number of inputs
      Nexp = numel(in);
      
      % Get number of experiments
      Nin = numel(in(1).objs);
      
      aoin(1:Nin,1:Nexp) = ao();
      
      for ii = 1:Nexp
        for jj = 1:Nin
          
          aoin(jj,ii) = in(ii).objs(jj);
          
        end
      end
      
    else
      % Leave it as it is. It will be checked inside ao/mcmc
      aoin = in;
      
      % Get number of experiments
      Nexp = numel(in(:,1));
      
    end
    
  end
  
  if isa(out, 'matrix')
    
    % Get number of inputs
    Nout = numel(out(1).objs);
    
    aoout(1:Nout,1:Nexp) = ao();
    
    for ii = 1:Nexp
      for jj = 1:Nout
        
        aoout(jj,ii) = out(ii).objs(jj);
        
      end
    end
    
  else
    % Leave it as it is. It will be checked inside ao/mcmc
    aoout = out;
    
  end
  
  if isa(noise, 'matrix')
    
    % Get number of inputs
    Nout = numel(noise(1).objs);
    
    aonoise(1:Nout,1:Nexp) = ao();
    
    for ii = 1:Nexp
      for jj = 1:Nout
        
        aonoise(jj,ii) = noise(ii).objs(jj);
        
      end
    end
    
  else
    % Leave it as it is. It will be checked inside ao/mcmc
    aonoise = noise;
    
  end
  
  % Add those objects in the new plist:
  new_pl = copy(pl, 1);
  
  new_pl = pset(new_pl, 'input', aoin);
  new_pl = pset(new_pl, 'noise', aonoise);
  
  % Now call ao/mcmc:
  p = modelSelect(aoout, new_pl);
  
  % add the history of the matrix objects
  p = addHistory(p,getInfo('None'), pl, mtxs_invars(:), [out(:).hist]);
  
  % Set output
  output = {p};
  varargout = output(1:nargout);
  
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
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  % Copy the plist from ao/modelSelect
  ao_modelSelect_info = ao.getInfo(mfilename());
  pl = copy(ao_modelSelect_info.plists, 1);
  
end


