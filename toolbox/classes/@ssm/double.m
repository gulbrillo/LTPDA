% Convert a statespace model object to double arrays for given i/o
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: double converts a statespace model object to double arrays.
%
% CALL:        [A B C D Ts ...
%              inputvarnames ssvarnames outputvarnames ...
%              inputvarunits ssvarunits outputvarunits ] = double(ssm, pl);
%
% INPUTS :
%             ssm     - a ssm object
%             pl      - an options plist
%
% OPTIONS :
% plist with parameters 'inputs', 'states' and 'outputs' to indicate which
% inputs, states and outputs variables are taken in account. This requires
% proper variable naming. If a variable called appears more that once it
% will be used once only.
% The field may be :
%              - a cellstr containing the resp. input/state/output *variable* names
%              - a logical indexing the resp. input/state/output *variables*
%              names. Index is stored in a cell array, each cell
%              correponding to one input/state/output block.
%              - a double indexing the resp. input/state/output *variables*
%              names. Index is stored in a cell array, each cell
%              correponding to one input/state/output block.
%              - 'ALL', this string indicates all i/o variables will be
%              given
%
%
% OUTPUTS :    A                - the As matrices in one double array
%              B                - the Bs matrices in one double array
%              C                - the Cs matrices in one double array
%              D                - the Ds matrices in one double array
%              Ts               - the sampling time of the system. 0 is
%                                 continuous
%              inputvarnames    - the variable names corresponding to the
%                                 columns of B and D
%              ssvarnames       - the variable names corresponding to the
%                                 rows of A and B, cols. of A and C
%              outputvarnames   - the variable names corresponding to the
%                                 rows of C and D
%              inputvarunits    - the variable names corresponding to the
%                                 columns of B and D
%              ssvarunits       - the variable names corresponding to the
%                                 rows of A and B, cols. of A and C
%              outputunits      - the variable names corresponding to the
%                                 rows of C and D
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'double')">Parameters Description</a>
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = double(varargin)
  
  %% starting initial checks
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(utils.const.msg.OMNAME, ['running ', mfilename]);
  
  in_names = cell(size(varargin));
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  if numel(sys)~=1
    error('double takes exactly one ssm as input')
  elseif ~sys.isnumerical  % checking system is numeric
    error(['error in double : system named ' sys.name ' is not numeric'])
  end
  
  %% begin function body
  
  %making model simplifications, and deepcopy
  indexInputs  = makePortLogicalIndex( sys.inputs,  find(pl,'inputs') );
  indexStates  = makePortLogicalIndex( sys.states,  find(pl,'states') );
  indexOutputs = makePortLogicalIndex( sys.outputs, find(pl,'outputs') );
  
  %% pruning the object fields and assigning fields
  %                                cell_mat   lines wanted    cols wanted
  sys.amats    = ssm.blockMatPrune(sys.amats, indexStates,    indexStates);
  sys.bmats    = ssm.blockMatPrune(sys.bmats, indexStates,    indexInputs);
  sys.cmats    = ssm.blockMatPrune(sys.cmats, indexOutputs,   indexStates);
  sys.dmats    = ssm.blockMatPrune(sys.dmats, indexOutputs,   indexInputs);
  
  sys.inputs   = applyPortLogicalIndex(sys.inputs,  indexInputs );
  sys.states   = applyPortLogicalIndex(sys.states,  indexStates );
  sys.outputs  = applyPortLogicalIndex(sys.outputs, indexOutputs );
  
%   sys = doSimplify(sys0, pl);
  
  %  Convert to double arrays
  A = ssm.blockMatFusion(sys.amats, sys.sssizes,     sys.sssizes);
  B = ssm.blockMatFusion(sys.bmats, sys.sssizes,     sys.inputsizes);
  C = ssm.blockMatFusion(sys.cmats, sys.outputsizes, sys.sssizes);
  D = ssm.blockMatFusion(sys.dmats, sys.outputsizes, sys.inputsizes);
  Ts = sys.timestep;
  
  inputvarnames = cell(1,sum(sys.inputsizes));
  inputunit = unit.initObjectWithSize(1,sum(sys.inputsizes));
  k=1;
  for i=1:sys.Ninputs
    for j=1:sys.inputsizes(i)
      inputvarnames{k} = sys.inputs(i).ports(j).name;
      inputunit(k) = sys.inputs(i).ports(j).units;
      k = k+1;
    end
  end
  ssvarnames = cell(1,sum(sys.sssizes));
  ssunit = unit.initObjectWithSize(1,sum(sys.inputsizes));
  k=1;
  for i=1:sys.Nss
    for j=1:sys.sssizes(i)
      ssvarnames{k} = sys.states(i).ports(j).name;
      ssunit(k) = sys.states(i).ports(j).units;
      k = k+1;
    end
  end
  outputvarnames = cell(1,sum(sys.outputsizes));
  outputunit = unit.initObjectWithSize(1,sum(sys.inputsizes));
  k=1;
  for i=1:sys.Noutputs
    for j=1:sys.outputsizes(i)
      outputvarnames{k} = sys.outputs(i).ports(j).name;
      outputunit(k) = sys.outputs(i).ports(j).units;
      k = k+1;
    end
  end
  
  
  %% parsing output
  varargout = {...
    A B C D Ts ...
    inputvarnames ssvarnames outputvarnames ...
    inputunit ssunit outputunit ...
    };
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
end


%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  
  pl = plist();
  
  p = param({'inputs', 'A cell-array of input ports.'}, 'ALL');
  pl.append(p);
  
  p = param({'states', 'A cell-array of state ports.'}, 'ALL');
  pl.append(p);
  
  p = param({'outputs', 'A cell-array of output ports.'}, 'ALL');
  pl.append(p);
  
  
end
