% CRB computes the inverse of the Fisher Matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CRB computes the inverse of the Fisher Matrix
%
% CALL:        bs = crb(in,pl)
%
% INPUTS:      in      - matrix objects with input signals to the system
%              model   - symbolic models containing the transfer function model
%
%              pl      - parameter list
%
% OUTPUTS:     bs   - covariance matrix AO
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'crb')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = crb(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### crb cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs smodels and plists
  [mtxs, mtxs_invars] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  pl                  = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % Get parameters
  in  = find_core(pl,'input');
  
  % Decide on a deep copy or a modify and checking inputs
  if isempty(mtxs)
    error('LTPDA:crb','### A noise signal was not inserted...')
  else
    noise  = copy(mtxs, nargout);
  end
  
  if isempty(in)
    warning('LTPDA:crb','### An input signal was not inserted...')
  end
  
  utils.helper.msg(msg.IMPORTANT, 'Reshaping matrix objects to AOs ...', mfilename('class'), mfilename);
  % checking if input or noise are ao or matrix objects and rearange them.
  if isa(in, 'matrix')
    
    % Get number of inputs
    Nin = numel(in(1).objs);
    
    % Get number of experiments
    Nexp = numel(in);
    
    aoin(1:Nin,1:Nexp) = ao();
    
    for ii = 1:Nexp
      for jj = 1:Nin
        
        aoin(jj,ii) = in(ii).getObjectAtIndex(jj);
        
      end
    end
    
  else
    % Leave it as it is. It will be checked inside ao/crb
    aoin = in;
    
  end
  
  if isa(noise, 'matrix')
    
    % Get number of inputs
    Nout = numel(noise(1).objs);
    
    % Get number of experiments
    Nexp = numel(noise);
    
    aonoise(1:Nout,1:Nexp) = ao();
    
    for ii = 1:Nexp
      for jj = 1:Nout
        
        aonoise(jj,ii) = noise(ii).getObjectAtIndex(jj);
        
      end
    end
    
  else
    % Leave it as it is. It will be checked inside ao/crb
    aonoise = noise;
    
  end
  
  % Add those objects in the new plist:
  new_pl = copy(pl, 1);
  
  new_pl = pset(new_pl, 'input', aoin);
  
  % Now call ao/crb:
  cc = crb(aonoise, new_pl);
  
  % add the history of the matrix objects
  cc = addHistory(cc,getInfo('None'), pl, mtxs_invars(:), [mtxs(:).hist]);
  
  % Set output
  output = {cc};
  varargout = output(1:nargout);
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
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
  
  % Copy the plist from ao/crb
  ao_crb_info = ao.getInfo(mfilename());
  pl = copy(ao_crb_info.plists, 1);
  
end
