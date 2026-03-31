% SMOOTHER smooths a given series of data points using the specified method.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SMOOTHER smooths a given series of data points using
%              the specified method.
%
% CALL:        b = smoother(a, pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'smoother')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = smoother(varargin)

  callerIsMethod = utils.helper.callerIsMethod;

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

  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  % Get parameters from plist
  bw      = find_core(pl, 'width');
  hc      = find_core(pl, 'hc');
  method  = find_core(pl, 'method');

  % check the method
  if  ~strcmp(method, 'median') && ...
      ~strcmp(method, 'mean') && ...
      ~strcmp(method, 'min') && ...
      ~strcmp(method, 'max') && ...
      ~strcmp(method, 'mode')
    help(mfilename)
    error('### Unknown smoothing method');
  end

  % Loop over input AOs
  for jj = 1:numel(bs)
    utils.helper.msg(msg.PROC1, 'smoothing %s', bs(jj).name);
    switch lower(method)
      case {'median', 'mean', 'min', 'max'}
        bs(jj).data.setY(ltpda_smoother(bs(jj).data.getY, bw, hc, method));
      otherwise
        bs(jj).data.setY(smooth(bs(jj).data.getY, bw, hc, method));
    end
    % set name
    bs(jj).name = sprintf('smoother(%s)', ao_invars{jj});
    % Add history
    if ~callerIsMethod
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
    end
  end

  % clear errors
  bs.clearErrors;

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
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end


%--------------------------------------------------------------------------
% smooth data
function ys = smooth(y, bw, hc, method)
  N = length(y);
  ys = zeros(size(y));

  % function to smooth with
  mfcn = eval(['@(x) ' method '(x)' ]);

  for kk=1:N
    if mod(kk, 1000)==0
      utils.helper.msg(utils.const.msg.PROC1, 'smoothed %06d samples', kk);
    end
    % Determine the interval we are looking in
    interval = kk-bw/2:kk+bw/2;
    interval(interval<=0)=1;
    interval(interval>N)=N;
    % calculate method(values) of interval
    % after throwing away outliers
    trial = sort(y(interval));
    b = round(hc*length(trial));
    ys(kk)  = mfcn(trial(1:b));
  end
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
  
  pl = plist();
  
  % width
  p = param({'width', 'The width of the smoothing filter.'}, paramValue.DOUBLE_VALUE(20));
  pl.append(p);
  
  % hc
  p = param({'hc', 'A cutoff to throw away outliers (0-1).'}, paramValue.DOUBLE_VALUE(0.8));
  pl.append(p);
  
  % Method
  p = param({'method', 'The smoothing method.'}, {1, {'median', 'mean', 'max', 'min', 'mode'}, paramValue.SINGLE});
  pl.append(p);
  
end
% END

% PARAMETERS:  width  - the width of the smoothing filter [default: 20 samples]
%              hc     - a cutoff to throw away outliers (0-1)  [default: 0.8]
%              method - the smoothing method:
%                       'median'  [default]
%                       'mean', 'min', 'max', 'mode'
%
