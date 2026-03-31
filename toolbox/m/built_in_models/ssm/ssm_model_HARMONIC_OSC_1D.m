% HARMONIC_OSC_1D A statespace model of the HARMONIC OSCILLATOR 1D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: A statespace model of the HARMONIC OSCILLATOR 1D
%
% CALL:
%           HARMONIC_OSC_1D = ssm(plist('built-in','HARMONIC_OSC_1D'))
%
%
% OUTPUTS:
%           - HARMONIC_OSC_1D is an SSM object
%
%
% REFERENCES:
%
%
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('ssm_model_HARMONIC_OSC_1D')">Model Information</a>
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = ssm_model_HARMONIC_OSC_1D(varargin)

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
  desc = 'A built-in model that constructs a statespace model for the HARMONIC_OSC_1D.';
end

function doc = getModelDocumentation
  doc = sprintf([...
    '<br>It constructs a simple harmonic oscillator in 1 dimension.<br>\n'...
    ]);
end

% default version is always the first one
function vt = versionTable()
  
  vt = {...
    'Standard', @versionStandard, ...
    'Fitting', @versionFitting,...
    };
  
end

% This is the standard FEEPS model
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
          'This is the standard model for the HARMONIC OSCILLATOR in 1D.'
          ]);
        
      case 'parameters'
        
        params.names        = {'M', 'K', 'VBETA'};
        params.values       = [1 1 1];
        params.units        = unit('kg', 'kg s^-2', 'kg s^-1');
        params.descriptions = {'Mass', 'Spring constant', 'Viscous friction coefficient'};
        
        varargout{1} = params;
        
      case 'inputs'
        
        inputnames    = {'Command' 'noise'};
        inputdescription = {'Force applied to the point-like particle' 'readout noise'};
        inputvarnames = {{'Force'} {'readout'}};
        inputvarunits  = { unit('kg m s^-2') unit('m') };
        inputvardescription = {{'Force applied to the point-like particle'} {'readout noise'}};

        
        % build input blocks
        inputs = ssmblock.makeBlocksWithData(inputnames, inputdescription, inputvarnames, inputvarunits, inputvardescription);
        
        varargout{1} = inputs;
        
      case 'states'
        
        ssnames = {'HARMONIC_OSC_1D'};
        ssdescription = {'Position and velocity'};
        ssvarnames = {{'x' 'xdot'}};
        ssvarunits = {[unit('m'),unit('m s^-1')]};
        ssvardescription = {{'Position' 'Velocity'}};
        
        % build state blocks
        states =  ssmblock.makeBlocksWithData(ssnames, ssdescription, ssvarnames, ssvarunits, ssvardescription);
        
        varargout{1} = states;
        
      case 'outputs'
        
        outputnames    = {'HARMONIC_OSC_1D'};
        outputdescription = {'Position'};
        outputvarnames = ...
          {{'position'}};
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
  
  % build input plist
  pl = copy(varargin{1}, 1);
  
  % physical parameters for this system
  params  = versionStandard('parameters');    
  
  % If the user didn't give a 'param names' key to set parameter values,
  % perhaps they gave individual parameter names
  pl = ssm.modelHelper_processInputPlist(pl, ssm_model_HARMONIC_OSC_1D('plist', 'Standard'));
  
  % processing parameters and declaring variables depending on user needs
  [sys.params, sys.numparams] = ssm.modelHelper_declareParameters(pl, params.names, params.values, params.descriptions, params.units);
  
  % here computation of the system's matrices
  A = [0 1;-1*K/M -1*VBETA/M];
  Bforce = [0;1/M];
  Breadout = [0;0];
  % as an alternative
  % B = [0 0;1/m 0];
  C = [1 0];
  Dforce = [0];
  Dreadout = [1];
  % as an alternative
  % D = [0 1];
  
  sys.amats    = {A};
  sys.bmats    = {Bforce Breadout};
  sys.cmats    = {C};
  sys.dmats    = {Dforce Dreadout};
  
  sys.timestep = 0;
  
  sys.name = 'HARMONIC_OSC_1D';
  sys.description = 'Harmonic oscillator';
  
  % set system inputs, outputs and states
  sys.inputs  = versionStandard('inputs');
  sys.states  = versionStandard('states');
  sys.outputs = versionStandard('outputs');
  
  sys = ssm(sys);
  
  varargout{1} = sys;
  
