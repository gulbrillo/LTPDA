% DOWNSAMPLE decimate AOs by an integer factor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DOWNSAMPLE AOs by an integer factor. Can be applied to
%              time-series, frequency-series, x-y, and c-data.
%              Note that no anti-aliasing filter is applied to the
%              original data!!!
% CALL:        b = downsample(a, pl)      - use plist to get parameters
%              b = downsample(a1, a2, pl) - downsample both a1 and a2;
%                                           b is then a 2x1 vector.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'downsample')">Parameters Description</a>
%
% EXAMPLES:   1) downsample x4; offset is set to default of 0
%
%                >> pl = plist('factor', 4);
%                >> b  = downsample(a, pl);
%
%             2) downsample x2 with 1 sample offset
%
%                >> pl = plist('factor', 2, 'offset', 1);
%                >> b  = downsample(a, pl);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = downsample(varargin)

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
  offset = find_core(pl, 'offset');
  factor = find_core(pl, 'factor');

  % Checking downsampling value is valid
  if isempty(factor)
    error('### Please give a plist with a parameter ''Factor''.');
  end

  % Checking downsampling value is integer
  if rem(factor, floor(factor)) ~= 0
    warning('!!! Downsample factor should be an integer. Rounding. !!!');
    factor = round(factor);
  end

  % Checking sample offset value
  if isempty(offset)
    warning('!!! No offset specified; using default of 0 samples !!!');
    offset = 0;
  end

  if factor == 0
    error('### The downsampling factor is zero. Please set a positive integer value.');
  end

  % Loop over input AOs
  for jj = 1:numel(bs)

    if isa(bs(jj).data, 'tsdata')
      % get samples
      ss = 1+offset;
      samples = ss:factor:length(bs(jj).data.y);
      % store errors
      errY = bs(jj).data.getDy;
      % select samples
      bs(jj).data.setXY(bs(jj).data.getX(samples), bs(jj).data.getY(samples));
      % set y error if any
      if ~isempty(errY)
        bs(jj).data.setDy(errY(samples));
      end
      % drop X vector again if we can
      bs(jj).data.collapseX;

      if ~callerIsMethod
        % set name
        bs(jj).name = sprintf('downsample(%s)', ao_invars{jj});
        % Add history
        bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
      end

    elseif isa(bs(jj).data, 'fsdata')
      % get samples
      ss = 1+offset;
      samples = ss:factor:length(bs(jj).data.y);
      % store errors
      errY = bs(jj).data.getDy;
      % select samples
      bs(jj).data.setXY(bs(jj).data.getX(samples), bs(jj).data.getY(samples));
      % set y error if any
      if ~isempty(errY)
        bs(jj).data.setDy(errY(samples));
      end
      % 
      if ~callerIsMethod
        % set name
        bs(jj).name = sprintf('downsample(%s)', ao_invars{jj});
        % Add history
        bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
      end

    elseif isa(bs(jj).data, 'cdata')
      % get samples
      ss = 1+offset;
      samples = ss:factor:length(bs(jj).data.y);
      % store errors
      errY = bs(jj).data.getDy;
      % select samples
      bs(jj).data.setY(bs(jj).data.getY(samples));
      % assign errors
      if ~isempty(errY)
        bs(jj).data.setDy(errY(samples));
      end
      
      if ~callerIsMethod
        % set name
        bs(jj).name = sprintf('downsample(%s)', ao_invars{jj});
        % Add history
        bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
      end

    elseif isa(bs(jj).data, 'xydata')
      % get samples
      ss = 1+offset;
      samples = ss:factor:length(bs(jj).data.y);
      % store errors
      errY = bs(jj).data.getDy;
      errX = bs(jj).data.getDx;
      % select samples
      bs(jj).data.setXY(bs(jj).data.getX(samples), bs(jj).data.getY(samples));
      if ~isempty(errY)
        bs(jj).data.setDy(errY(samples));
      end
      if ~isempty(errX)
        bs(jj).data.setDx(errX(samples));
      end

      if ~callerIsMethod
        % set name
        bs(jj).name = sprintf('downsample(%s)', ao_invars{jj});
        % Add history
        bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
      end
    else
      warning('!!! Downsample only works on fsdata, tsdata, xydata and cdata objects. Skipping AO %s', ao_invars{jj});
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

  % Factor
  p = param({'factor', 'The decimation factor. Should be an integer.'}, {1, {1}, paramValue.OPTIONAL});
  pl.append(p);

  % Offset
  p = param({'offset', 'The sample offset used in the decimation.'}, {1, {0}, paramValue.OPTIONAL});
  pl.append(p);

end


