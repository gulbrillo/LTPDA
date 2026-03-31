% MVE: Minimum Volume Ellipsoid estimator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Minimum Volume Ellipsoid estimator
%              for robust outlier detection.
%
% CALL:        ao_out = mve(pest_obj);
%              ao_out = mve(pest_obj, pl);
%
% NOTE:        The method will apply the MVE to the chain field pest_obj.chain.
%
% The ao_out is the weighted covariance matrix of the data. Other
% information, like the weighted mean, the volume and the center of
% the ellipsoid are stored in ao_out.procinfo.
%
%
% Uses the method described in P. Rousseeuw "Robust Regresion and outlier
% Detection, 1987" in pages 258-261.
%
% **Also in http://www.kimvdlinde.com/professional/pcamve.html
%
% NK 2013
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'mve')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mve(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### MVE cannot be used as a modifier. Please give an output variable.');
  end
  
  if callerIsMethod
    % do nothing?
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  % Collect all AOs pests and plists
  [pests, pests_invars] = utils.helper.collect_objects(varargin(:), 'pest',  in_names);
  pl                    = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % Initialize
  if ~isempty(pests)
    
    chain   = pests.chain;
    A       = chain(:,3:end); % Dont keep the loglikelihood and SNR columns
    A_ao    = ao(A);
    
  else
    
    error('### MVE can process only AO or PEST objects.');
    
  end
  
  % Create a new plist
  new_pl = copy(pl, 1);
  
  bs = mve(A_ao, new_pl);
  
  % Add History
  bs = addHistory(bs,getInfo('None'), pl, pests_invars(:), [pests(:).hist]);
  % Set outputs
  varargout = utils.helper.setoutputs(nargout, bs);
  
end


%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  ii = minfo.getInfoAxis(mfilename, @getDefaultPlist, mfilename('class'), 'ltpda', utils.const.categories.op, '', varargin);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function plout = buildplist(varargin)
  
  % Copy the plist from ao/mcmc
  ao_mve_info = ao.getInfo('mve');
  
  plout       = copy(ao_mve_info.plists, 1);
  
end