end

% this version is suited to build with symbolic params
function varargout = versionFitting(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % optional parameters: values
        p = param({'M', 'mass in kg'}, paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % optional parameters: values
        p = param({'K', 'spring constant in kg s^-2'}, paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % optional parameters: values
        p = param({'DAMP', 'damping coefficient in kg s^-1'}, paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % optional parameters: from the generic constructor
        pl_builtin = ssm.getDefaultPlist('from built-in model');
        pl = combine(pl, pl_builtin.pset('built-in', mfilename));
                
        % set output
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = sprintf([...
          'This is the fitting model for the HARMONIC OSCILLATOR in 1D.'
          ]);
        
      case 'parameters'
        
        params.names        = {'M', 'K', 'DAMP'};
        params.values       = [1 1 1];
        params.units        = unit('kg', 'kg s^-2', 'kg s^-1');
        params.descriptions = {'Mass', 'Spring constant', 'Viscous friction coefficient'};
        
        varargout{1} = params;
        
      case 'inputs'
        
        inputnames    = {'Command' 'noise'};
        inputdescription = {'Force applied to the point-like particle' 'readout noise'};
        inputvarnames = {{'Force'} {'readout'}};
        inputvarunits  = { unit('kg m s^-2') unit('m') };
        inputvardescription = {{'Force applied to the point-like particle'} {'readout noise'}};
        
        % build input blocks
        inputs = ssmblock.makeBlocksWithData(inputnames, inputdescription, inputvarnames, inputvarunits, inputvardescription);
        
        varargout{1} = inputs;
        
      case 'states'
        
        ssnames = {'HARMONIC_OSC_1D'};
        ssdescription = {'Position and velocity'};
        ssvarnames = {{'x' 'xdot'}};
        ssvarunits = {[unit('m'),unit('m s^-1')]};
        ssvardescription = {{'Position' 'Velocity'}};
        
        % build state blocks
        states =  ssmblock.makeBlocksWithData(ssnames, ssdescription, ssvarnames, ssvarunits, ssvardescription);
        
        varargout{1} = states;
        
      case 'outputs'
        
        outputnames    = {'HARMONIC_OSC_1D'};
        outputdescription = {'Position'};
        outputvarnames = ...
          {{'position'}};
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
  
  % build model
  pl = copy(varargin{1}, 1);
  
  % physical parameters for this system
  params  = versionFitting('parameters');    
  
  % If the user didn't give a 'param names' key to set parameter values,
  % perhaps they gave individual parameter names
  pl = ssm.modelHelper_processInputPlist(pl, ssm_model_HARMONIC_OSC_1D('plist', 'Standard'));
  
  % processing parameters and declaring variables depending on user needs
  [sys.params, sys.numparams] = ssm.modelHelper_declareParameters(pl, params.names, params.values, params.descriptions, params.units);
  
  % here computation of the system's matrices
  % here computation of the system's matrices
  A = [0 1;-1*K/M -1*DAMP/M];
  Bforce = [0;1/M];
  Breadout = [0;0];
  % as an alternative
  % B = [0 0;1/m 0];
  C = [1 0];
  Dforce = [0];
  Dreadout = [1];
  % as an alternative
  % D = [0 1];
  
  sys.amats    = {A};
  sys.bmats    = {Bforce Breadout};
  sys.cmats    = {C};
  sys.dmats    = {Dforce Dreadout};
  
  sys.timestep = 0;
  
  sys.name = 'HARMONIC_OSC_1D';
  sys.description = 'Harmonic oscillator';
  
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
  
  v = '';
  
end
