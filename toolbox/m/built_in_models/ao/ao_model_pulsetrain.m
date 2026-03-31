% AO_MODEL_PULSETRAIN constructs a pulse-train time-series from specified
% edges.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: AO_MODEL_PULSETRAIN constructs a pulse-train time-series
%             from specified edges.
%
% CALL:        a = ao(plist('built-in', 'pulsetrain'), pl);
%
% INPUTS:
%           pl - a parameter list of additional parameters (see below)
%
% OUTPUTS:
%           mdl - an AO object representing the time-series of the signal
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('ao_model_pulsetrain')">Model Information</a>
%
%
% REFERENCES:
%
%
% HISTORY:
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ao_model_pulsetrain(varargin)
  
  varargout = utils.models.mainFnc(varargin(:), ...
    mfilename, ...
    @getModelDescription, ...
    @getModelDocumentation, ...
    @getVersion, ...
    @versionTable, ...
    @getPackageName);
  
end

%--------------------------------------------------------------------------
% AUTHORS EDIT THIS PART
%--------------------------------------------------------------------------

function desc = getModelDescription
  desc = 'Constructs a pulse-train time-series';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'From a given set of rising/falling edge indices, create a time-series of the given length with pulses at the specified rising/falling times.' ...
    ]);
end

function package = getPackageName
  package = 'ltpda';
end

% default version is always the first one
function vt = versionTable()
  
  vt = {...
    'Initial version', @version01, ...
    };
  
end


% This version is the initial one
%
function varargout = version01(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameters 'Fs', 'Nsecs'
        pl.append(plist.TSDATA_PLIST);
        
        % parameter 'edges'
        p = param({'edges', 'A 2xN matrix of rising/falling edge pairs specified as indices.'}, ...
          {1, {[]}, paramValue.OPTIONAL});
        pl.append(p);
        
        % parameter 'rising'
        p = param({'rising', 'A 1xN matrix of rising edges specified as indices.'}, ...
          {1, {[]}, paramValue.OPTIONAL});
        pl.append(p);
        
        % parameter 'falling'
        p = param({'falling', 'A 1xN matrix of falling edges specified as indices.'}, ...
          {1, {[]}, paramValue.OPTIONAL});
        pl.append(p);
        
        % set output
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'Initial version';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  % build model
  pl = varargin{1};
  fs    = find(pl, 'fs');
  nsecs = find(pl, 'nsecs');
  
  edges = find(pl, 'edges');
  if isempty(edges)
    rising  = find(pl, 'rising');
    % check for an input ao
    if isa(rising, 'ao')
      rising = rising.y;
    end
    falling = find(pl, 'falling');
    % check for an input ao
    if isa(falling, 'ao')
      falling = falling.y;
    end
    if numel(rising) ~= numel(falling)
      error('Provide one rising edge index for each falling edge index');
    end
    
    rising  = reshape(rising, [], 1);
    falling = reshape(falling,[], 1);
    edges   = [rising falling];
  end
  
  % check for an input ao
  if isa(edges, 'ao')
    edges = edges.y;
  end
  
  % error checking
  if size(edges, 1) ~= 2 && size(edges, 2) ~= 2
    error('The edges should be a 2xN matrix');
  end
  
  % generate the initial zero-based timeseries
  a = ao.zeros(nsecs, fs);
  a.setXunits(find(pl,'xunits'));
  a.setYunits(find(pl,'yunits'));
  a.setT0(find(pl,'t0'));
  a.setToffset(find(pl,'toffset'));
  
  % substitute the desired intervals with ones.
  a = a.subsData(plist('indices', edges, 'value', 1));
  
  a.setName('pulsetrain');
  
  varargout{1} = a;
  
end


%--------------------------------------------------------------------------
% AUTHORS SHOULD NOT NEED TO EDIT BELOW HERE
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Get Version
%--------------------------------------------------------------------------
function v = getVersion
  
  v = '$Id$';
  
end