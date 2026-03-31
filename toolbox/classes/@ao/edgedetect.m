% EDGEDETECT detects edges in a binary pulse-train.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: EDGEDETECT detects edges in a binary pulse-train.
%
% The input time-series is expected to be a binary pulse-train of zeros and
% ones. This method then detects the rising and falling edges of that
% pulse-train and returns an AO containing pairs of indices which mark the
% first and last high samples of each pulse.
% 
% CALL:        b = edgedetect(a, pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'edgedetect')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = edgedetect(varargin)

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

  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);

  %%% Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  

  % Loop over input AOs
  for jj = 1:numel(bs)
    if ~isa(bs(jj).data, 'tsdata')
      error('Zero padding only works on time-series. AO %s is not a time-series.', ao_invars{jj});
    else
      
      % cache input history
      inhist = bs(jj).hist;
      
      % get edges
      rising  = find_rising_edge(bs(jj).y);
      falling = find_falling_edge(bs(jj).y);

      % build AO
      edges = [rising falling];
      bs(jj) = ao(edges);
      
      % Set name
      bs(jj).name = sprintf('edgedetect(%s)', ao_invars{jj});
      % Add history
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), inhist);
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


function idx = find_falling_edge(y)
  % returns sample index of falling edge in vector y
  % NOTES:
  %  index returned is of the last HIGH value
  %  If last sample is HIGH, it is treated as a falling edge
  
  % condition y to boolean
  y = logical(y);
  
  % length of data
  N = numel(y);
  
  % append with a false
  y = [y; false];
  
  % generate vector of edges
  edges = and(y(1:N),not(y(2:N+1)));
  
  % get indices
  idx = find(edges);
  
end

function idx = find_rising_edge(y)
  % returns sample index of rising edge in vector y
  % NOTES:
  %  index returned is of the first HIGH value
  %  If first sample is HIGH, it is treated as a rising edge
  
  % condition y to boolean
  y = logical(y);
  
  % get number of elements
  N = numel(y);
  
  % prepend y with a false
  y = [false; y];
  
  % generate vector of edges
  edges = and(y(2:N+1),not(y(1:N)));
  
  % get indices
  idx = find(edges);
  
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
end
% END
