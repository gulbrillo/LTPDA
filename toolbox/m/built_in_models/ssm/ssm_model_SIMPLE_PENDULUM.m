% SIMPLE_PENDULUM A statespace model of a simple pendulum.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SIMPLE_PENDULUM A statespace model of a simple pendulum.
%
% CALL:
%           p = ssm(plist('built-in','ssm_model_SIMPLE_PENDULUM'))
%
%
% OUTPUTS:
%           - p is an SSM object
%
%
% REFERENCES:
%
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('ssm_model_SIMPLE_PENDULUM')">Model Information</a>
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = ssm_model_SIMPLE_PENDULUM(varargin)  
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
  desc = 'A built-in model that constructs a statespace model of a simple pendulum.';
end

function doc = getModelDocumentation
  doc = sprintf([...
    '<br>The model transfers the commanded forces to the resulting displacement of the mass.<br>\n'...
    ]);
end

% default version is always the first one
function vt = versionTable()
  
  vt = {...
    'Standard', @versionStandard, ...
    };
  
end

% This is the DC readout configuration model
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
          'This is a model for a simple pendulum.'
          ]);
        
      case 'parameters'
        
        params.names        = {'M', 'L', 'Q'};
        params.values       = [5.6 1 10];
        params.units        = unit('kg', 'm', '');
        params.descriptions = {'Mass', 'Pendulum length', 'Pendulum Q'};
  
        varargout{1} = params;
        
      case 'inputs'
        
        inputnames    = {'COMMAND'};
        inputdescription = {'Commanded force applied to mass'};
        inputvarnames = {{'F_x'}};
        inputvarunits  = {unit('N') };
        inputvardescription = { {'x-axis force applied to mass'}};
        
        % build input blocks
        inputs = ssmblock.makeBlocksWithData(inputnames, inputdescription, inputvarnames, inputvarunits, inputvardescription);
        
        varargout{1} = inputs;
        
      case 'states'
        
        ssnames = {'PENDULUM_1D'};
        ssdescription = {'Position and velocity'};
        ssvarnames = {{'x' 'xdot'}};
        ssvarunits = {[unit('m'),unit('m s^-1')]};
        ssvardescription = {{'Position' 'Velocity'}};
        
        % build state blocks
        states =  ssmblock.makeBlocksWithData(ssnames, ssdescription, ssvarnames, ssvarunits, ssvardescription);
        
        varargout{1} = states;
        
      case 'outputs'
        
        outputnames    = {'PENDULUM'};
        outputdescription = {'Position'};
        outputvarnames = ...
          {{'x'}};
        outputvarunits = {unit('m') };
        outputvardescription = {{'Position'}};
        
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
  
  % build inout plist
  pl = varargin{1};
  
  % physical parameters for this system
  params  = versionStandard('parameters');  
  
  % If the user didn't give a 'param names' key to set parameter values,
  % perhaps they gave individual parameter names
  pl = ssm.modelHelper_processInputPlist(pl, ssm_model_SIMPLE_PENDULUM('plist', 'Standard'));
  
  % processing parameters and declaring variables depending on user needs
  [sys.params, sys.numparams] = ssm.modelHelper_declareParameters(pl, params.names, params.values, params.descriptions, params.units);
  
  % here computation of the system's matrices
  A = [0 1;-9.8/L -sqrt(9.8/L)/Q];
  B = [0; 1/M];
  C = [1 0];
  
  sys.amats    = {A};
  sys.bmats    = {B};
  sys.cmats    = {C};
  sys.dmats    = {[0]};  
  
  sys.timestep = 0;
  
  sys.name = 'Simple Pendulum';
  sys.description = 'A simple 1D pendulum';

  % set system inputs, outputs and states
  sys.inputs  = versionStandard('inputs');
  sys.states  = versionStandard('states');
  sys.outputs = versionStandard('outputs');
  
  % output
  varargout{1} = ssm(sys);
  
end



%--------------------------------------------------------------------------
% AUTHORS SHOULD NOT NEED TO EDIT BELOW HERE
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Get Version
%--------------------------------------------------------------------------
function v = getVersion
  
  v = '';
  
end
