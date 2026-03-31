% A built-in model of class ao called oscillator_sine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: A built-in model of class ao called oscillator_sine
%
% CALL:
%           mdl = smodel(plist('built-in', 'oscillator_sine'));
%
% INPUTS:
%
%
% OUTPUTS:
%           mdl - an object of class smodel
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('smodel_model_oscillator_sine')">Model Information</a>
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
function varargout = smodel_model_oscillator_sine(varargin)
  
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
  desc = 'constructs the time-domain response of a mechanical oscillator to a sinewave applied exernal force.';
end

function doc = getModelDocumentation
  doc = sprintf([...
    ''...
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
  
  % Let's define the oscillator parameters:
  w02 = 'k/m';
  w1 = strrep('sqrt(w02 - 1/(4*tau^2))', 'w02', w02);                    % Free decay frequency
  T = strrep('1./((w02-(2*pi*f).^2).^2+(2*pi*f./tau).^2)', 'w02', w02); % Power transfer function  
  step = strrep('(cos((t-toff).*w1) + sin((t-toff).*w1).*(1/(2*tau*w1)))', 'w1', w1);	% Step input response
  decay = 'exp(-(t-toff)./(2*tau))';                                         % Exponential decay
  
  % For each phase component, we will calculate the transitory contribution
  out_transitory_phase = '-F0/(m*w1)*2*pi*f*T*decay.*(sin((t-toff)*w1).*(w02-(2*pi*f)^2)-step.*(w1/tau))';
  out_transitory_phase = strrep(out_transitory_phase, 'w1', w1);
  out_transitory_phase = strrep(out_transitory_phase, 'T', T);
  out_transitory_phase = strrep(out_transitory_phase, 'step', step);
  out_transitory_phase = strrep(out_transitory_phase, 'decay', decay);
  out_transitory_phase = strrep(out_transitory_phase, 'w02', w02);
  
  out_transitory_quad = '-F0/(m*w1)*T*decay.*(sin((t-toff)*w1).*((2*pi*f)^2/tau)+step.*w1*(w02-(2*pi*f)^2))';  
  out_transitory_quad = strrep(out_transitory_quad, 'w1', w1);
  out_transitory_quad = strrep(out_transitory_quad, 'T', T);
  out_transitory_quad = strrep(out_transitory_quad, 'step', step);
  out_transitory_quad = strrep(out_transitory_quad, 'decay', decay);
  out_transitory_quad = strrep(out_transitory_quad, 'w02', w02);
  
  % and the stationary contribution
  out_stationary_phase = '-F0/m*T*(2*pi*f/tau*cos((t-toff).*2*pi*f)+((2*pi*f)^2-w02)*sin((t-toff).*2*pi*f))';
  out_stationary_phase = strrep(out_stationary_phase, 'w1', w1);
  out_stationary_phase = strrep(out_stationary_phase, 'T', T);
  out_stationary_phase = strrep(out_stationary_phase, 'step', step);
  out_stationary_phase = strrep(out_stationary_phase, 'decay', decay);
  out_stationary_phase = strrep(out_stationary_phase, 'w02', w02);
  
  out_stationary_quad = '-F0/m*T*(-2*pi*f/tau*sin((t-toff).*2*pi*f)+((2*pi*f)^2-w02)*cos((t-toff).*2*pi*f))';
  out_stationary_quad = strrep(out_stationary_quad, 'w1', w1);
  out_stationary_quad = strrep(out_stationary_quad, 'T', T);
  out_stationary_quad = strrep(out_stationary_quad, 'step', step);
  out_stationary_quad = strrep(out_stationary_quad, 'decay', decay);
  out_stationary_quad = strrep(out_stationary_quad, 'w02', w02);
  
  % Initial conditions evolution
  phase = '-atan2(v0*w1,x0*w02+v0/(2*tau))';
  
  A0 = strrep('1/cos(phase)*(x0+v0/(2*tau*w02))', 'phase', phase);
  A0 = strrep(A0, 'w1', w1);
  A0 = strrep(A0, 'w02', w02);
  
  step_phase = strrep('(cos((t-toff).*w1+phase) + sin((t-toff).*w1+phase).*(1/(2*tau*w1)))', 'phase', phase);
  step_phase = strrep(step_phase, 'w1', w1);
  step_phase = strrep(step_phase, 'w02', w02);
  
  out_initial = [A0 ' .* ' decay '.* ' step_phase];
  
  % Let's finally calculate the total displacement output
  y = ['(' out_stationary_phase ' + ' out_transitory_phase ') * cos(phi)' ...
    ' + ' ...
    '(' out_stationary_quad ' + ' out_transitory_quad ') *  sin(phi)' ...
    ' + ' ...
    out_initial];
  
  a = smodel(y);
  a.setXvar('t');
  a.setParams({'m','k','tau','F0','f','phi','x0','v0','toff'},{[],[],[],[],[],[],[],[],[]});
  a.setYunits('m');
  a.setName('Oscillator sine response');
  a.setDescription('time-domain response of a mechanical oscillator to a sinewave applied exernal force');
  
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
