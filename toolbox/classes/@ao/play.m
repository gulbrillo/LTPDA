% PLAY plays a time-series using MATLAB's audioplay function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLAY plays a time-series using MATLAB's audioplay function.
%
% CALL:        b = play(a, pl)
%
% Time-series can be played through MATLAB's audioplayer. By default, the
% data will be played back at a sample rate of 50kHz, but you can set this
% in the plist.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'play')">Parameters Description</a>
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = play(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [as, ~, ~] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  %----------- Get parameters
  fs = pl.find('fs')
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Loop over AOs
  for jj=1:numel(bs)
    
    if ~isa(bs(jj).data, 'tsdata')
      warning('Skipping object [%s] - it is not a time-series', bs(jj).name);
      continue
    end
    
    m = detrend(bs(jj), plist('order', 1));
    p = audioplayer(m.y, fs);
    p.playblocking()

    
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
  pl = plist();
  
  % fs
  p = param({'fs', 'The play-back sample rate.'}, paramValue.DOUBLE_VALUE(50000));
  pl.append(p);
  
end

