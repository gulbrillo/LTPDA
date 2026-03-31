% STEADYSTATE returns a possible value for the steady state of an ssm.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STEADYSTATE returns a possible value for the steady state
%              of the state space of an ssm with given inputs.
%
% CALL: [pl_out] = steadyState(sys, pl)
%
% INPUTS:
%         - sys, an ssm object
%
% OUTPUTS:
%         _ pl_out contains 'state', the random state position
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'steadyState')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TO DO: Check input aos for the timestep, tsdata, and ssm.timestep
% options to be defined (NL case)
% add check if one input mach no ssm input variable
% allow use of other LTPDA functions to generate white noise


function varargout = steadyState(varargin)
  
  %% starting initial checks
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all SSMs and plists
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  %% begin function body
  
  if numel(sys)~=1
    error('simulate needs exactly one ssm as an input')
  end
  if ~sys.isnumerical
    error(['error because system ',sys.name,' is not numerical']);
  end
  timestep  = sys.timestep;
  if timestep==0
    error('timestep should not be 0 in steadyState!!')
  end
  if pl.isparam('noise variable names')
    error('The noise option used must be split between "covariance" and "cpsd". "noise variable names" does not exist anymore!')
  end
  sssizes = sys.sssizes;
  %% collecting simulation i/o data
  
  constants_in = find(pl, 'constants');
  cov_in = find(pl, 'covariance');
  cpsd_in = find(pl, 'CPSD');
  noise_in = blkdiag(cov_in, cpsd_in/(timestep*2));
  [U1,S1,V1] = svd(noise_in.');
  if (sum(S1<0)>0)
    error('Covariance matrix is not positive definite')
  end
  noise_mat = U1*sqrt(S1);
  
  %% modifying system's ordering
  if find(pl, 'reorganize')
    sys = reorganize(sys, pl, plist('set', 'for simulate'));
  end
  
  %% getting system's i/o sizes
  inputSizes = sys.inputsizes;
  
  Nnoise = inputSizes(2);
  Nconstants = inputSizes(3);
  
  if numel(diag(noise_in))~=Nnoise
    error(['There are ' num2str(numel(diag(noise_in))) ' input noise variances and ' num2str(Nnoise) ' corresponding inputs indexed.' ])
  elseif numel(constants_in)~=Nconstants
    error(['There are ' num2str(numel(constants_in)) ' input constants and ' num2str(Nconstants) ' corresponding inputs indexed.' ])
  end
  
  A = sys.amats{1,1};
  Bnoise   = sys.bmats{1,2} * noise_mat;
  Bcst     = sys.bmats{1,3} * reshape(constants_in, Nconstants, 1);
  
  %% counting powers of 2 to use for initilization
  nSteps = 500;
  tSteady =  find(pl, 'tSteady');
  nPow2 = nextpow2(tSteady/(nSteps*timestep));
  
  %% simulation loop
  A_pow2=cell(1,nPow2);
  G_pow2=cell(1,nPow2);
  
  A_pow2{1} = A;
  G_pow2{1} = Bcst;
  
  %% method 1 :  iterate equations with growing time-step for a very long time
  E_pow2=cell(1,nPow2);
  E_pow2{1} = Bnoise;
  for i_pow2 = 2:nPow2
    G_pow2{i_pow2} = G_pow2{i_pow2-1} + A_pow2{i_pow2-1}*G_pow2{i_pow2-1};
    E_pow2{i_pow2} = E_pow2{i_pow2-1} + A_pow2{i_pow2-1}*E_pow2{i_pow2-1};
    A_pow2{i_pow2} = A_pow2{i_pow2-1}^2;
  end
  lastX = zeros(size(A,1),1);
  for i_pow2 = fliplr(1:nPow2)
    A = A_pow2{i_pow2};
    G = G_pow2{i_pow2};
    E = E_pow2{i_pow2};
    noise_array = randn(size(E,2), nSteps);
    for i_steps = 1:nSteps
      lastX  = A*lastX +  G + E*noise_array(:,i_steps) ;
    end
  end
  
  %% method 2 : compute the limit state-mean and covariance as i_pow2 tends to infinity
  %   P_pow2=cell(1,nPow2);
  %   P_pow2{1} = Bnoise*Bnoise.';
  %   for i_pow2 = 2:nPow2
  %     G_pow2{i_pow2} = G_pow2{i_pow2-1} + A_pow2{i_pow2-1}*G_pow2{i_pow2-1}; % taking step response to 2 longer time;
  %     P_pow2{i_pow2} = P_pow2{i_pow2-1} + A_pow2{i_pow2-1}*P_pow2{i_pow2-1}*(A_pow2{i_pow2-1}.');% taking state covariance to 2 longer time;
  %     A_pow2{i_pow2} = A_pow2{i_pow2-1}^2;
  %   end
  %   [U1,S1,V1] = svd(P_pow2{nPow2});
  %   lastX = U1*sqrt(S1)*randn(size(A,1),1) + G_pow2{nPow2};
  
  %% construct output analysis object
  plist_out = plist('state', ssm.blockMatRecut(lastX,sssizes,1) );
  varargout  = {plist_out};
end


%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  pl = plist();
  
  p = param({'cpsd variable names', 'A cell-array of strings specifying the desired input variable names.'}, {} );
  pl.append(p);
  
  p = param({'cpsd', 'The covariance of this noise between input ports for the <i>time-continuous</i> noise model.'}, []);
  pl.append(p);
  
  p = param({'covariance variable names', 'A cell-array of strings specifying the desired input variable names.'}, {} );
  pl.append(p);
  
  p = param({'covariance', 'The covariance of this noise between input ports for the <i>time-continuous</i> noise model.'}, []);
  pl.append(p);
  
  p = param({'constant variable names', 'A cell-array of strings of the desired input variable names.'}, {});
  pl.append(p);
  
  p = param({'constants', 'Array of DC values for the different corresponding inputs.'}, paramValue.DOUBLE_VALUE(zeros(0,1)));
  pl.append(p);
  
  p = param({'tSteady', 'The settling time used in the calculation, in the same unit as the ssm''s timestep'}, paramValue.DOUBLE_VALUE(10^6) );
  pl.append(p);
  
  p = param({'reorganize', 'When set to 0, this means the ssm does not need be modified to match the requested i/o. Faster but dangerous!'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
end

