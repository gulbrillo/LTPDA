% assembles embedded subsytems, with exogenous inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: assemble assembles embedded subsytems, closes loops
%             (endogenous inputs disappear) leaving outputs and exogenous
%             inputs. SSM content is copied.
%
% CALL:          sys = assemble(sys_array)
%
% INPUTS: sys_array - array or list of systems to assemble
%
% OUTPUTS: sys - assembled system
%
%  <a href="matlab:utils.helper.displayMethodInfo('ssm', 'assemble')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function   varargout = assemble( varargin )
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  % use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;
  
  % send starting message
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % collecting input
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all SSMs and plists
  [sys, ssm_invars] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  
  Nsys = numel(sys);
  
  % We want to force a copy - this is not a modify method
  if nargout ~= 1
    error('### assemble cannot be used as a modifier. Please give exactly one output variable.');
  end
  
  % Decide on a deep copy or a modify, depending on the output
  sys_array = copy(sys, true);
  
  % begin function body
  sys_out = ssm;
  
  % checking there is not problem with the timesteps
  
  for i=2:Nsys
    if ~(sys_array(i-1).timestep == sys_array(i).timestep)
      error(['At least two ssm have incompatible timestep fields : ' ...
        num2str(sys_array(i-1).timestep) ' for ''' sys_array(i-1).name ''' and '...
        num2str(sys_array(i).timestep) ' for ''' sys_array(i).name '''' ]);
    end
  end
  
  % merging ss data : ss* output* *input
  names   = cell(1,0);
  inputs  = ssmblock.initObjectWithSize(1,0);
  outputs = ssmblock.initObjectWithSize(1,0);
  states  = ssmblock.initObjectWithSize(1,0);
  params  = plist;
  numparams  = plist;
  
  sssizes         = zeros(1,0);
  ssposition      = zeros(1,0);
  outputsizes     = zeros(1,0);
  outputposition  = zeros(1,0);
  inputsizes      = zeros(1,0);
  inputposition   = zeros(1,0);
  
  for i=1:Nsys
    params.combine(sys_array(i).params);
    numparams.combine(sys_array(i).numparams); 
    inputs = inputs.combine(sys_array(i).inputs, false) ;
    outputs = [outputs, sys_array(i).outputs] ;
    states = [states, sys_array(i).states] ;
    
    names          = [names          sys_array(i).name           ];
    sssizes        = [sssizes        sys_array(i).sssizes        ];
    ssposition     = [ssposition     i*ones(1,sys_array(i).Nss)  ];
    outputsizes    = [outputsizes    sys_array(i).outputsizes    ];
    outputposition = [outputposition i*ones(1,sys_array(i).Noutputs) ];
    inputsizes     = [inputsizes     sys_array(i).inputsizes     ];
    inputposition  = [inputposition  i*ones(1,sys_array(i).Ninputs)  ];
  end
  
  % data already good to store
  sys_out.params     = params;
  sys_out.numparams  = numparams;
  sys_out.outputs    = outputs;
  sys_out.states     = states;
  
  % non redundancy checks :  not necessary anymore on the I/O fields
  % to be added on subfields ??
  
  % building A, and C matrices
  amats = {};
  cmats = {};
  for i=1:Nsys
    Namats = size(amats,2);
    amats = ...
      [amats                             cell(Namats, sys_array(i).Nss)    ; ...
      cell(sys_array(i).Nss, Namats)     sys_array(i).amats ] ;
    cmats = ...
      [cmats                             cell(size(cmats,1), sys_array(i).Nss)    ; ...
      cell(sys_array(i).Noutputs, size(cmats,2))            sys_array(i).cmats ] ;
  end
  
  % construction of B_xx and D_xx matrices
  inputs_ext = ssmblock.initObjectWithSize(1,0);
  
  B_in  = cell( numel(sssizes),     numel(outputsizes) );
  D_in  = cell( numel(outputsizes), numel(outputsizes) );
  B_ext = cell( numel(sssizes),     0 );
  D_ext = cell( numel(outputsizes), 0 );
  inputsizes = [];
  Ninputs = 0;
  for i_sys=1:Nsys
    for i_input = 1:numel(sys(i_sys).inputs)
      % current input of a subsystem
      input_name = sys_array(i_sys).inputs(i_input).name;
      % does the input match a local output ?
      [pos_output, sum_output] = findBlockWithNames(outputs, input_name, false);
      % check it is not already in the external input list
      [pos_input, sum_input] = findBlockWithNames(inputs_ext, input_name, false);

      if sum_output>0
        % if it is an internal input
        % put at the correct place in the B_in and D_in matrices
        B_in(ssposition==i_sys, pos_output) = sys_array(i_sys).bmats(:,i_input);
        D_in(outputposition==i_sys, pos_output) = sys_array(i_sys).dmats(:,i_input);
        % checking sizes match
        for i_out = pos_output
          Nin = sys_array(i_sys).inputs(i_input).Nports;
          if ~( Nin == outputs(i_out).Nports)
            error(['I/O sizes not matching between input "' sys_array(i_sys).inputs(i_input).name , ...
              '" of system "'  sys_array(i_sys).name ' of size ' num2str(Nin) ...
              '" and the output of size ' num2str(outputs(i_out).Nports) ...
              ' of the system "' sys_array(outputposition(pos_output)).name '"'] )
          end
        end
      else
        % if it is external
        % if it is not there, add to the input plist
        if sum_input == 0
          % extend the size of the input fields
          inputs_ext = [inputs_ext sys_array(i_sys).inputs(i_input)];
          inputsizes = [inputsizes sys_array(i_sys).inputsizes(i_input)];
          B_ext = [B_ext cell(size(B_ext,1),1)];
          D_ext = [D_ext cell(size(D_ext,1),1)];
          Ninputs = Ninputs +1;
          
          pos_input = numel(inputs_ext);
        end
        % put at the correct place in the B_ext and D_ext matrices
        B_ext(ssposition==i_sys, pos_input) = sys_array(i_sys).bmats(:,i_input);
        D_ext(outputposition==i_sys, pos_input) = sys_array(i_sys).dmats(:,i_input);
      end
    end
  end
  sys_out.inputs = inputs_ext;
  
  B_ext = ssm.blockMatFillDiag(B_ext, sssizes, inputsizes);
  D_ext = ssm.blockMatFillDiag(D_ext, outputsizes, inputsizes);
  B_in  = ssm.blockMatFillDiag(B_in, sssizes, outputsizes);
  D_in  = ssm.blockMatFillDiag(D_in, outputsizes, outputsizes);
  cmats = ssm.blockMatFillDiag(cmats, outputsizes, sssizes);
  % flattening and getting constant feedthrough
  D_in_f = ssm.blockMatFusion(D_in, outputsizes,outputsizes);
  G = (eye(size(D_in_f)) - D_in_f);
  if isnumeric(G)
    id_D_inv = inv(G);
  else
    id_D_inv = evalin(symengine, ['inverse(' char(G) ')']);
  end
  id_D_inv = ssm.blockMatRecut(id_D_inv, outputsizes, outputsizes);
  
  sys_out.amats = ssm.blockMatAdd(amats, ssm.blockMatMult(B_in, ssm.blockMatMult(id_D_inv, cmats, outputsizes, sssizes) , sssizes , sssizes ));
  sys_out.bmats = ssm.blockMatAdd(B_ext, ssm.blockMatMult(B_in, ssm.blockMatMult(id_D_inv, D_ext, outputsizes, inputsizes) , sssizes , inputsizes ));
  sys_out.cmats = ssm.blockMatMult(id_D_inv, cmats, outputsizes , sssizes );
  sys_out.dmats = ssm.blockMatMult(id_D_inv, D_ext, outputsizes , inputsizes );
  
  % building new name and strings
  name = 'assemble( ';
  for i = 1:Nsys
    if i==1
      name = [name, sys_array(i).name ];
    elseif i<=Nsys
      name = [name,' + ', sys_array(i).name];
    end
  end
  name = [name ' )'];
  sys_out.name = name;
  
  % getting timestep and checking consitency
  for i=1:Nsys
    if i == 1
      sys_out.timestep = sys_array(i).timestep;
    elseif ~ sys_out.timestep == sys_array(i).timestep
      error(['error because systems 1 and ',num2str(i),...
        ' named ',sys_array(i).name,' and ',sys_array(i).name,...
        ' have different timesteps :',...
        num2str(sys_array(i).timestep),' and ',num2str(sys_array(i).timestep) ]);
    end
  end
  
  % setting history and validating
  if ~callerIsMethod
    sys_out.addHistory(ssm.getInfo(mfilename), plist , ssm_invars(:), [sys_array(:).hist] );
    validate(sys_out);
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, sys_out);
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
  ii.setModifier(false);
  ii.setArgsmin(2);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  pl = plist();
end

