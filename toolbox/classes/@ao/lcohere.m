% LCOHERE implement magnitude-squadred coherence estimation on a log frequency axis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LCOHERE implement coherence estimation on a log frequency axis.
%              The estimate is done by taking 
%              the ratio of the CPSD between the two inputs, Sxy, divided by 
%              the product of the PSDs of the inputs, Sxx and Syy,              
%              and is either magnitude-squared: (abs(Sxy))^2 / (Sxx * Syy) 
%              or complex value: Sxy / sqrt(Sxx * Syy)
%              Here x is the first input, y is the second input
%
% CALL:        b = lcohere(a1,a2,pl)
%
% INPUTS:      a1   - input analysis object
%              a2   - input analysis object
%              pl   - input parameter list
%
% OUTPUTS:     b    - output analysis object
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'lcohere')">Parameters Description</a>
%
% References:  "Improved spectrum estimation from digitized time series
%               on a logarithmic frequency axis", Michael Troebs, Gerhard Heinzel,
%               Measurement 39 (2006) 120-129.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = lcohere(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  if nargout == 0
    error('### lcohere cannot be used as a modifier. Please give an output variable.');
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
    error('### lcohere only accepts two inputs AOs.');
  end
  
  % Compute coherence with lxspec
  scale_type = find_core(pl, 'Type');
  switch lower(scale_type)
    case 'c'
      bs = ao.lxspec(as, pl, 'cohere', getInfo, ao_invars);
    case 'ms'
      bs = ao.lxspec(as, pl, 'mscohere', getInfo, ao_invars);
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
  
  % General plist for Welch-based, log-scale spaced spectral estimators
  pl = copy(plist.LPSD_PLIST,1);
  
  % Type
  p = param({'Type',['type of output scaling. Choose from:<ul>', ...
    '<li>MS - Magnitude-Squared Coherence:<br><tt>(abs(Sxy))^2 / (Sxx * Syy)</tt></li>', ...
    '<li>C  - Complex Coherence:<br><tt>Sxy / sqrt(Sxx * Syy)</tt></li></ul>']}, {1, {'C', 'MS'}, paramValue.SINGLE});
  pl.append(p);
  
end

% PARAMETERS:
%
%     'Kdes'  - desired number of averages   [default: 100]
%     'Jdes'  - number of spectral frequencies to compute [default: 1000]
%     'Lmin'  - minimum segment length   [default: 0]
%     'Win'   - the window to be applied to the data to remove the 
%               discontinuities at edges of segments. [default: taken from
%               user prefs]
%               Only the design parameters of the window object are
%               used. Enter either:
%                - a specwin window object OR
%                - a string value containing the window name 
%                  e.g., plist('Win', 'Kaiser', 'psll', 200)
%     'Olap'  - segment percent overlap [default: -1, (taken from window function)]  
%     'Type'  - type of output scaling. Choose from:
%                MS - Magnitude-Squared Coherence (abs(Sxy))^2 / (Sxx * Syy)  
%                C  - Complex Coherence Sxy / sqrt(Sxx * Syy) [default] 
%     'Order' - order of segment detrending
%                -1 - no detrending
%                0 - subtract mean [default]
%                1 - subtract linear fit
%                N - subtract fit of polynomial, order N
