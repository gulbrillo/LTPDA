% COHERE estimates the coherence between time-series objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COHERE estimates the coherence between the
%              time-series objects in the input analysis objects. 
%              The estimate is done by taking 
%              the ratio of the CPSD between the two inputs, Sxy, divided by 
%              the product of the PSDs of the inputs, Sxx and Syy,              
%              and is either magnitude-squared: (abs(Sxy))^2 / (Sxx * Syy) 
%              or complex value: Sxy / sqrt(Sxx * Syy)
%              Here x is the first input, y is the second input
%
% CALL:        b = cohere(a1,a2,pl)
%
% INPUTS:      a1   - input analysis object
%              a2   - input analysis object
%              pl   - input parameter list
%
% OUTPUTS:     b    - output analysis object
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'cohere')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cohere(varargin)

  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  if nargout == 0
    error('### cohere cannot be used as a modifier. Please give an output variable.');
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
    error('### cohere only accepts two inputs AOs.');
  end
  
  % Compute coherence with xspec
  scale_type = find_core(pl, 'Type');
  switch lower(scale_type)
    case 'c'
      bs = xspec(as, pl, 'cohere', getInfo, ao_invars, false, false, callerIsMethod);
    case 'ms'
      bs = xspec(as, pl, 'mscohere', getInfo, ao_invars, false, false, callerIsMethod);
    otherwise
      error(['### Unknown coherence type: [' scale_type ']']);
  end

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
  pl = copy(plist.WELCH_PLIST,1);
  
  % Type
  p = param({'Type',['type of output scaling. Choose from:<ul>', ...
    '<li>MS - Magnitude-Squared Coherence:<br><tt>(abs(Sxy))^2 / (Sxx * Syy)</tt></li>', ...
    '<li>C  - Complex Coherence:<br><tt>Sxy / sqrt(Sxx * Syy)</tt></li></ul>']}, {1, {'C', 'MS'}, paramValue.SINGLE});
  pl.append(p);
  
  
end

