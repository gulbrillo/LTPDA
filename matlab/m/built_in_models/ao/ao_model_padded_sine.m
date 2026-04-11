% A built-in model of class ao called padded_sine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: A built-in model of class ao called padded_sine
%
% CALL:
%           mdl = ao(plist('built-in', 'padded_sine'));
%
% INPUTS:
%
%
% OUTPUTS:
%           mdl - an object of class ao
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('ao_model_padded_sine')">Model Information</a>
%
%
% REFERENCES:
%
%
% HISTORY:
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% YOU SHOULD NOT NEED TO EDIT THIS MAIN FUNCTION
function varargout = ao_model_padded_sine(varargin)
  
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
  desc = 'A built-in model that constructs a sine-wave time-series with zero-padding at each end.';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'A sine-wave time-series padded with zeros at both ends.\n'...
    ]);
end

function package = getPackageName
  package = 'ltpda';
end

% default version is always the first one
function vt = versionTable()
  
  vt = {...
    'Version 1', @version1, ...
    };
  
end

% This version is ...
%
function varargout = version1(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
                
        % A
        p = param({'A', ['The amplitude of the sine-wave.']}, ...
          paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % f0
        p = param({'f0', ['The frequency of the sine-wave in Hz.']}, ...
          paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % phi
        p = param({'phi', ['The phase of the sine-wave [deg].']}, ...
          paramValue.DOUBLE_VALUE(0));
        pl.append(p);
        
        % dc
        p = param({'dc', ['The dc offset of the sine-wave.']}, ...
          paramValue.DOUBLE_VALUE(0));
        pl.append(p);
        
        % t0
        p = param({'Tstart', ['The start time offset of the sine-wave.']}, ...
          paramValue.DOUBLE_VALUE(0));
        pl.append(p);
        
        % N
        p = param({'Ncycles', ['The number of cycles of the sine-wave. Can be fractional.']}, ...
          paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % Yunits
        p = param({'yunits', ['The units of the final signal.']}, ...
          paramValue.EMPTY_STRING);
        pl.append(p);
        
        % X
        p = param({'Timebase', ['An evenly sampled vector of time-samples (the x-axis) in which to embed the sine-wave.'...
          'This could also be a time-series AO in which case the x-vector from the AO will be used.']}, ...
          paramValue.DOUBLE_VALUE(1:10));
        pl.append(p);
        
        % P
        p = param({'P', ['A vector of parameter values [dc,A,f0,phi,t0,N]. These will override other settings.']}, ...
          paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % set output
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version is version 1.';
      case 'info'
        % Add info calls for any other models that you use to build this
        % model. For example:
        %         varargout{1} = [ ...
        %  ao_model_SubModel1('info', 'Some Version') ...
        %  ao_model_SubModel2('info', 'Another Version') ...
        %                        ];
        %
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  % build model
  pl = varargin{1};

  % Get parameters
  f0     = pl.find('f0');
  A      = pl.find('A');
  phi    = pl.find('phi');
  dc     = pl.find('dc');
  N      = pl.find('Ncycles');
  yunits = pl.find('yunits');
  X      = pl.find('Timebase');
  t0     = pl.find('Tstart');
  P      = pl.find('P');
  
  if isa(X, 'ao')
    X = X.x;
  end
  
  if ~isempty(P)
    if length(P) ~= 6
      error('When providing a parameter vector, you must specify all 6 parameters [dc,A,f0,phi,t0,N].');
    end
    
    %     [dc,A,f0,phi,t0,N]
    dc  = P(1);
    A   = P(2);
    f0  = P(3);
    phi = P(4);
    t0  = P(5);
    N   = P(6);
  end
  
  % The zeros vector
  v = zeros(size(X));
  
  % Time-base for the sine-wave part
  dt = X(2)-X(1); % assuming evenly sampled X here!
  st = 0:dt:N/f0-dt;
  
  % The sine wave
  s = dc + A*sin(2*pi*f0*st + phi*pi/180);
  
  % Embed that in the zeros now
  idx = find(X>=t0);
  v(idx(1):idx(1)+length(s)-1) = s;
  % And truncate in case we over-ran the X vector
  v = v(1:length(X));
  
  % Build a time-series data object
  tsd = tsdata(X,v,1/dt);
  
  % Set X-units, Y-units
  tsd.setXunits('s');
  tsd.setYunits(yunits);
  
  % Build the AO and set its name
  a = ao(tsd);
  
  a.setName('PaddedSine');
  
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
