% DELAY overloads ao/delay for matrix objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DELAY overloads ao/delay for matrix objects.
%
% CALL:        b = delay(a, pl)
%              b = delay(a, tau) % in this case, fft filtering is used
%
% Time-series can be delayed either by an integer numbers of samples, or a
% time, depending on the method chosen. For delaying by an explicit time,
% you can use the fft filtering method, or a fractional delay filtering
% method.
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'delay')">Parameters Description</a>
%
% EXAMPLES:    1) Shift by 10 samples and zero pad the end of the time-series
%                 >> b = delay(a, plist('N', 10, 'method', 'zero'));
%
%              2) Shift by 0.1 seconds
%                 >> b = delay(a, plist('mode', 'fftfilter', 'tau', 0.1));
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = delay(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Collect input variable names
  if callerIsMethod
    
    % assume a call delay(ao, tau)
    as   = varargin{1};
    tau  = varargin{2};
    if isa(tau, 'plist')
      pl = applyDefaults(getDefaultPlist, tau);
    elseif isnumeric(tau)
      mode = 'fftfilter';
      pl = plist('mode',mode,'tau',tau);
    else
      error('Unknown usage of delay');
    end
    
  else
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Collect all matrix objects
    [as, matrix_invars, rest] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
    
    % Apply defaults to plist
    pl = applyDefaults(getDefaultPlist, varargin{:});
    
    %----------- Get parameters
    
    if ~isempty(rest) && isnumeric(rest{1})
      tau = rest{1};
      pl.pset('mode', 'fftfilter');
      pl.pset('tau', tau);
    end
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  
  % Loop over Matricies
  for jj=1:numel(bs)
    
    % convert matrix to AOs
    mao = bs.toArray();
    
    % reshape
    s = size(mao);
    mao = reshape(mao, prod(s),1);
    
    % apply delay
    mao.delay(pl);
    
    % reshape back
    mao = reshape(mao,s(1),s(2));
    
    % set objects
    bs.setObjs(mao);
    
    if ~callerIsMethod
      % make output analysis object
      bs(jj).name = sprintf('delay(%s)', matrix_invars{jj});
      % Add history
      bs(jj).addHistory(getInfo('None'), pl, matrix_invars(jj), bs(jj).hist);
    end
    
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
  pl = ao.getInfo('delay').plists;
  
end
