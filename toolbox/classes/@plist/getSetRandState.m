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
  
  persistent lessThanMatlab77;  % MATLAB 7.7  = R2008b
  persistent lessThanMatlab712; % MATLAB 7.12 = R2011a
  
  if isempty(lessThanMatlab77)
    lessThanMatlab77 = verLessThan('MATLAB', '7.7');
  end
  
  if isempty(lessThanMatlab712)
    lessThanMatlab712 = verLessThan('MATLAB', '7.12');
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
  
  %%% We have different behavior for the MATLAB version 2008b and less than
  %%% version 2008b because version 2008b is working with random streams.
  
  %%% MATLAB version 2008a and less
  if lessThanMatlab77
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                    MATLAB version 2008a and less                    %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if ~isempty(rand_state)
      %%%    Reset random state    %%%
      
      %%% It might be that 'rand_state' contains the 'state' or the 'seed'
      %%% of the MATLAB rand or randn methods.
      try
        randn('seed',rand_state);
        rand('seed', rand_state);
      catch
        if numel(rand_state) > 2
          rand('state', rand_state)
        else
          randn('state', rand_state)
        end
      end
      plout.remove('rand_state');
      plout.getSetRandState();
      
    elseif ~isempty(rand_stream)
      %%%    Reset random state    %%%
      
      %%% Legacy mode
      if numel(rand_stream) ~= 1
        %%% Set that of 'randn'
        randn('state', rand_stream(1).State)
        %%% Set that of 'rand'
        rand('state', rand_stream(2).State)
      else
        error('### I have no idea what I should do because the random state is stores as a random stream with MATLAB version 2008b or later.')
      end
      
    else
      %%%    Store random state    %%%
      
      stream = [def_struct def_struct];
      %%% Store state of 'randn'
      stream(1).Type  = 'randn';
      stream(1).State = randn('state');
      %%% Store state of 'rand'
      stream(2).Type  = 'rand';
      stream(2).State = rand('state');
      plout.append('rand_stream', stream);
    end
    
  else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%                   MATLAB version 2008b and later                    %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if lessThanMatlab712
      def_stream = RandStream.getDefaultStream;
    else
      %%% Sice MATLAB version R2011a (7.12) exist a new function to get the
      %%% current random stream.
      gs = RandStream.getGlobalStream();
      def_stream = RandStream(gs.Type, 'Seed', RandStream.shuffleSeed);
      RandStream.setGlobalStream(def_stream);
    end
    
    if ~isempty(rand_state)
      %%%    Reset random state    %%%
      
      %%% It might be that 'rand_state' contains the 'state' or the 'seed'
      %%% of the MATLAB rand or randn methods.
      try
        randn('seed',rand_state);
        rand('seed', rand_state);
      catch
        if numel(rand_state) > 2
          rand('state', rand_state)
        else
          randn('state', rand_state)
        end
      end
      plout.remove('rand_state');
      plout.getSetRandState();
      
    elseif ~isempty(rand_stream)
      %%%    Reset random state    %%%
      
      %%% Legacy mode
      %%% This happens if LTPDA or the user sets the random state with the
      %%% old commans:
      %%% rand('state', rand_state)
      %%% randn('state', rand_state)
      if numel(rand_stream) ~= 1
        
        %%% Set that of 'randn'
        randn('state', rand_stream(1).State)
        %%% Set that of 'rand'
        rand('state', rand_stream(2).State)
      else
        
        if lessThanMatlab712
          stream = RandStream(rand_stream.Type, 'Seed', rand_stream.Seed, 'RandnAlg', rand_stream.RandnAlg);
        else
          if isa(rand_stream, 'RandStream')
            algo = rand_stream.NormalTransform;
          else
            algo = rand_stream.RandnAlg;
          end
          stream = RandStream(rand_stream.Type, 'Seed', rand_stream.Seed, 'NormalTransform', algo);
        end
        
        if isfield(rand_stream, 'State')
          stream.State         = uint32(rand_stream.State);
        end
        stream.Substream     = rand_stream.Substream;
        stream.Antithetic    = rand_stream.Antithetic;
        stream.FullPrecision = rand_stream.FullPrecision;
        
        if lessThanMatlab712
          RandStream.setDefaultStream(stream);
        else
          %%% Sice MATLAB version R2011a (7.12) exist a new function to set
          %%% a random stream.
          RandStream.setGlobalStream(stream);
        end
      end
      
    else
      %%%    Store random state    %%%
      
      if strcmp(def_stream.Type, 'legacy')
        %%%%%%%%%%   Legacy Mode   %%%%%%%%%%
        %%% This happens if LTPDA or the user sets the random state with the
        %%% old commans:
        %%% rand('state', rand_state)
        %%% randn('state', rand_state)
        
        stream = [def_struct def_struct];
        %%% Store state of 'randn'
        stream(1).Type  = 'randn';
        stream(1).State = randn('state');
        %%% Store state of 'rand'
        stream(2).Type  = 'rand';
        stream(2).State = rand('state');
        
      else
        %%%%%%%%%%   Stream Mode   %%%%%%%%%%
        stream = def_struct;
        stream.Type          = def_stream.Type;
        stream.NumStreams    = double(def_stream.NumStreams);
        stream.StreamIndex   = double(def_stream.StreamIndex);
        stream.Substream     = double(def_stream.Substream);
        stream.Seed          = double(def_stream.Seed);
%         stream.State         = double(def_stream.State);
        if lessThanMatlab712
          stream.RandnAlg    = def_stream.RandnAlg;
        else
          stream.RandnAlg    = def_stream.NormalTransform;
        end
        stream.Antithetic    = double(def_stream.Antithetic);
        stream.FullPrecision = double(def_stream.FullPrecision);
      end
      plout.pset('rand_stream', stream);
    end
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.internal, '', sets, pl);
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

