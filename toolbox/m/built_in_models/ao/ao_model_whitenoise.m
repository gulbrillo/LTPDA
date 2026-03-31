% AO_MODEL_WHITENOISE constructs a known white-noise time-series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: AO_MODEL_WHITENOISE constructs a known white-noise time-series.
%
% CALL:     mdl = ao(plist('built-in', 'whitenoise'), pl);
%
% INPUTS:
%           pl - a parameter list of additional parameters (see below)
%
% OUTPUTS:
%           mdl - an AO object representing the time-series of the signal
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('ao_model_whitenoise')">Model Information</a>
%
%
% REFERENCES:
%
%
% HISTORY:
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ao_model_whitenoise(varargin)
  
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
  desc = 'Constructs a known white-noise time-series';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'No documentation at the moment' ...
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
        
        % parameters 'Fs', 'Nsecs', 'Xunits'
        pl.append(plist.TSDATA_PLIST);
        
        % parameter 'sigma'
        p = param({'sigma', ['The standard deviation of the noise']}, ...
          paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'Yunits'
        p = param({'yunits','Unit on Y axis.'},  paramValue.STRING_VALUE(''));
        pl.append(p);
        
        % set output
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version is the initial one';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  % build model
  pl = varargin{1};
  fs     = find(pl, 'fs');
  nsecs  = find(pl, 'nsecs');
  sigma  = find(pl, 'sigma');
  xunits = find(pl, 'xunits');
  yunits = find(pl, 'yunits');
  
  % force default if the user set them to empty
  if isempty(fs)
    fs = 10;
  end
  if isempty(nsecs)
    nsecs = 1;
  end
  if isempty(sigma)
    sigma = 1;
  end
  
  % set known random seed (MATLAB 7.12 = R2011a)
  seed = 212366.3425;
  if verLessThan('MATLAB', '7.12')
    prevRandStream = RandStream.getDefaultStream;
    RandStream.setDefaultStream(RandStream('shr3cong','seed', seed));
    oncleanup = onCleanup(@() RandStream.setDefaultStream(prevRandStream));
  else
    prevRandStream = RandStream.getGlobalStream;
    RandStream.setGlobalStream(RandStream('shr3cong','seed', seed));
    oncleanup = onCleanup(@() RandStream.setGlobalStream(prevRandStream));
  end
  
  % build data vector
  y = sigma.*randn(fs*nsecs, 1);

  % Build a time-series data object
  tsd = tsdata(y, fs);
  
  % Set X-units and Y-units
  tsd.setXunits(xunits);
  tsd.setYunits(yunits);
  
  % Finally, build the AO and set its name
  a = ao(tsd);
  a.setName('WN');

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
