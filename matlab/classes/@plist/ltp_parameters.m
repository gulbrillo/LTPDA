% LTP/LPF Parameter plist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  To be completed
%
% CALL :
%   s??
%
% PARAMETERS :
%   ??
%
%  VERSION :
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pl = ltp_parameters(varargin)
  
  if nargin == 1
    subsystemName = varargin{1};
    if ~ischar(subsystemName)
      error('this function takes a char as an input')
    end
    % modelNames = {'FEEPS_properties' 'CAPACT1_properties' 'CAPACT2_properties' 'SC_properties' 'TM_properties' 'IFO_properties'},;
    switch upper(subsystemName)
      case 'FEEPS'
        pl = FEEPS_properties;
      case 'CAPACT1'
        pl = CAPACT1_properties;
      case 'CAPACT2'
        pl = CAPACT2_properties;
      case 'SC'
        pl = SC_properties;
      case 'TM'
        pl = TM_properties;
      case 'IFO'
        pl = IFO_properties;
      otherwise
      models = { 'FEEPS' 'CAPACT1' 'CAPACT2' 'SC' 'TM' 'IFO'};
      error('Unknown model. Please use one of the following models. %s', utils.helper.val2str(models))
    end
  else
    pl = FEEPS_properties;
    pl.combine(CAPACT1_properties);
    pl.combine(CAPACT2_properties);
    pl.combine(SC_properties);
    pl.combine(TM_properties);
    pl.combine(IFO_properties);
  end
end

