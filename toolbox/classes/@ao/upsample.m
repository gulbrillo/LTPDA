% UPSAMPLE overloads upsample function for AOs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: UPSAMPLE AOs containing time-series data. All other AOs with
%              no time-series data are skipped but appear in the output.
%
%              A signal at sample rate fs is upsampled by inserting N-1 zeros between the
%              input samples.
%
% CALL:        b = upsample(a, pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'upsample')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = upsample(varargin)
  
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
  
  % Get output sample rate
  Nup = find_core(pl, 'N');
  if isempty(Nup)
    error('### Please give a plist with a parameter ''N''.');
  end
  % Get initial phase
  phase = find_core(pl, 'phase');
  if isempty(phase)
    phase = 0;
  end
  
  % Loop over AOs
  for jj = 1:numel(bs)
    
    if ~isa(bs(jj).data, 'tsdata')
      warning('!!! Upsample only works on tsdata objects. Skipping AO %s', ao_invars{jj});
    else
      % Clear the errors since they don't make sense anymore
      clearErrors(bs(jj));
      % upsample y
      bs(jj).data.setY(upsample(bs(jj).data.y, floor(Nup), phase));
      % Upsample x in necessary
      if ~bs(jj).data.evenly
        bs(jj).data.setX(upsample(bs(jj).data.x, floor(Nup), phase));
      end
      % Correct fs
      bs(jj).data.setFs(floor(Nup)*bs(jj).data.fs);
      
      if ~callerIsMethod
        % Set name
        bs(jj).name = sprintf('upsample(%s)', ao_invars{jj});
        % Add history
        bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
      end
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
  
  pl = plist();
  
  % N
  p = param({'N', 'The upsample factor.'}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  % phase
  p = param({'phase', 'The initial phase [0, N-1].'}, paramValue.DOUBLE_VALUE(0));
  pl.append(p);
  
end
