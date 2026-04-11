% GETSETRANDSTATE gets or sets the random state of the MATLAB functions 'rand' and 'randn'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETSETRANDSTATE gets or sets the random state of the MATLAB
%              functions 'rand' and 'randn'. This function looks in the
%              input plist for the key-word 'rand_state' (LTPDA toolbox
%              less than 2.1) or 'rand_stream' (LTPDA toolbox greate equal
%              than 2.1) to set the random state. If these key words
%              doesn't exist in the plist then stores this function the
%              random state in the plist.
%
% CALL:        pl = getSetRandState(pl_in);
%              pl = pl_in.getSetRandState();
%              pl_in.getSetRandState();
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'getSetRandState')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getSetRandState(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect all PLISTs
  plin = utils.helper.collect_objects(varargin(:), 'plist');
  
  % Decide on a deep copy or a modify
  plout = copy(plin, nargout);
  
  if numel(plout) ~= 1
    error('### This method accepts only one input plist object.');
  end
  
  def_struct = struct('Type',          '',    ...
    'NumStreams',    [],    ...
    'StreamIndex',   [],    ...
    'Substream',      1,    ...
    'Seed',           0,    ...%     'State',         [],    ...
    'RandnAlg',      '',    ...
    'Antithetic',    false, ...
    'FullPrecision', true);
  
  rand_state  = plout.find_core('rand_state');
  rand_stream = plout.find_core('rand_stream');
  
  gs = RandStream.getGlobalStream();
  def_stream = RandStream(gs.Type, 'Seed', RandStream.shuffleSeed);
  RandStream.setGlobalStream(def_stream);

  if ~isempty(rand_state)
    %%%    Reset random state (legacy rand_state key) — forward to rand_stream path    %%%
    plout.remove('rand_state');
    plout.getSetRandState();

  elseif ~isempty(rand_stream)
    %%%    Reset random state    %%%

    if numel(rand_stream) ~= 1
      %%% Very old legacy format stored as two separate structs — best-effort restore
      randn('state', rand_stream(1).State)
      rand('state',  rand_stream(2).State)
    else
      if isa(rand_stream, 'RandStream')
        algo = rand_stream.NormalTransform;
      else
        algo = rand_stream.RandnAlg;
      end
      stream = RandStream(rand_stream.Type, 'Seed', rand_stream.Seed, 'NormalTransform', algo);
      if isfield(rand_stream, 'State')
        stream.State         = uint32(rand_stream.State);
      end
      stream.Substream     = rand_stream.Substream;
      stream.Antithetic    = rand_stream.Antithetic;
      stream.FullPrecision = rand_stream.FullPrecision;
      RandStream.setGlobalStream(stream);
    end

  else
    %%%    Store random state    %%%

    stream = def_struct;
    stream.Type          = def_stream.Type;
    stream.NumStreams     = double(def_stream.NumStreams);
    stream.StreamIndex   = double(def_stream.StreamIndex);
    stream.Substream     = double(def_stream.Substream);
    stream.Seed          = double(def_stream.Seed);
    stream.RandnAlg      = def_stream.NormalTransform;
    stream.Antithetic    = double(def_stream.Antithetic);
    stream.FullPrecision = double(def_stream.FullPrecision);
    plout.pset('rand_stream', stream);
  end
  
  varargout{1} = plout;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = ltpda_minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.internal, '', sets, pl);
  ii.setArgsmin(1);
  ii.setArgsmax(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plo = getDefaultPlist()
  plo = plist();
end