function pl = FEEPS_properties()
  
  pl = plist();
  
  % FEEP delay for action on X
  p = param({'FEEPS_TAU_X','FEEP delay for action on X'}, ...
    paramValue.DOUBLE_VALUE(0.066762));
  p.setProperty('units', 'sec');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP delay for action on Y
  p = param({'FEEPS_TAU_Y','FEEP delay for action on Y'}, ...
    paramValue.DOUBLE_VALUE(0.066762));
  p.setProperty('units', 'sec');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP delay for action on Z
  p = param({'FEEPS_TAU_Z','FEEP delay for action on Z'}, ...
    paramValue.DOUBLE_VALUE(0.066762));
  p.setProperty('units', 'sec');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP delay for action on theta
  p = param({'FEEPS_TAU_THETA','FEEP delay for action on theta'}, ...
    paramValue.DOUBLE_VALUE(0.066762));
  p.setProperty('units', 'sec');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP delay for action on eta
  p = param({'FEEPS_TAU_ETA','FEEP delay for action on eta'}, ...
    paramValue.DOUBLE_VALUE(0.066762));
  p.setProperty('units', 'sec');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP delay for action on phi
  p = param({'FEEPS_TAU_PHI','FEEP delay for action on phi'}, ...
    paramValue.DOUBLE_VALUE(0.066762));
  p.setProperty('units', 'sec');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between X and X
  p = param({'FEEPS_XX','FEEP cross talk between X and X'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between X and Y
  p = param({'FEEPS_XY','FEEP cross talk between X and Y'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between X and Z
  p = param({'FEEPS_XZ','FEEP cross talk between X and Z'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between X and theta
  p = param({'FEEPS_XTHETA','FEEP cross talk between X and theta'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between X and eta
  p = param({'FEEPS_XETA','FEEP cross talk between X and eta'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between Y and phi
  p = param({'FEEPS_XPHI','FEEP cross talk between Y and phi'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between Y and X
  p = param({'FEEPS_YX','FEEP cross talk between Y and X'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between Y and Y
  p = param({'FEEPS_YY','FEEP cross talk between Y and Y'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between Y and Z
  p = param({'FEEPS_YZ','FEEP cross talk between Y and Z'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between Y and theta
  p = param({'FEEPS_YTHETA','FEEP cross talk between Y and theta'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between Y and eta
  p = param({'FEEPS_YETA','FEEP cross talk between Y and eta'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between Y and phi
  p = param({'FEEPS_YPHI','FEEP cross talk between Y and phi'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between Z and X
  p = param({'FEEPS_ZX','FEEP cross talk between Z and X'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between Z and Y
  p = param({'FEEPS_ZY','FEEP cross talk between Z and Y'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between Z and Z
  p = param({'FEEPS_ZZ','FEEP cross talk between Z and Z'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between Z and theta
  p = param({'FEEPS_ZTHETA','FEEP cross talk between Z and theta'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between Z and eta
  p = param({'FEEPS_ZETA','FEEP cross talk between Z and eta'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between Z and phi
  p = param({'FEEPS_ZPHI','FEEP cross talk between Z and phi'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between theta and X
  p = param({'FEEPS_THETAX','FEEP cross talk between theta and X'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between theta and Y
  p = param({'FEEPS_THETAY','FEEP cross talk between theta and Y'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between theta and Z
  p = param({'FEEPS_THETAZ','FEEP cross talk between theta and Z'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between theta and theta
  p = param({'FEEPS_THETATHETA','FEEP cross talk between theta and theta'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between theta and eta
  p = param({'FEEPS_THETAETA','FEEP cross talk between theta and eta'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between theta and phi
  p = param({'FEEPS_THETAPHI','FEEP cross talk between theta and phi'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between eta and X
  p = param({'FEEPS_ETAX','FEEP cross talk between eta and X'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between eta and Y
  p = param({'FEEPS_ETAY','FEEP cross talk between eta and Y'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between eta and Z
  p = param({'FEEPS_ETAZ','FEEP cross talk between eta and Z'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between eta and theta
  p = param({'FEEPS_ETATHETA','FEEP cross talk between eta and theta'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between eta and eta
  p = param({'FEEPS_ETAETA','FEEP cross talk between eta and eta'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between eta and phi
  p = param({'FEEPS_ETAPHI','FEEP cross talk between eta and phi'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between phi and X
  p = param({'FEEPS_PHIX','FEEP cross talk between phi and X'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between phi and Y
  p = param({'FEEPS_PHIY','FEEP cross talk between phi and Y'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between phi and Z
  p = param({'FEEPS_PHIZ','FEEP cross talk between phi and Z'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between phi and theta
  p = param({'FEEPS_PHITHETA','FEEP cross talk between phi and theta'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between phi and eta
  p = param({'FEEPS_PHIETA','FEEP cross talk between phi and eta'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % FEEP cross talk between phi and phi
  p = param({'FEEPS_PHIPHI','FEEP cross talk between phi and phi'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'FEEPS');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % X position of CoM of SC
  p = param({'rB_M_X','X position of CoM of SC'}, ...
    paramValue.DOUBLE_VALUE(5e-3));
  p.setProperty('units', 'm');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'unknown');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % Y position of CoM of SC
  p = param({'rB_M_Y','Y position of CoM of SC'}, ...
    paramValue.DOUBLE_VALUE(6e-3));
  p.setProperty('units', 'm');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'unknown');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % Z position of CoM of SC
  p = param({'rB_M_Z','Z position of CoM of SC'}, ...
    paramValue.DOUBLE_VALUE(470e-3));
  p.setProperty('units', 'm');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'unknown');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
end
function pl = CAPACT1_properties()
  
  pl = plist();
  
  % TM1 X to X Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_XX','TM1 X to X Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 X to Y Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_XY','TM1 X to Y Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.0011));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 X to Z Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_XZ','TM1 X to Z Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.0011));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 X to theta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_XTHETA','TM1 X to theta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.21739));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 X to eta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_XETA','TM1 X to eta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.21739));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 X to phi Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_XPHI','TM1 X to phi Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.39131));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 Y to X Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_YX','TM1 Y to X Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.0011));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 Y to Y Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_YY','TM1 Y to Y Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 Y to Z Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_YZ','TM1 Y to Z Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.0011));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 Y to theta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_YTHETA','TM1 Y to theta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.39131));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 Y to eta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_YETA','TM1 Y to eta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.21739));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 Y to phi Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_YPHI','TM1 Y to phi Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.21739));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 Z to X Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_ZX','TM1 Z to X Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.0011));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 Z to Y Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_ZY','TM1 Z to Y Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.0011));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 Z to Z Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_ZZ','TM1 Z to Z Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 Z to theta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_ZTHETA','TM1 Z to theta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.21739));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 Z to eta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_ZETA','TM1 Z to eta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.39131));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 Z to phi Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_ZPHI','TM1 Z to phi Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.21739));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 theta to X Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_THETAX','TM1 theta to X Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 theta to Y Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_THETAY','TM1 theta to Y Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 theta to Z Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_THETAZ','TM1 theta to Z Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 theta to theta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_THETATHETA','TM1 theta to theta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 theta to eta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_THETAETA','TM1 theta to eta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.005));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 theta to phi Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_THETAPHI','TM1 theta to phi Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.005));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 eta to X Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_ETAX','TM1 eta to X Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 eta to Y Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_ETAY','TM1 eta to Y Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 eta to Z Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_ETAZ','TM1 eta to Z Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 eta to theta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_ETATHETA','TM1 eta to theta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.005));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 eta to eta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_ETAETA','TM1 eta to eta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 eta to phi Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_ETAPHI','TM1 eta to phi Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.005));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 phi to X Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_PHIX','TM1 phi to X Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 phi to Y Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_PHIY','TM1 phi to Y Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 phi to Z Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_PHIZ','TM1 phi to Z Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 phi to theta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_PHITHETA','TM1 phi to theta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.005));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 phi to eta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_PHIETA','TM1 phi to eta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.005));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM1 phi to phi Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM1_PHIPHI','TM1 phi to phi Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT1');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
end
function pl = CAPACT2_properties()
  
  pl = plist();
  
  % TM2 X to X Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_XX','TM2 X to X Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 X to Y Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_XY','TM2 X to Y Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.0011));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 X to Z Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_XZ','TM2 X to Z Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.0011));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 X to theta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_XTHETA','TM2 X to theta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.21739));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 X to eta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_XETA','TM2 X to eta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.21739));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 X to phi Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_XPHI','TM2 X to phi Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.39131));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 Y to X Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_YX','TM2 Y to X Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.0011));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 Y to Y Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_YY','TM2 Y to Y Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 Y to Z Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_YZ','TM2 Y to Z Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.0011));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 Y to theta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_YTHETA','TM2 Y to theta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.39131));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 Y to eta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_YETA','TM2 Y to eta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.21739));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 Y to phi Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_YPHI','TM2 Y to phi Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.21739));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 Z to X Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_ZX','TM2 Z to X Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.0011));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 Z to Y Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_ZY','TM2 Z to Y Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.0011));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 Z to Z Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_ZZ','TM2 Z to Z Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 Z to theta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_ZTHETA','TM2 Z to theta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.21739));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 Z to eta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_ZETA','TM2 Z to eta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.39131));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 Z to phi Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_ZPHI','TM2 Z to phi Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.21739));
  p.setProperty('units', 'rad m^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 theta to X Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_THETAX','TM2 theta to X Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 theta to Y Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_THETAY','TM2 theta to Y Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 theta to Z Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_THETAZ','TM2 theta to Z Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 theta to theta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_THETATHETA','TM2 theta to theta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 theta to eta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_THETAETA','TM2 theta to eta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.005));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 theta to phi Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_THETAPHI','TM2 theta to phi Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.005));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 eta to X Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_ETAX','TM2 eta to X Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 eta to Y Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_ETAY','TM2 eta to Y Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 eta to Z Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_ETAZ','TM2 eta to Z Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 eta to theta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_ETATHETA','TM2 eta to theta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.005));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 eta to eta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_ETAETA','TM2 eta to eta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 eta to phi Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_ETAPHI','TM2 eta to phi Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.005));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 phi to X Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_PHIX','TM2 phi to X Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 phi to Y Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_PHIY','TM2 phi to Y Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 phi to Z Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_PHIZ','TM2 phi to Z Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(4e-05));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 phi to theta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_PHITHETA','TM2 phi to theta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.005));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 phi to eta Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_PHIETA','TM2 phi to eta Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(0.005));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % TM2 phi to phi Capacitive actuation cross-talk (worst case) ?
  p = param({'CAPACT_TM2_PHIPHI','TM2 phi to phi Capacitive actuation cross-talk (worst case) ?'}, ...
    paramValue.DOUBLE_VALUE(1));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'CAPACT2');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
