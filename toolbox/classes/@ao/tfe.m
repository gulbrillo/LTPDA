% TFE estimates transfer function between time-series objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TFE makes transfer function estimates of the time-series
%              in the input analysis objects. The estimate is done by taking 
%              the ratio of the CPSD between the two inputs, Sxy, divided by 
%              the PSD of the first input, Sxx:
%              Sxy / Sxx where x is the first input, y is the second input
%
% CALL:        b = tfe(a1,a2,pl)
%
% INPUTS:      a1   - input analysis object
%              a2   - input analysis object
%              pl   - input parameter list
%
% OUTPUTS:     b    - output analysis object
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'tfe')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = tfe(varargin)

  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  if nargout == 0
    error('### tfe cannot be used as a modifier. Please give an output variable.');
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
    error('### tfe only accepts two inputs AOs.');
  end

  % Compute transfer function with xspec
  bs = xspec(as, pl, 'tfe', getInfo, ao_invars, false, false, callerIsMethod);

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
  
  % General plist for Welch-based, linearly spaced spectral estimators
  pl = plist.WELCH_PLIST;
  
end

