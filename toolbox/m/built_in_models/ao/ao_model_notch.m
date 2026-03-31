% AO_MODEL_NOTCH constructs a sine-wave time-series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: AO_MODEL_NOTCH constructs a sine-wave time-series
%
% CALL:        a = ao(plist('built-in', 'sinewave'), pl);
%
% INPUTS:
%           pl - a parameter list of additional parameters (see below)
%
% OUTPUTS:
%           mdl - an AO object representing the time-series of the signal
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('ao_model_notch')">Model Information</a>
%
%
% REFERENCES:
%
%
% HISTORY:
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ao_model_notch(varargin)
  
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
  desc = 'Constructs a frequency-series with notches at specific frequencies';
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
    'Default', @versionDefault, ...
    };
  
end


% This version is the initial one
%
function varargout = versionDefault(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'F'
        p = param(...
          {'F','Vector of Fourier frequencies. Should be linearly-spaced '},...
          1.0);
        pl.append(p);
        
        % parameter 'F0'
        p = param(...
          {'F0','Array of notch frequencies.'},...
          paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'harmonics'
        p = param(...
          {'HARMONICS','Number of harmonics for each notch frequency'},...
          1);
        pl.append(p);
        
        % parameter 'width'
        p = param(...
          {'WIDTH','Width of the notch, in Hz or same units as F'},...
          []);
        pl.append(p);
        
        % parameter 'depth'
        p = param(...
          {'DEPTH','maximumDepth of the notch'},...
          1e-6);
        pl.append(p);
        
        % parameter 'xunits'
        p = param(...
          {'XUNITS','Units for the dependant (frequency) axis'},...
          'Hz');
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
  
  % parse plist
  pl = varargin{1};
  
  % frequency vector
  f = find(pl, 'F');
  switch class(f)
    case 'ao'
      xunits = f.xunits;
      f = f.y;
    case 'double'
      xunits = unit(pl.find('XUNITS'));
    otherwise
      error('%s is not a valid object type for a frequecy vector', class(f));
  end
  
  
  % notch frequencies
  f0      = double(find(pl, 'F0'));
  
  % number of harmonics
  nharm = double(find(pl,'HARMONICS'));
  
  if numel(nharm) == 1
    nharm = nharm*ones(size(f0));
  elseif numel(nharm) == numel(f0)
  else
    error('# of harmonics (%i) does not match number of fundamental notch frequencies (%i)',numel(nharm),numel(f0));
  end
  
  % width
  width = double(find(pl,'WIDTH'));
  if isempty(width)
    width = f0/5;
  end
  
  if numel(width) == 1
    width = width*ones(size(f0));
  elseif numel(width) == numel(f0)
    
  else
    error('# notch widths (%i) does not match number of fundamental notch frequencies (%i)',numel(width),numel(f0));
  end
  
  % depth
  depth = double(find(pl,'DEPTH'));
  
  if numel(depth) == 1
    depth = depth*ones(size(f0));
  elseif numel(depth) == numel(f0)
  else
    error('# notch depths (%i) does not match number of fundamental notch frequencies (%i)',numel(depth),numel(f0));
  end
  
  % xunits
  xunits = find(pl, 'xunits');
  
  % build data vectors
  
  % frequency resolution (assumes linear frequency vector!)
  fres = f(2)-f(1);
  
  %intialize output
  y = ones(size(f));
  
  % loop through number of fundamentals
  for ii = 1:numel(f0)
    
    % width (rounded to a power of 6)
    Mwin = 6*ceil(width(ii)/(6*fres));
    
    % loop over harmonics
    for jj = 1:nharm(ii)
      % find index corresponding to notch
      [~,idx] = min(abs(f-f0(ii)*jj));
      y(idx-1/2*Mwin:idx-1/6*Mwin-1) = 1-0.5*(1-(1-depth(ii))*cos(2*pi*(0:(Mwin/3-1))/((Mwin-2)*2/3)))';
      y(idx-1/6*Mwin:idx+1/6*Mwin-1) = depth(ii)*ones(1,Mwin/3);
      y(idx+1/6*Mwin:idx+1/2*Mwin-1) = 1-0.5*(1-(1-depth(ii))*cos(2*pi*((Mwin/3-1):-1:0)/((Mwin-2)*2/3)))';
    end
    
  end
  
  
  % Build a time-series AO and set its name, X-units, Y-units
  spl = plist(...
    'xvals', f, ...
    'yvals', y, ...
    'type', 'fsdata', ...
    'xunits', xunits, ...
    'yunits', unit(), ...
    'name', 'Notch' ...
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
