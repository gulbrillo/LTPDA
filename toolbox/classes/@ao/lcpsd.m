% LCPSD implement cross-power-spectral density estimation on a log frequency axis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LCPSD implement cross-power-spectral density estimation on a
%              log frequency axis
%
% CALL:        b = lcpsd(a1,a2,pl)
%
% INPUTS:      aN   - input analysis objects (two)
%              pl   - input parameter list
%
% OUTPUTS:     b    - output analysis object
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'lcpsd')">Parameters Description</a>
%
% References:  "Improved spectrum estimation from digitized time series
%               on a logarithmic frequency axis", Michael Troebs, Gerhard Heinzel,
%               Measurement 39 (2006) 120-129.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = lcpsd(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  if nargout == 0
    error('### lcpsd cannot be used as a modifier. Please give an output variable.');
  end

  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
    
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  % Throw an error if input is not two AOs
  if numel(as) ~= 2
    error('### lcpsd only accepts two inputs AOs.');
  end
  
  % Compute cross-spectrum with lxspec
  bs = ao.lxspec(as, pl, 'cpsd', getInfo, ao_invars);

  % Set output
  varargout{1} = bs;

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
  ii.setModifier(false);
  ii.setArgsmin(2);
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
  
  % General plist for Welch-based, log-scale spaced spectral estimators
  pl = plist.LPSD_PLIST;
  
end

