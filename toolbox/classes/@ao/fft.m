% FFT overloads the fft method for Analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FFT overloads the fft operator for Analysis objects.
%
% CALL:        b = fft(a, pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'fft')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = fft(varargin)

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

  inhists = [];
  
  % two-sided or one?
  fft_type = find_core(pl, 'type');
  
  % scale?
  scale = utils.prog.yes2true(find_core(pl, 'scale'));
  
  % apply window?
  win = find_core(pl, 'win');
  
  switch class(win)
    case 'specwin'
      win = win.type;
    case 'char'
    otherwise
      error('### Unsupported class %s for the window specifier. Please provide a string or a specwin object');
  end
  
  % Check input analysis object
  for jj = 1:numel(bs)
    % gather the input history objects
    inhists = [inhists bs(jj).hist];
    % apply the window
    % So far I found no other workaround to the fact that the multiply etc
    % operators cannot be used as modifier
    y = bs(jj).y;
    s = size(y);
    w = specwin(win, s(1)).win';
    y = y .* repmat(w, 1, s(2));
    bs(jj).setY(y);
    % call core method of the fft
    bs(jj).fft_core(fft_type);
    % scale if desired
    if scale
      bs(jj) = bs(jj) ./ ao(plist('vals', as(jj).data.fs, 'yunits', unit.Hz));
    end
    % set name
    bs(jj).name = sprintf('fft(%s)', ao_invars{jj});
    if ~callerIsMethod
      % Add history
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), inhists(jj));
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

function plo = buildplist()
  plo = plist();

  % FFT Type
  p = param({'type', ['The fft type. Choose between: <ul>' ...
    '<li>Plain (complete non-symmetric)</li>' ...
    '<li>One-sided (from zero to Nyquist). Please notice that this applies only to tsdata ao with real values in y.</li>' ...
    '<li>Two-sided (complete symmetric).</li></ul>' ...
    ]}, {2, {'plain', 'one', 'two'}, paramValue.SINGLE});
  plo.append(p);
  
  % Scale by sample rate?
  p = param({'scale', ['set to ''true'' to scale FFT by sampling rate to match '...
      'amplitude in continuous domain. Only applicable to time-series AOs.']},...
      paramValue.FALSE_TRUE);  
  plo.append(p);
  
  % Apply a Window?
  p = param({'Win', ['The window to be applied to the data to remove the ', ...
    'discontinuities at edges of segments. [default: rectangular one] <br>', ...
    'Only the design parameters of the window object are used. Enter ', ...
    'a string value containing the window name e.g.<br>', ...
    '<tt>plist(''Win'', ''Kaiser'', ''psll'', 200)</tt><br>', ...
    '<tt>plist(''Win'', ''BH92'')</tt>']}, paramValue.WINDOW);
  p.setDefaultOption('Rectangular');
  plo.append(p);

end