end
function pl = SC_properties()
  
  pl = plist();
  
  % X of housing 1
  p = param({'EOM_H1SC_X','X of housing 1'}, ...
    paramValue.DOUBLE_VALUE(0.183));
  p.setProperty('units', 'm');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % Y of housing 1
  p = param({'EOM_H1SC_Y','Y of housing 1'}, ...
    paramValue.DOUBLE_VALUE(-0.006));
  p.setProperty('units', 'm');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % Z of housing 1
  p = param({'EOM_H1SC_Z','Z of housing 1'}, ...
    paramValue.DOUBLE_VALUE(0.1393));
  p.setProperty('units', 'm');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % theta of housing 1
  p = param({'EOM_H1SC_THETA','theta of housing 1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % eta of housing 1
  p = param({'EOM_H1SC_ETA','eta of housing 1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % phi of housing 1
  p = param({'EOM_H1SC_PHI','phi of housing 1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % X of housing 2   (wrong !! should be -0.183)
  p = param({'EOM_H2SC_X','X of housing 2   (wrong !! should be -0.183)'}, ...
    paramValue.DOUBLE_VALUE(-0.193));
  p.setProperty('units', 'm');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % Y of housing 2
  p = param({'EOM_H2SC_Y','Y of housing 2'}, ...
    paramValue.DOUBLE_VALUE(-0.006));
  p.setProperty('units', 'm');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % Z of housing 2
  p = param({'EOM_H2SC_Z','Z of housing 2'}, ...
    paramValue.DOUBLE_VALUE(0.1393));
  p.setProperty('units', 'm');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % theta of housing 2
  p = param({'EOM_H2SC_THETA','theta of housing 2'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % eta of housing 2
  p = param({'EOM_H2SC_ETA','eta of housing 2'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % phi of housing 2
  p = param({'EOM_H2SC_PHI','phi of housing 2'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % SC mass
  p = param({'EOM_SC_M','SC mass'}, ...
    paramValue.DOUBLE_VALUE(422.7));
  p.setProperty('units', 'kg');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % SC Moment of inertia w.r.t. X
  p = param({'EOM_SC_IXX','SC Moment of inertia w.r.t. X'}, ...
    paramValue.DOUBLE_VALUE(202.5));
  p.setProperty('units', 'kg m^(2)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % SC Moment of inertia w.r.t. Y
  p = param({'EOM_SC_IYY','SC Moment of inertia w.r.t. Y'}, ...
    paramValue.DOUBLE_VALUE(209.7));
  p.setProperty('units', 'kg m^(2)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % SC Moment of inertia w.r.t. Z
  p = param({'EOM_SC_IZZ','SC Moment of inertia w.r.t. Z'}, ...
    paramValue.DOUBLE_VALUE(191.7));
  p.setProperty('units', 'kg m^(2)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % SC Moment of inertia w.r.t. XY
  p = param({'EOM_SC_IXY','SC Moment of inertia w.r.t. XY'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'kg m^(2)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % SC Moment of inertia w.r.t. XZ
  p = param({'EOM_SC_IXZ','SC Moment of inertia w.r.t. XZ'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'kg m^(2)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
  % SC Moment of inertia w.r.t. YZ
  p = param({'EOM_SC_IYZ','SC Moment of inertia w.r.t. YZ'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'kg m^(2)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'SC');
  p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
  pl.append(p);
  
end
function plOut = TM_properties()
  
  persistent pl;
  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = plist();
    
    % X of TM1
    p = param({'EOM_TM1H1_X','X of TM1'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'm');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % Y of TM1
    p = param({'EOM_TM1H1_Y','Y of TM1'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'm');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % Z of TM1
    p = param({'EOM_TM1H1_Z','Z of TM1'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'm');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % theta of TM1
    p = param({'EOM_TM1H1_THETA','theta of TM1'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % eta of TM1
    p = param({'EOM_TM1H1_ETA','eta of TM1'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % phi of TM1
    p = param({'EOM_TM1H1_PHI','phi of TM1'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % X of TM2
    p = param({'EOM_TM2H2_X','X of TM2'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'm');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % Y of TM2
    p = param({'EOM_TM2H2_Y','Y of TM2'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'm');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % Z of TM2
    p = param({'EOM_TM2H2_Z','Z of TM2'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'm');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % theta of TM2
    p = param({'EOM_TM2H2_THETA','theta of TM2'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % eta of TM2
    p = param({'EOM_TM2H2_ETA','eta of TM2'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % phi of TM2
    p = param({'EOM_TM2H2_PHI','phi of TM2'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % TM1 mass
    p = param({'EOM_TM1_M','TM1 mass'}, ...
      paramValue.DOUBLE_VALUE(1.96));
    p.setProperty('units', 'kg');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'none');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % TM1 Moment of inertia w.r.t. X
    p = param({'EOM_TM1_IXX','TM1 Moment of inertia w.r.t. X'}, ...
      paramValue.DOUBLE_VALUE(0.0006912));
    p.setProperty('units', 'kg m^(2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H1');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % TM1 Moment of inertia w.r.t. Y
    p = param({'EOM_TM1_IYY','TM1 Moment of inertia w.r.t. Y'}, ...
      paramValue.DOUBLE_VALUE(0.0006912));
    p.setProperty('units', 'kg m^(2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H1');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % TM1 Moment of inertia w.r.t. Z
    p = param({'EOM_TM1_IZZ','TM1 Moment of inertia w.r.t. Z'}, ...
      paramValue.DOUBLE_VALUE(0.0006912));
    p.setProperty('units', 'kg m^(2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H1');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % TM1 Moment of inertia w.r.t. XY
    p = param({'EOM_TM1_IXY','TM1 Moment of inertia w.r.t. XY'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'kg m^(2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H1');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % TM1 Moment of inertia w.r.t. XZ
    p = param({'EOM_TM1_IXZ','TM1 Moment of inertia w.r.t. XZ'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'kg m^(2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H1');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % TM1 Moment of inertia w.r.t. YZ
    p = param({'EOM_TM1_IYZ','TM1 Moment of inertia w.r.t. YZ'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'kg m^(2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H1');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % TM2 mass
    p = param({'EOM_TM2_M','TM2 mass'}, ...
      paramValue.DOUBLE_VALUE(1.96));
    p.setProperty('units', 'kg');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'none');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % TM2 Moment of inertia w.r.t. X
    p = param({'EOM_TM2_IXX','TM2 Moment of inertia w.r.t. X'}, ...
      paramValue.DOUBLE_VALUE(0.0006912));
    p.setProperty('units', 'kg m^(2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H2');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % TM2 Moment of inertia w.r.t. Y
    p = param({'EOM_TM2_IYY','TM2 Moment of inertia w.r.t. Y'}, ...
      paramValue.DOUBLE_VALUE(0.0006912));
    p.setProperty('units', 'kg m^(2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H2');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % TM2 Moment of inertia w.r.t. Z
    p = param({'EOM_TM2_IZZ','TM2 Moment of inertia w.r.t. Z'}, ...
      paramValue.DOUBLE_VALUE(0.0006912));
    p.setProperty('units', 'kg m^(2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H2');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % TM2 Moment of inertia w.r.t. XY
    p = param({'EOM_TM2_IXY','TM2 Moment of inertia w.r.t. XY'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'kg m^(2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H2');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % TM2 Moment of inertia w.r.t. XZ
    p = param({'EOM_TM2_IXZ','TM2 Moment of inertia w.r.t. XZ'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'kg m^(2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H2');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % TM2 Moment of inertia w.r.t. YZ
    p = param({'EOM_TM2_IYZ','TM2 Moment of inertia w.r.t. YZ'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 'kg m^(2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H2');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % stiffness of TM1 along X(there should be 2 stiffnesses electrostatic + gravitation)
    p = param({'EOM_TM1_STIFF_XX','stiffness of TM1 along X(there should be 2 stiffnesses electrostatic + gravitation)'}, ...
      paramValue.DOUBLE_VALUE(1.935e-06));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between X and Y
    p = param({'EOM_TM1_STIFF_XY','stiffness of TM1 between X and Y'}, ...
      paramValue.DOUBLE_VALUE(1.2716e-07));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between X and Z
    p = param({'EOM_TM1_STIFF_XZ','stiffness of TM1 between X and Z'}, ...
      paramValue.DOUBLE_VALUE(1.2716e-07));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between X and theta
    p = param({'EOM_TM1_STIFF_XTHETA','stiffness of TM1 between X and theta'}, ...
      paramValue.DOUBLE_VALUE(4.0031e-10));
    p.setProperty('units', 's^(-2) m rad^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between X and eta
    p = param({'EOM_TM1_STIFF_XETA','stiffness of TM1 between X and eta'}, ...
      paramValue.DOUBLE_VALUE(3.4003e-09));
    p.setProperty('units', 's^(-2) m rad^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between X and phi
    p = param({'EOM_TM1_STIFF_XPHI','stiffness of TM1 between X and phi'}, ...
      paramValue.DOUBLE_VALUE(2.4003e-09));
    p.setProperty('units', 's^(-2) m rad^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between Y and X
    p = param({'EOM_TM1_STIFF_YX','stiffness of TM1 between Y and X'}, ...
      paramValue.DOUBLE_VALUE(1.2716e-07));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 along Y
    p = param({'EOM_TM1_STIFF_YY','stiffness of TM1 along Y'}, ...
      paramValue.DOUBLE_VALUE(2.8115e-06));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between Y and Z
    p = param({'EOM_TM1_STIFF_YZ','stiffness of TM1 between Y and Z'}, ...
      paramValue.DOUBLE_VALUE(1.2716e-07));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between Y and theta
    p = param({'EOM_TM1_STIFF_YTHETA','stiffness of TM1 between Y and theta'}, ...
      paramValue.DOUBLE_VALUE(3.4003e-09));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between Y and eta
    p = param({'EOM_TM1_STIFF_YETA','stiffness of TM1 between Y and eta'}, ...
      paramValue.DOUBLE_VALUE(4.0031e-10));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between Y and phi
    p = param({'EOM_TM1_STIFF_YPHI','stiffness of TM1 between Y and phi'}, ...
      paramValue.DOUBLE_VALUE(1.4003e-09));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between Z and X
    p = param({'EOM_TM1_STIFF_ZX','stiffness of TM1 between Z and X'}, ...
      paramValue.DOUBLE_VALUE(1.2716e-07));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between Z and Y
    p = param({'EOM_TM1_STIFF_ZY','stiffness of TM1 between Z and Y'}, ...
      paramValue.DOUBLE_VALUE(1.2716e-07));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 along Z
    p = param({'EOM_TM1_STIFF_ZZ','stiffness of TM1 along Z'}, ...
      paramValue.DOUBLE_VALUE(4.6759e-06));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between Z and theta
    p = param({'EOM_TM1_STIFF_ZTHETA','stiffness of TM1 between Z and theta'}, ...
      paramValue.DOUBLE_VALUE(2.4003e-09));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between Z and eta
    p = param({'EOM_TM1_STIFF_ZETA','stiffness of TM1 between Z and eta'}, ...
      paramValue.DOUBLE_VALUE(1.4003e-09));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between Z and phi
    p = param({'EOM_TM1_STIFF_ZPHI','stiffness of TM1 between Z and phi'}, ...
      paramValue.DOUBLE_VALUE(4.0031e-10));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between theta and X
    p = param({'EOM_TM1_STIFF_THETAX','stiffness of TM1 between theta and X'}, ...
      paramValue.DOUBLE_VALUE(2.4572e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between theta and Y
    p = param({'EOM_TM1_STIFF_THETAY','stiffness of TM1 between theta and Y'}, ...
      paramValue.DOUBLE_VALUE(1.0851e-05));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between theta and Z
    p = param({'EOM_TM1_STIFF_THETAZ','stiffness of TM1 between theta and Z'}, ...
      paramValue.DOUBLE_VALUE(7.4482e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 along theta
    p = param({'EOM_TM1_STIFF_THETATHETA','stiffness of TM1 along theta'}, ...
      paramValue.DOUBLE_VALUE(5.456e-06));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between theta and eta
    p = param({'EOM_TM1_STIFF_THETAETA','stiffness of TM1 between theta and eta'}, ...
      paramValue.DOUBLE_VALUE(5.6515e-08));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between theta and phi
    p = param({'EOM_TM1_STIFF_THETAPHI','stiffness of TM1 between theta and phi'}, ...
      paramValue.DOUBLE_VALUE(5.6515e-08));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between eta and X
    p = param({'EOM_TM1_STIFF_ETAX','stiffness of TM1 between eta and X'}, ...
      paramValue.DOUBLE_VALUE(1.0851e-05));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between eta and Y
    p = param({'EOM_TM1_STIFF_ETAY','stiffness of TM1 between eta and Y'}, ...
      paramValue.DOUBLE_VALUE(2.4572e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between eta and Z
    p = param({'EOM_TM1_STIFF_ETAZ','stiffness of TM1 between eta and Z'}, ...
      paramValue.DOUBLE_VALUE(5.4682e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between eta and theta
    p = param({'EOM_TM1_STIFF_ETATHETA','stiffness of TM1 between eta and theta'}, ...
      paramValue.DOUBLE_VALUE(5.6515e-08));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 along eta
    p = param({'EOM_TM1_STIFF_ETAETA','stiffness of TM1 along eta'}, ...
      paramValue.DOUBLE_VALUE(5.3478e-06));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between eta and phi
    p = param({'EOM_TM1_STIFF_ETAPHI','stiffness of TM1 between eta and phi'}, ...
      paramValue.DOUBLE_VALUE(5.6515e-08));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between phi and X
    p = param({'EOM_TM1_STIFF_PHIX','stiffness of TM1 between phi and X'}, ...
      paramValue.DOUBLE_VALUE(7.4642e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between phi and Y
    p = param({'EOM_TM1_STIFF_PHIY','stiffness of TM1 between phi and Y'}, ...
      paramValue.DOUBLE_VALUE(5.4062e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between phi and Z
    p = param({'EOM_TM1_STIFF_PHIZ','stiffness of TM1 between phi and Z'}, ...
      paramValue.DOUBLE_VALUE(2.4572e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between phi and theta
    p = param({'EOM_TM1_STIFF_PHITHETA','stiffness of TM1 between phi and theta'}, ...
      paramValue.DOUBLE_VALUE(5.6515e-08));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 between phi and eta
    p = param({'EOM_TM1_STIFF_PHIETA','stiffness of TM1 between phi and eta'}, ...
      paramValue.DOUBLE_VALUE(5.6515e-08));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM1 along phi
    p = param({'EOM_TM1_STIFF_PHIPHI','stiffness of TM1 along phi'}, ...
      paramValue.DOUBLE_VALUE(3.9735e-06));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 along X(there should be 2
    p = param({'EOM_TM2_STIFF_XX','stiffness of TM2 along X(there should be 2'}, ...
      paramValue.DOUBLE_VALUE(2e-06));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between X and Y
    p = param({'EOM_TM2_STIFF_XY','stiffness of TM2 between X and Y'}, ...
      paramValue.DOUBLE_VALUE(1.35e-07));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between X and Z
    p = param({'EOM_TM2_STIFF_XZ','stiffness of TM2 between X and Z'}, ...
      paramValue.DOUBLE_VALUE(1.35e-07));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between X and theta
    p = param({'EOM_TM2_STIFF_XTHETA','stiffness of TM2 between X and theta'}, ...
      paramValue.DOUBLE_VALUE(4.25e-10));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between X and eta
    p = param({'EOM_TM2_STIFF_XETA','stiffness of TM2 between X and eta'}, ...
      paramValue.DOUBLE_VALUE(3.425e-09));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between X and phi
    p = param({'EOM_TM2_STIFF_XPHI','stiffness of TM2 between X and phi'}, ...
      paramValue.DOUBLE_VALUE(2.425e-09));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between Y and X
    p = param({'EOM_TM2_STIFF_YX','stiffness of TM2 between Y and X'}, ...
      paramValue.DOUBLE_VALUE(1.35e-07));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 along Y
    p = param({'EOM_TM2_STIFF_YY','stiffness of TM2 along Y'}, ...
      paramValue.DOUBLE_VALUE(2.867e-06));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between Y and Z
    p = param({'EOM_TM2_STIFF_YZ','stiffness of TM2 between Y and Z'}, ...
      paramValue.DOUBLE_VALUE(1.35e-07));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between Y and theta
    p = param({'EOM_TM2_STIFF_YTHETA','stiffness of TM2 between Y and theta'}, ...
      paramValue.DOUBLE_VALUE(3.425e-09));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between Y and eta
    p = param({'EOM_TM2_STIFF_YETA','stiffness of TM2 between Y and eta'}, ...
      paramValue.DOUBLE_VALUE(4.25e-10));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between Y and phi
    p = param({'EOM_TM2_STIFF_YPHI','stiffness of TM2 between Y and phi'}, ...
      paramValue.DOUBLE_VALUE(1.425e-09));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between Z and X
    p = param({'EOM_TM2_STIFF_ZX','stiffness of TM2 between Z and X'}, ...
      paramValue.DOUBLE_VALUE(1.35e-07));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between Z and Y
    p = param({'EOM_TM2_STIFF_ZY','stiffness of TM2 between Z and Y'}, ...
      paramValue.DOUBLE_VALUE(1.35e-07));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 along Z
    p = param({'EOM_TM2_STIFF_ZZ','stiffness of TM2 along Z'}, ...
      paramValue.DOUBLE_VALUE(4.816e-06));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between Z and theta
    p = param({'EOM_TM2_STIFF_ZTHETA','stiffness of TM2 between Z and theta'}, ...
      paramValue.DOUBLE_VALUE(2.425e-09));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between Z and eta
    p = param({'EOM_TM2_STIFF_ZETA','stiffness of TM2 between Z and eta'}, ...
      paramValue.DOUBLE_VALUE(1.425e-09));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between Z and phi
    p = param({'EOM_TM2_STIFF_ZPHI','stiffness of TM2 between Z and phi'}, ...
      paramValue.DOUBLE_VALUE(4.25e-10));
    p.setProperty('units', 's^(-2) m rad^(-1))');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between theta and X
    p = param({'EOM_TM2_STIFF_THETAX','stiffness of TM2 between theta and X'}, ...
      paramValue.DOUBLE_VALUE(2.6087e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between theta and Y
    p = param({'EOM_TM2_STIFF_THETAY','stiffness of TM2 between theta and Y'}, ...
      paramValue.DOUBLE_VALUE(1.1003e-05));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between theta and Z
    p = param({'EOM_TM2_STIFF_THETAZ','stiffness of TM2 between theta and Z'}, ...
      paramValue.DOUBLE_VALUE(7.5997e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 along theta
    p = param({'EOM_TM2_STIFF_THETATHETA','stiffness of TM2 along theta'}, ...
      paramValue.DOUBLE_VALUE(5.634e-06));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between theta and eta
    p = param({'EOM_TM2_STIFF_THETAETA','stiffness of TM2 between theta and eta'}, ...
      paramValue.DOUBLE_VALUE(6e-08));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between theta and phi
    p = param({'EOM_TM2_STIFF_THETAPHI','stiffness of TM2 between theta and phi'}, ...
      paramValue.DOUBLE_VALUE(6e-08));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between eta and X
    p = param({'EOM_TM2_STIFF_ETAX','stiffness of TM2 between eta and X'}, ...
      paramValue.DOUBLE_VALUE(1.1003e-05));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between eta and Y
    p = param({'EOM_TM2_STIFF_ETAY','stiffness of TM2 between eta and Y'}, ...
      paramValue.DOUBLE_VALUE(2.6087e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between eta and Z
    p = param({'EOM_TM2_STIFF_ETAZ','stiffness of TM2 between eta and Z'}, ...
      paramValue.DOUBLE_VALUE(5.6197e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between eta and theta
    p = param({'EOM_TM2_STIFF_ETATHETA','stiffness of TM2 between eta and theta'}, ...
      paramValue.DOUBLE_VALUE(6e-08));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 along eta
    p = param({'EOM_TM2_STIFF_ETAETA','stiffness of TM2 along eta'}, ...
      paramValue.DOUBLE_VALUE(5.538e-06));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between eta and phi
    p = param({'EOM_TM2_STIFF_ETAPHI','stiffness of TM2 between eta and phi'}, ...
      paramValue.DOUBLE_VALUE(6e-08));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between phi and X
    p = param({'EOM_TM2_STIFF_PHIX','stiffness of TM2 between phi and X'}, ...
      paramValue.DOUBLE_VALUE(7.6157e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between phi and Y
    p = param({'EOM_TM2_STIFF_PHIY','stiffness of TM2 between phi and Y'}, ...
      paramValue.DOUBLE_VALUE(5.5577e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between phi and Z
    p = param({'EOM_TM2_STIFF_PHIZ','stiffness of TM2 between phi and Z'}, ...
      paramValue.DOUBLE_VALUE(2.6087e-06));
    p.setProperty('units', 's^(-2) m^(-1) rad');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between phi and theta
    p = param({'EOM_TM2_STIFF_PHITHETA','stiffness of TM2 between phi and theta'}, ...
      paramValue.DOUBLE_VALUE(6e-08));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 between phi and eta
    p = param({'EOM_TM2_STIFF_PHIETA','stiffness of TM2 between phi and eta'}, ...
      paramValue.DOUBLE_VALUE(6e-08));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % stiffness of TM2 along phi
    p = param({'EOM_TM2_STIFF_PHIPHI','stiffness of TM2 along phi'}, ...
      paramValue.DOUBLE_VALUE(4.136e-06));
    p.setProperty('units', 's^(-2)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % TM1 residual gas drag along X (defined in housing 1)
    p = param({'EOM_TM1_DRAG_XX','TM1 residual gas drag along X (defined in housing 1)'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 's^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H1');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % TM1 residual gas drag along Y (defined in housing 1)
    p = param({'EOM_TM1_DRAG_YY','TM1 residual gas drag along Y (defined in housing 1)'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 's^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H1');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % TM1 residual gas drag along Z (defined in housing 1)
    p = param({'EOM_TM1_DRAG_ZZ','TM1 residual gas drag along Z (defined in housing 1)'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 's^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H1');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % TM1 residual gas drag along theta (defined in housing 1)
    p = param({'EOM_TM1_DRAG_THETATHETA','TM1 residual gas drag along theta (defined in housing 1)'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 's^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H1');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % TM1 residual gas drag along eta (defined in housing 1)
    p = param({'EOM_TM1_DRAG_ETAETA','TM1 residual gas drag along eta (defined in housing 1)'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 's^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H1');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % TM1 residual gas drag along phi (defined in housing 1)
    p = param({'EOM_TM1_DRAG_PHIPHI','TM1 residual gas drag along phi (defined in housing 1)'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 's^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H1');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % TM2 residual gas drag along X (defined in housing 2)
    p = param({'EOM_TM2_DRAG_XX','TM2 residual gas drag along X (defined in housing 2)'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 's^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H2');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % TM2 residual gas drag along Y (defined in housing 2)
    p = param({'EOM_TM2_DRAG_YY','TM2 residual gas drag along Y (defined in housing 2)'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 's^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H2');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % TM2 residual gas drag along Z (defined in housing 2)
    p = param({'EOM_TM2_DRAG_ZZ','TM2 residual gas drag along Z (defined in housing 2)'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 's^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H2');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % TM2 residual gas drag along theta (defined in housing 2)
    p = param({'EOM_TM2_DRAG_THETATHETA','TM2 residual gas drag along theta (defined in housing 2)'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 's^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H2');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % TM2 residual gas drag along eta (defined in housing 2)
    p = param({'EOM_TM2_DRAG_ETAETA','TM2 residual gas drag along eta (defined in housing 2)'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 's^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H2');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % TM2 residual gas drag along phi (defined in housing 2)
    p = param({'EOM_TM2_DRAG_PHIPHI','TM2 residual gas drag along phi (defined in housing 2)'}, ...
      paramValue.DOUBLE_VALUE(0));
    p.setProperty('units', 's^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'H2');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
    % IS TM1 Cross talk between X and X
    p = param({'IS_TM1_XX','IS TM1 Cross talk between X and X'}, ...
      paramValue.DOUBLE_VALUE(1));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between X and Y
    p = param({'IS_TM1_XY','IS TM1 Cross talk between X and Y'}, ...
      paramValue.DOUBLE_VALUE(0.003));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between X and Z
    p = param({'IS_TM1_XZ','IS TM1 Cross talk between X and Z'}, ...
      paramValue.DOUBLE_VALUE(0.003));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between X and theta
    p = param({'IS_TM1_XTHETA','IS TM1 Cross talk between X and theta'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between X and eta
    p = param({'IS_TM1_XETA','IS TM1 Cross talk between X and eta'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between X and phi
    p = param({'IS_TM1_XPHI','IS TM1 Cross talk between X and phi'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between Y and X
    p = param({'IS_TM1_YX','IS TM1 Cross talk between Y and X'}, ...
      paramValue.DOUBLE_VALUE(0.003));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between Y and Y
    p = param({'IS_TM1_YY','IS TM1 Cross talk between Y and Y'}, ...
      paramValue.DOUBLE_VALUE(1));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between Y and Y
    p = param({'IS_TM1_YZ','IS TM1 Cross talk between Y and Y'}, ...
      paramValue.DOUBLE_VALUE(0.003));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between Y and theta
    p = param({'IS_TM1_YTHETA','IS TM1 Cross talk between Y and theta'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between Y and eta
    p = param({'IS_TM1_YETA','IS TM1 Cross talk between Y and eta'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between Y and phi
    p = param({'IS_TM1_YPHI','IS TM1 Cross talk between Y and phi'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between Z and X
    p = param({'IS_TM1_ZX','IS TM1 Cross talk between Z and X'}, ...
      paramValue.DOUBLE_VALUE(0.003));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between Z and Y
    p = param({'IS_TM1_ZY','IS TM1 Cross talk between Z and Y'}, ...
      paramValue.DOUBLE_VALUE(0.003));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between Z and Z
    p = param({'IS_TM1_ZZ','IS TM1 Cross talk between Z and Z'}, ...
      paramValue.DOUBLE_VALUE(1));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between Z and theta
    p = param({'IS_TM1_ZTHETA','IS TM1 Cross talk between Z and theta'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between Z and eta
    p = param({'IS_TM1_ZETA','IS TM1 Cross talk between Z and eta'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between Z and phi
    p = param({'IS_TM1_ZPHI','IS TM1 Cross talk between Z and phi'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between theta and X
    p = param({'IS_TM1_THETAX','IS TM1 Cross talk between theta and X'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between theta and Y
    p = param({'IS_TM1_THETAY','IS TM1 Cross talk between theta and Y'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between theta and Z
    p = param({'IS_TM1_THETAZ','IS TM1 Cross talk between theta and Z'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between theta and theta
    p = param({'IS_TM1_THETATHETA','IS TM1 Cross talk between theta and theta'}, ...
      paramValue.DOUBLE_VALUE(1));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between theta and eta
    p = param({'IS_TM1_THETAETA','IS TM1 Cross talk between theta and eta'}, ...
      paramValue.DOUBLE_VALUE(0.001));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between theta and phi
    p = param({'IS_TM1_THETAPHI','IS TM1 Cross talk between theta and phi'}, ...
      paramValue.DOUBLE_VALUE(0.001));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between eta and X
    p = param({'IS_TM1_ETAX','IS TM1 Cross talk between eta and X'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between eta and Y
    p = param({'IS_TM1_ETAY','IS TM1 Cross talk between eta and Y'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between eta and Z
    p = param({'IS_TM1_ETAZ','IS TM1 Cross talk between eta and Z'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between eta and theta
    p = param({'IS_TM1_ETATHETA','IS TM1 Cross talk between eta and theta'}, ...
      paramValue.DOUBLE_VALUE(0.001));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between eta and eta
    p = param({'IS_TM1_ETAETA','IS TM1 Cross talk between eta and eta'}, ...
      paramValue.DOUBLE_VALUE(1));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between phi and phi
    p = param({'IS_TM1_ETAPHI','IS TM1 Cross talk between phi and phi'}, ...
      paramValue.DOUBLE_VALUE(0.001));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between phi and X
    p = param({'IS_TM1_PHIX','IS TM1 Cross talk between phi and X'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between phi and Y
    p = param({'IS_TM1_PHIY','IS TM1 Cross talk between phi and Y'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between phi and Z
    p = param({'IS_TM1_PHIZ','IS TM1 Cross talk between phi and Z'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between phi and theta
    p = param({'IS_TM1_PHITHETA','IS TM1 Cross talk between phi and theta'}, ...
      paramValue.DOUBLE_VALUE(0.001));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between phi and eta
    p = param({'IS_TM1_PHIETA','IS TM1 Cross talk between phi and eta'}, ...
      paramValue.DOUBLE_VALUE(0.001));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM1 Cross talk between phi and phi
    p = param({'IS_TM1_PHIPHI','IS TM1 Cross talk between phi and phi'}, ...
      paramValue.DOUBLE_VALUE(1));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between X and X
    p = param({'IS_TM2_XX','IS TM2 Cross talk between X and X'}, ...
      paramValue.DOUBLE_VALUE(1));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between X and Y
    p = param({'IS_TM2_XY','IS TM2 Cross talk between X and Y'}, ...
      paramValue.DOUBLE_VALUE(0.003));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between X and Z
    p = param({'IS_TM2_XZ','IS TM2 Cross talk between X and Z'}, ...
      paramValue.DOUBLE_VALUE(0.003));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between X and theta
    p = param({'IS_TM2_XTHETA','IS TM2 Cross talk between X and theta'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between X and eta
    p = param({'IS_TM2_XETA','IS TM2 Cross talk between X and eta'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between X and phi
    p = param({'IS_TM2_XPHI','IS TM2 Cross talk between X and phi'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between Y and X
    p = param({'IS_TM2_YX','IS TM2 Cross talk between Y and X'}, ...
      paramValue.DOUBLE_VALUE(0.003));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between Y and Y
    p = param({'IS_TM2_YY','IS TM2 Cross talk between Y and Y'}, ...
      paramValue.DOUBLE_VALUE(1));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between Y and Z
    p = param({'IS_TM2_YZ','IS TM2 Cross talk between Y and Z'}, ...
      paramValue.DOUBLE_VALUE(0.003));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between Y and theta
    p = param({'IS_TM2_YTHETA','IS TM2 Cross talk between Y and theta'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between Y and eta
    p = param({'IS_TM2_YETA','IS TM2 Cross talk between Y and eta'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between Y and phi
    p = param({'IS_TM2_YPHI','IS TM2 Cross talk between Y and phi'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between Z and X
    p = param({'IS_TM2_ZX','IS TM2 Cross talk between Z and X'}, ...
      paramValue.DOUBLE_VALUE(0.003));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between Z and Y
    p = param({'IS_TM2_ZY','IS TM2 Cross talk between Z and Y'}, ...
      paramValue.DOUBLE_VALUE(0.003));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between Z and Z
    p = param({'IS_TM2_ZZ','IS TM2 Cross talk between Z and Z'}, ...
      paramValue.DOUBLE_VALUE(1));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between Z and theta
    p = param({'IS_TM2_ZTHETA','IS TM2 Cross talk between Z and theta'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between Z and eta
    p = param({'IS_TM2_ZETA','IS TM2 Cross talk between Z and eta'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between Z and phi
    p = param({'IS_TM2_ZPHI','IS TM2 Cross talk between Z and phi'}, ...
      paramValue.DOUBLE_VALUE(0.000598));
    p.setProperty('units', 'rad m ^(-1)');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between theta and X
    p = param({'IS_TM2_THETAX','IS TM2 Cross talk between theta and X'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between theta and Y
    p = param({'IS_TM2_THETAY','IS TM2 Cross talk between theta and Y'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between theta and Z
    p = param({'IS_TM2_THETAZ','IS TM2 Cross talk between theta and Z'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between theta and theta
    p = param({'IS_TM2_THETATHETA','IS TM2 Cross talk between theta and theta'}, ...
      paramValue.DOUBLE_VALUE(1));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between theta and eta
    p = param({'IS_TM2_THETAETA','IS TM2 Cross talk between theta and eta'}, ...
      paramValue.DOUBLE_VALUE(0.001));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between theta and phi
    p = param({'IS_TM2_THETAPHI','IS TM2 Cross talk between theta and phi'}, ...
      paramValue.DOUBLE_VALUE(0.001));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between eta and X
    p = param({'IS_TM2_ETAX','IS TM2 Cross talk between eta and X'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between eta and Y
    p = param({'IS_TM2_ETAY','IS TM2 Cross talk between eta and Y'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between eta and Z
    p = param({'IS_TM2_ETAZ','IS TM2 Cross talk between eta and Z'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between eta and theta
    p = param({'IS_TM2_ETATHETA','IS TM2 Cross talk between eta and theta'}, ...
      paramValue.DOUBLE_VALUE(0.001));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between eta and eta
    p = param({'IS_TM2_ETAETA','IS TM2 Cross talk between eta and eta'}, ...
      paramValue.DOUBLE_VALUE(1));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between ETA and phi
    p = param({'IS_TM2_ETAPHI','IS TM2 Cross talk between eta and phi'}, ...
      paramValue.DOUBLE_VALUE(0.001));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between phi and X
    p = param({'IS_TM2_PHIX','IS TM2 Cross talk between phi and X'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between phi and Y
    p = param({'IS_TM2_PHIY','IS TM2 Cross talk between phi and Y'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between phi and Z
    p = param({'IS_TM2_PHIZ','IS TM2 Cross talk between phi and Z'}, ...
      paramValue.DOUBLE_VALUE(0.086957));
    p.setProperty('units', 'rad^(-1) m');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between phi and theta
    p = param({'IS_TM2_PHITHETA','IS TM2 Cross talk between phi and theta'}, ...
      paramValue.DOUBLE_VALUE(0.001));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between phi and eta
    p = param({'IS_TM2_PHIETA','IS TM2 Cross talk between phi and eta'}, ...
      paramValue.DOUBLE_VALUE(0.001));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'S2-ASD-ICD-2011_Iss14 DFACS External ICD');
    pl.append(p);
    
    % IS TM2 Cross talk between phi and phi
    p = param({'IS_TM2_PHIPHI','IS TM2 Cross talk between phi and phi'}, ...
      paramValue.DOUBLE_VALUE(1));
    p.setProperty('units', 'unit');
    p.setProperty('min', -inf);
    p.setProperty('max', inf);
    p.setProperty('ref_frame', 'SS_MF');
    p.setProperty('subsystem', 'TM');
    p.setProperty('reference', 'TBD');
    pl.append(p);
    
  end
  plOut = pl;
  
end
function pl = IFO_properties()
  
  pl = plist();
  
  % IFO Cross talk between X1 and X1
  p = param({'IFO_X1X1','IFO Cross talk between X1 and X1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between X1 and eta1
  p = param({'IFO_X1ETA1','IFO Cross talk between X1 and eta1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m ^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between X1 and phi1
  p = param({'IFO_X1PHI1','IFO Cross talk between X1 and phi1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m ^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between X1 and X12
  p = param({'IFO_X1X12','IFO Cross talk between X1 and X12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between X1 and eta12
  p = param({'IFO_X1ETA12','IFO Cross talk between X1 and eta12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m ^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between eta1 and phi12
  p = param({'IFO_X1PHI12','IFO Cross talk between eta1 and phi12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between eta1 and X1
  p = param({'IFO_ETA1X1','IFO Cross talk between eta1 and X1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between eta1 and eta1
  p = param({'IFO_ETA1ETA1','IFO Cross talk between eta1 and eta1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between eta1 and phi1
  p = param({'IFO_ETA1PHI1','IFO Cross talk between eta1 and phi1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between eta1 and X12
  p = param({'IFO_ETA1X12','IFO Cross talk between eta1 and X12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between eta1 and eta12
  p = param({'IFO_ETA1ETA12','IFO Cross talk between eta1 and eta12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between eta1 and phi12
  p = param({'IFO_ETA1PHI12','IFO Cross talk between eta1 and phi12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between phi1 and X1
  p = param({'IFO_PHI1X1','IFO Cross talk between phi1 and X1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between phi1 and eta1
  p = param({'IFO_PHI1ETA1','IFO Cross talk between phi1 and eta1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between phi1 and phi1
  p = param({'IFO_PHI1PHI1','IFO Cross talk between phi1 and phi1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between phi1 and X12
  p = param({'IFO_PHI1X12','IFO Cross talk between phi1 and X12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between phi1 and eta12
  p = param({'IFO_PHI1ETA12','IFO Cross talk between phi1 and eta12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between phi1 and phi12
  p = param({'IFO_PHI1PHI12','IFO Cross talk between phi1 and phi12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between X12 and X1
  p = param({'IFO_X12X1','IFO Cross talk between X12 and X1'}, ...
    paramValue.DOUBLE_VALUE(0.0001));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between X12 and eta1
  p = param({'IFO_X12ETA1','IFO Cross talk between X12 and eta1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m ^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between X12 and phi1
  p = param({'IFO_X12PHI1','IFO Cross talk between X12 and phi1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m ^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between X12 and X12
  p = param({'IFO_X12X12','IFO Cross talk between X12 and X12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between X12 and eta12
  p = param({'IFO_X12ETA12','IFO Cross talk between X12 and eta12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m ^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between X12 and phi12
  p = param({'IFO_X12PHI12','IFO Cross talk between X12 and phi12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad m ^(-1)');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between eta12 and X1
  p = param({'IFO_ETA12X1','IFO Cross talk between eta12 and X1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between eta12 and eta1
  p = param({'IFO_ETA12ETA1','IFO Cross talk between eta12 and eta1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between eta12 and phi1
  p = param({'IFO_ETA12PHI1','IFO Cross talk between eta12 and phi1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between eta12 and X12
  p = param({'IFO_ETA12X12','IFO Cross talk between eta12 and X12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between eta12 and eta12
  p = param({'IFO_ETA12ETA12','IFO Cross talk between eta12 and eta12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between eta12 and phi12
  p = param({'IFO_ETA12PHI12','IFO Cross talk between eta12 and phi12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between phi1 and X1
  p = param({'IFO_PHI12X1','IFO Cross talk between phi1 and X1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between phi1 and eta1
  p = param({'IFO_PHI12ETA1','IFO Cross talk between phi1 and eta1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between phi1 and phi1
  p = param({'IFO_PHI12PHI1','IFO Cross talk between phi1 and phi1'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between phi1 and X12
  p = param({'IFO_PHI12X12','IFO Cross talk between phi1 and X12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'rad^(-1) m');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between phi1 and eta12
  p = param({'IFO_PHI12ETA12','IFO Cross talk between phi1 and eta12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
  % IFO Cross talk between phi1 and phi12
  p = param({'IFO_PHI12PHI12','IFO Cross talk between phi1 and phi12'}, ...
    paramValue.DOUBLE_VALUE(0));
  p.setProperty('units', 'unit');
  p.setProperty('min', -inf);
  p.setProperty('max', inf);
  p.setProperty('ref_frame', 'SS_MF');
  p.setProperty('subsystem', 'IFO');
  p.setProperty('reference', 'TBD');
  pl.append(p);
  
end

