% SMD A statespace model of the Spring-Mass-Damper system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: A statespace model of the Spring-Mass-Damper
%
% CALL:
%           SMD = ssm(plist('built-in','SMD'))
%
%
% OUTPUTS:
%           - SMD is an SSM object
%
%
% REFERENCES:
%
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('ssm_model_SMD')">Model Information</a>
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = ssm_model_SMD(varargin)
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

function package = getPackageName
  package = 'ltpda';
end

function desc = getModelDescription
  desc = 'A built-in model that constructs a statespace model for the SMD.';
end

function doc = getModelDocumentation
  doc = sprintf([...
    '<br>It constructs a simple spring mass damper test system.<br>\n'...
    ]);
end

% default version is always the first one
function vt = versionTable()
  
  vt = {...
    'Standard', @versionStandard, ...
    };
  
end

% This is the standard SMD model
%
function varargout = versionStandard(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        % The plist for this version of this model
        pl = plist();
        
        % optional parameters: from the generic constructor
        pl = combine(pl, ssm.getDefaultPlist('from built-in model'));
        
        % set output
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = sprintf([...
          'This is the standard model for the SMD.'
          ]);
        
      case 'parameters'
        
        params.names  = {'SMD_W' 'SMD_C' 'SMD_S1' 'SMD_S2' 'SMD_B' 'SMD_D1'};
        params.values = [0.2 0.5 0 0 1 0];
        params.units = unit('s^-1', 's^-1', '', 's', '', 's^2');
        params.descriptions = {'Oscillator eigen-frequency' 'Oscillator damping factor'...
          'Gain sensing coefficient'  'Gain differential sensing coefficient' ...
          'Actuator gain' 'Actuation cross sensing coefficient'};
  
        varargout{1} = params;
        
      case 'inputs'
        
        inputnames    = {'CMD' 'DIST_SMD'};
        inputdescription = {'force noise' 'observation noise'};
        inputvarnames = {{'F'} {'F' 'S'}};
        inputvarunits = {unit('kg m s^-2') [unit('kg m s^-2') unit('m')]};
        inputvardescription = { ...
          { ...
          'Force' ...
          } ... % CMD
          { ...
          'Force' ...
          'Signal' ...
          }... % DIST_SMD
          };
        
        % build input blocks
        inputs = ssmblock.makeBlocksWithData(inputnames, inputdescription, inputvarnames, inputvarunits, inputvardescription);
        
        varargout{1} = inputs;
        
      case 'states'
        
        ssnames    = {'SMD'};
        ssdescription = {'TM position and speed'};
        ssvarnames = {{'x' 'xdot'}};
        ssvarunits={[unit('m') unit('m s^-1')]};
        ssvardescription = {...
          {...
          'position' ...
          'velocity' ...
          }... % SMD
          };
        
        % build state blocks
        states =  ssmblock.makeBlocksWithData(ssnames, ssdescription, ssvarnames, ssvarunits, ssvardescription);
        
        varargout{1} = states;
        
      case 'outputs'
        
        outputnames    = {'SMD'};
        outputdescription = {'observed position'};
        outputvarnames ={{'OBS'}};
        outputvarunits={unit('m')};
        outputvardescription = {...
          {...
          'position' ...
          }... % SMD
          };
        
        % build output blocks
        outputs = ssmblock.makeBlocksWithData(outputnames, outputdescription, outputvarnames, outputvarunits, outputvardescription);
        
        varargout{1} = outputs;
        
      case 'info'
        varargout{1} = [];
        
      otherwise
        error('unknown inputs');
        
    end
    return;
  end
  
  % build input plist
  pl = copy(varargin{1}, 1);
  
  % physical parameters for this system
  params  = versionStandard('parameters');  

  % If the user didn't give a 'param names' key to set parameter values,
  % perhaps they gave individual parameter names
  pl = ssm.modelHelper_processInputPlist(pl, ssm_model_SMD('plist','Standard'));
  
  % processing parameters and declaring variables depending on user needs
  [sys.params, sys.numparams] = ssm.modelHelper_declareParameters(pl, params.names, params.values, params.descriptions, params.units);
  
  % here computation of the system's matrices
  sys.amats    = {[0 1 ; -SMD_W*SMD_W -2*SMD_C*SMD_W]};
  sys.cmats    = {[1+SMD_S1 SMD_S2]};
  sys.bmats    = {[0;SMD_B] [0 0; 1 0]};
  sys.dmats    = {SMD_D1 [0 1]};
  
  sys.timestep = 0;
  
  sys.name = 'SPRINGMASSDAMPER';
  sys.description = 'standard spring-mass-damper test system';
  
  % set system inputs, outputs and states
  sys.inputs  = versionStandard('inputs');
  sys.states  = versionStandard('states');
  sys.outputs = versionStandard('outputs');
  
  sys = ssm(sys);
  
  varargout{1} = sys;
  
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
