% PSD makes power spectral density estimates of the time-series objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PSD makes power spectral density estimates of the
%              time-series objects in the input analysis objects
%              using the Welch Overlap method. PSD is computed
%              using a modified version of MATLAB's welch (>> help welch).
%
% CALL:        bs = psd(a1,a2,a3,...,pl)
%              bs = psd(as,pl)
%              bs = as.psd(pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     bs   - array of analysis objects, one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'psd')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% callerIsMethod interface expects the last object to be a plist
%
%     bs = psd(a1, a2, ..., pl)
%

function varargout = psd(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  
  % Collect all AOs and last object as plist
  if callerIsMethod
    if isa(varargin{end}, 'plist')
      as = [varargin{1:end-1}];
      pl = varargin{end};
    else
      as = varargin{:};
      pl = [];
    end
    ao_invars = cell(size(as));
  else
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
    pl                    = utils.helper.collect_objects(rest(:), 'plist', in_names);
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % check data types
  bs.checkNumericDataTypes(getInfo());
  
  % Apply defaults to plist
  usepl = applyDefaults(getDefaultPlist, pl);
  
  if nargout == 0
    isModifier = true;
  else
    isModifier = false;
  end
  
  % loop over inputs
  for kk=1:numel(bs)
    bs(kk) = xspec([bs(kk) bs(kk)], usepl, 'psd', getInfo, [ao_invars(kk) ao_invars(kk)], isModifier, true, callerIsMethod);
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

function pl = buildplist()
  
  % General plist for Welch-based, linearly spaced spectral estimators
  pl = copy(plist.WELCH_PLIST, 1);
  
  % Scale
  p = param({'Scale',['The scaling of output. Choose from:<ul>', ...
    '<li>PSD - Power Spectral Density</li>', ...
    '<li>ASD - Amplitude (linear) Spectral Density</li>', ...
    '<li>PS  - Power Spectrum</li>', ...
    '<li>AS  - Amplitude (linear) Spectrum</li></ul>']}, {1, {'PSD', 'ASD', 'PS', 'AS'}, paramValue.SINGLE});
  pl.append(p);
  
end

