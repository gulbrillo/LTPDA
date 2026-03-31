% A built-in model of class ao called oscillator_step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: A built-in model of class ao called oscillator_step
%
% CALL:
%           mdl = smodel(plist('built-in', 'oscillator_step'));
%
% INPUTS:
%
%
% OUTPUTS:
%           mdl - an object of class smodel
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('smodel_model_oscillator_step')">Model Information</a>
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
function varargout = smodel_model_oscillator_step(varargin)
  
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
  desc = 'constructs the time-domain response of a mechanical oscillator to a step change in the applied exernal force.';
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
  step = strrep('(cos((t-toff).*w1) + sin((t-toff).*w1).*(1/(2*tau*w1)))', 'w1', w1);	% Step input response
  decay = 'exp(-(t-toff)./(2*tau))';                                         % Exponential decay
  
  % Step response in displacement
  out_step = strrep('F0/(m*w02)*(1-decay.*step)', 'step', step);
  out_step = strrep(out_step, 'decay', decay);
  out_step = strrep(out_step, 'w02', w02);
  
  % Initial conditions evolution
  phase = '-atan2(v0*w1,x0*w02+v0/(2*tau))'; 

  A0 = strrep('1/cos(phase)*(x0+v0/(2*tau*w02))', 'phase', phase);
  A0 = strrep(A0, 'w1', w1);
  A0 = strrep(A0, 'w02', w02);

  step_phase = strrep('(cos((t-toff).*w1+phase) + sin((t-toff).*w1+phase).*(1/(2*tau*w1)))', 'phase', phase);
  step_phase = strrep(step_phase, 'w1', w1);
  step_phase = strrep(step_phase, 'w02', w02);
  
  out_initial = [A0 ' .* ' decay '.* ' step_phase];
  
  % Total displacement
  y = [out_step ' + ' out_initial];
  
  
  a = smodel(y);
  a.setXvar('t');
  a.setParams({'k','m','tau','F0','x0','v0','toff'}, {[],[],[],[],[],[],[]});
  a.setYunits('m');
  a.setName('Oscillator step response');
  a.setDescription('time-domain response of a mechanical oscillator to a step change in the applied exernal force');
  
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
