% PLIST_MODEL_PHYSICAL_CONSTANTS constructs a PLIST with physical constants.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLIST_MODEL_PHYSICAL_CONSTANTS constructs a PLIST with
%              physical constants.
%
% CALL:
%           pl = plist(plist('built-in', 'physical_constants'));
%
% INPUTS:
%           additional parameters (see below)
%
% OUTPUTS:
%           pl - an PLIST object representing the physical constants
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('plist_model_physical_constants')">Model Information</a>
%
% MODEL CONTENT:
%   <a href="matlab:tohtml(plist(plist('built-in', 'physical_constants')))">Model Content</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = plist_model_physical_constants(varargin)
  
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
  desc = 'Constructs a plist with the physical constants.';
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
  
  % input PLIST
  pli = varargin{1};
  
  % build model
  pl = constructPhysicalConstantsPlist();
  
  % Define output
  varargout{1} = pl;
  
end

function plOut = constructPhysicalConstantsPlist()
  
  persistent pl;
  
  if ~exist('pl', 'var') || isempty(pl)
    
    pl = plist();
    pl.setName('physical_constants');
    
    c     = 299792458;            % Speed of light in vacuum
    G     = 6.6742867e-11;        % Newtonian constant of gravitation
    h     = 6.6260689633e-34;     % Planck constant
    hred  = h/(2*pi);             % Reduced Planck constant
    
    me    = 9.1093821545e-31;     % Electron mass
    mp    = 1.67262163783e-27;    % Proton mass
    mn    = 1.674927351e-27;      % Neutron mass
    amu   = 1.660538921e-27;      % Unified atomic mass unit
    
    u0    = 4*pi*1e-7;            % Magnetic constant
    e0    = 1/(u0*c^2);           % Electric constant
    Z0    = u0*c;                 % Impedance of vacuum
    ke    = 1/(4*pi*e0);          % Coulomb's constant
    e     = 1.60217648740e-19;    % Elementary charge
    uB    = (e*hred)/(2*me);      % Bohr magneton
    G0    = (2*e^2)/h;            % Conductance quantum
    G0inv = h/(2*e^2);            % Inverse conductance quantum
    KJ    = (2*e)/h;              % Josephson constant
    O0    = h/(2*e);              % Magnetic flux quantum
    uN    = (e*hred)/(2*mp);      % Nuclear magneton
    RK    = h / e^2;              % von Klitzing constant

    alpha = (u0*e^2*c)/(2*h);     % fine-structure constant
    Rinf  = (alpha^2*me*c)/(2*h); % Rydberg constant
    a0    = alpha/(4*pi*Rinf);    % Bohr radius
    re    = e^2/(4*pi*e0*me*c^2); % Classical electron radius
    Eh    = 2*Rinf*h*c;           % Hartree energy
    
    kB        = 1.3806504e-23;    % Boltzmann constant
    Na        = 6.02214129e23;    % Avogadro's number
    R         = 8.3144621;        % Gas constant
    
    
    %--------------------------------------------------------------------------
    %                           UNIVERSAL CONSTANTS 
    %--------------------------------------------------------------------------
    
    % C: Speed of light in vacuum.
    p = param({'C', 'Speed of light in vacuum'}, ...
      paramValue.DOUBLE_VALUE(c));
    p.setProperty('units', 'm s^-1');
    p.setProperty('error', []);
    p.setProperty('subsystem', 'universal');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % G: Newtonian constant of gravitation
    p = param({'G', 'Newtonian constant of gravitation'}, ...
      paramValue.DOUBLE_VALUE(G));
    p.setProperty('units', 'm^3 kg^-1 s^-2');
    p.setProperty('error', 1e-4);
    p.setProperty('subsystem', 'universal');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % h: Planck constant
    p = param({'h', 'Planck constant'}, ...
      paramValue.DOUBLE_VALUE(h));
    p.setProperty('units', 'J s');
    p.setProperty('error', 5e-8);
    p.setProperty('subsystem', 'universal');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % PLANCK_CONST: Planck constant
    p = param({'PLANCK_CONST', 'Planck constant'}, ...
      paramValue.DOUBLE_VALUE(h));
    p.setProperty('units', 'J s');
    p.setProperty('error', 5e-8);
    p.setProperty('subsystem', 'universal');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % RED_PLANCK_CONST: Reduced Planck constant
    p = param({'RED_PLANCK_CONST', 'Reduced Planck constant (h/(2*pi))'}, ...
      paramValue.DOUBLE_VALUE(hred));
    p.setProperty('units', 'J s');
    p.setProperty('error', 5e-8);
    p.setProperty('subsystem', 'universal');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    
    %--------------------------------------------------------------------------
    %                           ELECTROMAGNETIC CONSTANTS
    %--------------------------------------------------------------------------
    
    % MAGNETIC_CONST : Magnetic constant
    p = param({'MAGNETIC_CONST', 'Magnetic constant'}, ...
      paramValue.DOUBLE_VALUE(u0));
    p.setProperty('units', 'N A^-2');
    p.setProperty('error', []);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % mu0 : Magnetic constant
    p = param({'mu0', 'Magnetic constant'}, ...
      paramValue.DOUBLE_VALUE(u0));
    p.setProperty('units', 'N A^-2');
    p.setProperty('error', []);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % u0 : Magnetic constant
    p = param({'u0', 'Magnetic constant'}, ...
      paramValue.DOUBLE_VALUE(u0));
    p.setProperty('units', 'N A^-2');
    p.setProperty('error', []);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % ELECTRIC_CONST : Electric constant
    p = param({'ELECTRIC_CONST', 'Electric constant'}, ...
      paramValue.DOUBLE_VALUE(e0));
    p.setProperty('units', 'F m^-1');
    p.setProperty('error', []);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % e0 : Electric constant
    p = param({'e0', 'Electric constant'}, ...
      paramValue.DOUBLE_VALUE(e0));
    p.setProperty('units', 'F m^-1');
    p.setProperty('error', []);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % epsilon0 : Electric constant
    p = param({'epsilon0', 'Electric constant'}, ...
      paramValue.DOUBLE_VALUE(e0));
    p.setProperty('units', 'F m^-1');
    p.setProperty('error', []);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % IMPEDANCE_VACUUM : Characteristic impedance of vacuum
    p = param({'IMPEDANCE_VACUUM', 'Characteristic impedance of vacuum'}, ...
      paramValue.DOUBLE_VALUE(Z0));
    p.setProperty('units', 'Ohm');
    p.setProperty('error', []);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % COULOMB_CONST: Coulomb's constant
    p = param({'COULOMB_CONST', 'Coulomb''s constant'}, ...
      paramValue.DOUBLE_VALUE(ke));
    p.setProperty('units', 'N m^2 C^-2');
    p.setProperty('error', []);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % ELEMENTARY_CHARGE : Elementary charge
    p = param({'ELEMENTARY_CHARGE', 'Elementary charge'}, ...
      paramValue.DOUBLE_VALUE(e));
    p.setProperty('units', 'C');
    p.setProperty('error', 2.5e-8);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % ELEMENTARY_CHARGE : Elementary charge
    p = param({'e', 'Elementary charge'}, ...
      paramValue.DOUBLE_VALUE(e));
    p.setProperty('units', 'C');
    p.setProperty('error', 2.5e-8);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % BOHR_MAGNETON : Bohr magneton
    p = param({'BOHR_MAGNETON', 'Bohr magneton'}, ...
      paramValue.DOUBLE_VALUE(uB));
    p.setProperty('units', 'J T^-1');
    p.setProperty('error', 2.5e-8);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % CONDUCTANCE_QUANTUM : Conductance quantum
    p = param({'CONDUCTANCE_QUANTUM', 'Conductance quantum'}, ...
      paramValue.DOUBLE_VALUE(G0));
    p.setProperty('units', 'S');
    p.setProperty('error', 6.8e-10);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % INV_CONDUCTANCE_QUANTUM : Inverse conductance quantum
    p = param({'INV_CONDUCTANCE_QUANTUM', 'Inverse conductance quantum'}, ...
      paramValue.DOUBLE_VALUE(G0inv));
    p.setProperty('units', 'Ohm');
    p.setProperty('error', 6.8e-10);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % JOSEPHSON_CONST : Josephson constant
    p = param({'JOSEPHSON_CONST', 'Josephson constant'}, ...
      paramValue.DOUBLE_VALUE(KJ));
    p.setProperty('units', 'Hz V^-1');
    p.setProperty('error', 2.5e-8);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % MAGNETIC_FLUX_QUANTUM : Magnetic flux quantum
    p = param({'MAGNETIC_FLUX_QUANTUM', 'Magnetic flux quantum'}, ...
      paramValue.DOUBLE_VALUE(O0));
    p.setProperty('units', 'Wb');
    p.setProperty('error', 2.5e-8);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % NUCLEAR_MAGNETON : Nuclear magneton
    p = param({'NUCLEAR_MAGNETON', 'Nuclear magneton'}, ...
      paramValue.DOUBLE_VALUE(uN));
    p.setProperty('units', 'J T^-1');
    p.setProperty('error', 8.6e-8);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % VON_KLITZING_CONST : von Klitzing constant
    p = param({'VON_KLITZING_CONST', 'von Klitzing constant'}, ...
      paramValue.DOUBLE_VALUE(RK));
    p.setProperty('units', 'Ohm');
    p.setProperty('error', 6.8e-10);
    p.setProperty('subsystem', 'electromagnetic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    
    %--------------------------------------------------------------------------
    %                           ATOMIC AND NUCLEAR CONSTANTS
    %--------------------------------------------------------------------------
    
    % BOHR_RADIUS : Bohr radius
    p = param({'BOHR_RADIUS', 'Bohr radius'}, ...
      paramValue.DOUBLE_VALUE(a0));
    p.setProperty('units', 'm');
    p.setProperty('error', 3.3e-9);
    p.setProperty('subsystem', 'atomic and nuclear');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % CLASSICAL_ELECTRON_RADIUS : Classical electron radius
    p = param({'CLASSICAL_ELECTRON_RADIUS', 'Classical electron radius'}, ...
      paramValue.DOUBLE_VALUE(re));
    p.setProperty('units', 'm');
    p.setProperty('error', 2.1e-9);
    p.setProperty('subsystem', 'atomic and nuclear');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % ELECTRON_MASS : Electron mass
    p = param({'ELECTRON_MASS', 'Electron mass'}, ...
      paramValue.DOUBLE_VALUE(me));
    p.setProperty('units', 'kg');
    p.setProperty('error', 5e-8);
    p.setProperty('subsystem', 'atomic and nuclear');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % FINE_STRUCTURE_CONST : Fine-structure constant
    p = param({'FINE_STRUCTURE_CONST', 'Fine-structure constant'}, ...
      paramValue.DOUBLE_VALUE(alpha));
    p.setProperty('units', '');
    p.setProperty('error', 6.8e-10);
    p.setProperty('subsystem', 'atomic and nuclear');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % HARTREE_ENERGY : Hartree energy
    p = param({'HARTREE_ENERGY', 'Hartree energy'}, ...
      paramValue.DOUBLE_VALUE(Eh));
    p.setProperty('units', 'J');
    p.setProperty('error', 1.7e-7);
    p.setProperty('subsystem', 'atomic and nuclear');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % PROTON_MASS : Proton mass
    p = param({'PROTON_MASS', 'Proton mass'}, ...
      paramValue.DOUBLE_VALUE(mp));
    p.setProperty('units', 'kg');
    p.setProperty('error', 5e-8);
    p.setProperty('subsystem', 'atomic and nuclear');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % NEUTRON_MASS : Neutron mass
    p = param({'NEUTRON_MASS', 'Neutron mass'}, ...
      paramValue.DOUBLE_VALUE(mn));
    p.setProperty('units', 'kg');
    p.setProperty('error', 1.4e-8);
    p.setProperty('subsystem', 'atomic and nuclear');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Neutron');
    pl.append(p);
    
    % ATOMIC_MASS_UNIT : Unified atomic mass unit
    p = param({'ATOMIC_MASS_UNIT', 'Unified atomic mass unit'}, ...
      paramValue.DOUBLE_VALUE(amu));
    p.setProperty('units', 'kg');
    p.setProperty('error', 7.3e-35);
    p.setProperty('subsystem', 'atomic and nuclear');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % RYDBERG_CONST : Rydberg constant
    p = param({'RYDBERG_CONST', 'Rydberg constant'}, ...
      paramValue.DOUBLE_VALUE(Rinf));
    p.setProperty('units', 'm^-1');
    p.setProperty('error', 6.6e-12);
    p.setProperty('subsystem', 'atomic and nuclear');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    
    %--------------------------------------------------------------------------
    %                           THERMODYNAMIC CONSTANTS
    %--------------------------------------------------------------------------
    
    % BOLTZMANN_CONST : Boltzmann constant
    p = param({'BOLTZMANN_CONST', 'Boltzmann constant'}, ...
      paramValue.DOUBLE_VALUE(kB));
    p.setProperty('units', 'J K^-1');
    p.setProperty('error', 1.3e-28);
    p.setProperty('subsystem', 'thermodynamic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);

    % kB : Boltzmann constant
    p = param({'kB', 'Boltzmann constant'}, ...
      paramValue.DOUBLE_VALUE(kB));
    p.setProperty('units', 'J K^-1');
    p.setProperty('error', 1.3e-28);
    p.setProperty('subsystem', 'thermodynamic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % Na : Avogadro's number
    p = param({'Na', 'Avogadro''s number'}, ...
      paramValue.DOUBLE_VALUE(Na));
    p.setProperty('units', 'mol^-1');
    p.setProperty('error', 2.7e15);
    p.setProperty('subsystem', 'thermodynamic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    % R : gas constant
    p = param({'R', 'gas constant'}, ...
      paramValue.DOUBLE_VALUE(R));
    p.setProperty('units', 'J K^-1 mol^-1');
    p.setProperty('error', 7.5e-5);
    p.setProperty('subsystem', 'thermodynamic');
    p.setProperty('reference', 'http://en.wikipedia.org/wiki/Physical_constants');
    pl.append(p);
    
    
  end
  plOut = pl;
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

