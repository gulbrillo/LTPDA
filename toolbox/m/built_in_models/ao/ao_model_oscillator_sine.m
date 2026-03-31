% A built-in model of class ao called oscillator_sine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: A built-in model of class ao called oscillator_sine
%
% CALL:
%           mdl = ao(plist('built-in', 'oscillator_sine'));
%
% INPUTS:
%
%
% OUTPUTS:
%           mdl - an object of class ao
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('ao_model_oscillator_sine')">Model Information</a>
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
function varargout = ao_model_oscillator_sine(varargin)
  
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
  desc = 'A built-in model that constructs the time-domain response of a mechanical oscillator to a sinewave applied exernal force.';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'The model of a mechanical oscillator which depends on the following physical system parameters.<br>\n'...
    '           ''m''  - oscillator mass in kg [default: 1];<br>\n'...
    '           ''k''  - oscillator spring constant in N/m [default: 1];<br>\n'...
    '         ''tau''  - oscillator amplitude damping time in s [default: 10]<br>\n'...
    '          ''F0''  - amplitude of the force sine in N. [default: 1]<br>\n'...
    '        ''toff''  - time start of the force sine in s [default: 0]<br>\n'...
    '           ''f''  - frequency of the force sine in Hz. [default: 0.1]<br>\n'...
    '         ''phi''  - phase of the force sine in rad. [default: 0]<br>\n'...
    '          ''x0''  - oscillator position at t = 0 in m [default: 0]<br>\n'...
    '          ''v0''  - oscillator velocity at t = 0 in m/s [default:0]<br>\n'...
    '       ''nsecs''  - number of seconds [s] of data. [default: 1]<br>\n'...
    '          ''fs''  - sample rate [Hz] for the time series. [default:10]<br>\n'...
    '<br>\n'...
    'These results are calculated by assuming the oscillator is a linear system,\n'...
    'characterized by an impulse response h(t):\n'...
    '<br>\n'...
    '<pre>     h = 1/(m*w1)*exp(-t./(2*tau)).*sin(t.*w1)*theta(t);<br>\n'...
    '     in(t) = in_s*theta(t) = F0*sin(w.*t+phi)*theta(t);	  Input to the linear system<br>\n'...
    '    out(t) = Integral(h(t'')*in_s(t-t''),dt'',-Inf,+Inf);	Output from the linear system</pre><br>\n'...
    'which in this case becomes<br>\n'...
    '<pre>    out(t) = Integral(<br>\n'...
    '                   1/(m*w1)*exp(-t./(2*tau)).*sin(t.*w1) * F0*sin(w.*(t-t'')+phi),<br>\n'...
    '                   dt'',0,t)</pre><br>\n'...
    '<br>\n'...
    'The phase offset of the input, phi, enters just rotating the response vector, so<br>\n'...
    'the output can be calculated only for phi = 0 and phi = pi/2, applying then the following:<br>\n'...
    '<pre>    out(t,phi) = out(t,0)*cos(phi) + out(t,pi/2)*sin(phi);</pre><br>\n'...
    '<br>\n'...
    'After making all the calculations one finds that the output can be written:<br>\n'...
    'A transitory contribution + a stationary contribution<br>\n'...
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
        
        % parameter 'm'
        p = param({'m', ['The mass of the oscillating body [kg].']}, ...
          paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % parameter 'k'
        p = param({'k', ['The oscillator spring constant [N/m].']}, ...
          paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % parameter 'tau'
        p = param({'tau', ['The oscillator damping amplitude [s].']}, ...
          paramValue.DOUBLE_VALUE(10));
        pl.append(p);
        
        % parameter 'f0'
        p = param({'f0', ['The amplitude of the force sine [N].']}, ...
          paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % parameter 'toff'
        p = param({'toff', ['The start time of the force sine [s].']}, ...
          paramValue.DOUBLE_VALUE(0));
        pl.append(p);
        
        % parameter 'f'
        p = param({'f', ['The frequency of the force sine [Hz].']}, ...
          paramValue.DOUBLE_VALUE(0.1));
        pl.append(p);
        
        % parameter 'phi'
        p = param({'phi', ['The phase of the force sine [rad].']}, ...
          paramValue.DOUBLE_VALUE(0));
        pl.append(p);
        
        % parameter 'x0'
        p = param({'x0', ['The oscillator position at t = 0 [m].']}, ...
          paramValue.DOUBLE_VALUE(0));
        pl.append(p);
        
        % parameter 'v0'
        p = param({'v0', ['The oscillator velocity at t = 0 [m/s].']}, ...
          paramValue.DOUBLE_VALUE(0));
        pl.append(p);
        
        % parameters 'Fs', 'Nsecs', 'Xunits'
        pl.append(plist.TSDATA_PLIST);
        
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
  fs     = find(pl, 'fs');
  nsecs  = find(pl, 'nsecs');
  F0     = find(pl, 'F0');
  toff   = find(pl, 'toff');
  f      = find(pl, 'f');
  phi    = find(pl, 'phi');
  m      = find(pl, 'm');
  k      = find(pl, 'k');
  tau    = find(pl, 'tau');
  x0     = find(pl, 'x0');
  v0     = find(pl, 'v0');
  
  % Build the model object
  
  % Let's get the time base
  t = 0 : 1/fs : nsecs - 1/fs;
  
  % Let's define the oscillator parameters:
  w02 = k/m;
  w = 2*pi*f;
  w1 = sqrt(w02 -1/(4*tau^2));                  % Free decay frequency
  T = 1./((w02-w.^2).^2+(w./tau).^2);           % Power transfer function
  step = cos((t-toff).*w1)+sin((t-toff).*w1).*(1/(2*tau*w1));	% Step input response
  decay = exp(-(t-toff)./(2*tau));                     % Exponential decay
  
  
  % For each phase component, we will calculate the transitory contribution
  out_transitory_phase = -F0/(m*w1)*w*T*decay.*(sin((t-toff)*w1).*(w02-w^2)-step.*(w1/tau));
  out_transitory_quad = -F0/(m*w1)*T*decay.*(sin((t-toff)*w1).*(w^2/tau)+step.*w1*(w02-w^2));
  
  % and the stationary contribution
  out_stationary_phase = -F0/m*T*(w/tau*cos((t-toff).*w)+(w^2-w02)*sin((t-toff).*w));
  out_stationary_quad = -F0/m*T*(-w/tau*sin((t-toff).*w)+(w^2-w02)*cos((t-toff).*w));
  
  % Let's calculate the two total phases
  out_phase = out_stationary_phase + out_transitory_phase;
  out_quad = out_stationary_quad + out_transitory_quad;
  
  % Initial conditions evolution
  phase = -atan2(v0*w1, x0*w02+v0/(2*tau));
  
  A0 = 1/cos(phase) * (x0 + v0/(2*tau*w02));
  step_phase = cos((t-toff).*w1 + phase) + sin((t-toff).*w1 + phase).*(1/(2*tau*w1));
  
  out_initial = A0 * decay .* step_phase;
  
  % Let's finally calculate the total output
  y = out_phase*cos(phi) + out_quad*sin(phi) + out_initial;
  
  % Pads the region before the sine start with the initial position
  y(t < toff) = x0;
  
  % Build a time-series data object
  tsd = tsdata(t,y,fs);
  
  % Set X-units, Y-units
  tsd.setXunits('s');
  tsd.setYunits('m');
  
  % Build the AO and set its name
  a = ao(tsd);
  
  a.setName('Sine');
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
