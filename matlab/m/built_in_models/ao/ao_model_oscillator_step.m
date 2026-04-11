% A built-in model of class ao called oscillator_step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: A built-in model of class ao called oscillator_step
%
% CALL:
%           mdl = ao(plist('built-in', 'oscillator_step'));
%
% INPUTS:
%
%
% OUTPUTS:
%           mdl - an object of class ao
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('ao_model_oscillator_step')">Model Information</a>
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
function varargout = ao_model_oscillator_step(varargin)
  
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
  desc = 'A built-in model that constructs the time-domain response of a mechanical oscillator to a step change in the applied exernal force.';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'The response of a mechanical oscillator to an step change on the force input. <br>\n'...
    'The system response is calculated by assuming the oscillator is a linear system,\n'...
    'characterized by an impulse response h(t):<br>\n'...
    '<pre>      h = 1/(m*w1)*exp(-t./(2*tau)).*sin(t.*w1)*theta(t);	Impulse response of the oscillator<br>\n'...
    '      in(t) = in_s*theta(t) = F0*theta(t);					Input to the linear system<br>\n'...
    '     out(t) = Integral(h(t'')*in_s(t-t''),dt'',-Inf,+Inf)			output from the linear system</pre><br>\n'...
    'which in this case becomes<br>\n'...
    '<pre>      out(t) = Integral(<br>\n'...
    '                 1/(m*w1)*exp(-t./(2*tau)).*sin(t.*w1) * F0,<br>\n',...
    '                   dt'',0,t)<br>\n'...
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
        p = param({'F0', ['The amplitude of the force sine [N].']}, ...
          paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % parameter 'toff'
        p = param({'toff', ['The start time of the force sine [s].']}, ...
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
  w1 = sqrt(w02 - 1/(4*tau^2));                  % Free decay frequency
  step = cos((t-toff).*w1)+sin((t-toff).*w1).*(1/(2*tau*w1));	% Step input response
  decay_step = exp(-(t-toff)./(2*tau));                     % Exponential decay
  
  % Step response in displacement
  out_step = F0/(m*w02) * (1 - decay_step.*step);
  
  % Pads the region before the step with zeros
  out_step(t < toff) = 0;
  
  % Initial conditions evolution
  phase = -atan2(v0*w1, x0*w02+v0/(2*tau));
  
  A0 = 1/cos(phase) * (x0 + v0/(2*tau*w02));
  
  step_phase = cos(t.*w1 + phase) + sin(t.*w1 + phase).*(1/(2*tau*w1));
  decay = exp(-t./(2*tau));                     % Exponential decay
  out_initial = A0 * decay .* step_phase;
  
  % Total displacement
  y = out_step + out_initial;
  
  % Build a time-series data object
  % If the starting time was not 0, zero-pads at beginning and cuts the end
  
  tsd = tsdata(t,y,fs);
  
  % Set X-units, Y-units
  tsd.setXunits('s');
  tsd.setYunits('m');
  
  % Build the AO and set its name
  a = ao(tsd);
  
  a.setName('Step');
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
