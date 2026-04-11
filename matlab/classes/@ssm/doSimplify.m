% DOSIMPLIFY enables to do model simplification. It is a private function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% DESCRIPTION: DOSIMPLIFY allows to eliminate input/state/output variables.
%
% CALL:        [ssm] = DOSIMPLIFY(ssm, options); (private)
%
% INPUTS :
%             ssm     - a ssm object
%             options - an options plist
%
% OPTIONS :
% plist with parameters 'inputs', 'states' and 'outputs' to indicate which
% inputs, states and outputs variables are taken in account. This requires
% proper variable naming. If a variable called appears more that once it
% will be used once only.
% The field may be :
%              - a cellstr containing the resp. input/state/output *variable* names
%              - a logical indexing the resp. input/state/output
%                *variables*. Index is stored in a cell array, each cell
%                correponding to one input/state/output block.
%              - a double indexing the resp. input/state/output
%                *variables*. Index is stored in a cell array, each cell
%                correponding to one input/state/output block.
%              - 'ALL', this string indicates all i/o variables will be
%                given
%
% OUTPUTS:
%           The output array are of size Nsys*Noptions
% sys_out -  (array of) ssm objects without the specified information
%
%
function varargout = doSimplify(varargin)
  
  % Collect all SSMs and plists
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm');
  [pl, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  if numel(sys) ~= 1
    error('### Please input (only) one SSM model');
  end
  
  % Decide on a deep copy or a modify, depending on the output
  sys = copy(sys, nargout);
  
  %% retrieving indexes
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
  
  %% output
  varargout{1} = sys;
  
end


%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  pl = plist();
  
  p = param({'inputs', 'input index'}, 'ALL');
  pl.append(p);
  
  p = param({'states', 'states index'}, 'ALL');
  pl.append(p);
  
  p = param({'outputs', 'output index'}, 'ALL');
  pl.append(p);
  
end
