% AO_MODEL_GAUSSIAN_PULSE constructs a Gaussian pulse-function time-series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: AO_MODEL_GAUSSIAN_PULSE constructs a step-function time-series
%
% CALL:        a = ao(plist('built-in', 'gaussian_pulse'), pl);
%
% OUTPUTS:
%           mdl - an AO object representing the time-series of the signal
%
% EXAMPLE: a =  ao(plist('built-in','gaussian_pulse','nsecs',10,'sigma',1,'fs',100,'toff',0));
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('ao_model_gaussian_pulse')">Model Information</a>
%
%
% REFERENCES:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ao_model_gaussian_pulse(varargin)
  
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
  desc = 'Constructs a Gaussian pulse-function time-series';
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
        
        % parameter 'A'
        p = param({'A','Amplitude of the signal.'}, {1, {1}, paramValue.OPTIONAL});
        pl.append(p);
        
        % parameter 'Sigma'
        p = param({'Sigma','Sigma of the signal.'}, {1, {1}, paramValue.OPTIONAL});
        pl.append(p);
        
        % parameter 'Toff'
        p = param({'Toff', ['Offset of the pulse, as a number of seconds']}, {1, {0}, paramValue.OPTIONAL});
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
  A      = find(pl, 'A');
  cv     = find(pl, 'sigma');
  toff   = find(pl, 'toff');
  xunits = find(pl, 'xunits');
  yunits = find(pl, 'yunits');
  mu     = find(pl, 'mu');
  
  if isempty(nsecs)
    error('Please provide with the number of seconds ''nsecs''.')
  end
  
  if isempty(fs)
    fs = 0.1;
  end
  
  if isempty(mu)
    mu = nsecs/2;
  end
  
  if any(mu < 0) || any(mu > nsecs)
    error('The elements of the parameter mu must be within the limits of (0, nsecs).')
  end
  
  % build data vectors
  t = 0 : 1/fs : nsecs - 1/fs;
  
  y = zeros(numel(mu),size(t,2));
  for ii = 1:numel(mu)
    y(ii,:) = A*exp(-(t - mu(ii)).*(t - mu(ii))/(2*cv));
  end
  
  if size(y,1) > 1
    Y = sum(y);
  else
    Y = y;
  end
  % Build a time-series AO and set its name, X-units, Y-units
  spl = plist(...
    'xvals', t, ...
    'yvals', Y, ...
    'type', 'tsdata', ...
    'fs', fs, ...
    'toffset',toff,...
    'xunits', xunits, ...
    'yunits', yunits, ...
    'name', 'Gaussian pulse' ...
    );
  
  a = ao(spl);
  a.setProcinfo(spl);
  
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

