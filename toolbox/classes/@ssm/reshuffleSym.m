% RESHUFFLE rearragnes a ssm object using the given inputs and outputs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: rearragnes a ssm object using the given inputs and outputs.
%
% CALL:    sys = reshuffle(sys, inputs1, inputs2, inputs3,  states,
% outputs, outputStates)
%
% INPUTS:
%         'sys'           - ssm object
%         'inputs1'       - these will constitute the input block 1 of the output
%                         ssm (order is user defined)
%         'inputs2'       - these will constitute the input block 1 of the output
%                         ssm (order is user defined)
%         'inputs3'       - these will constitute the input block 1 of the output
%                         ssm (order is user defined)
%         'states'        - states to keep (order is user defined)
%         'outputs'       - outputs to keep, first output block (order is user
%                         defined) 
%         'outputStates'  - states to return as an output, second output block 
%                         (order is user defined) 
%
%  The inputs/states/outputs can only be indexed using a cellstr containing
%  block names or port names.
%
% OUTPUTS:
%
%        'sys' - a ssm object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sys = reshuffleSym(sys, inputs1, inputs2, inputs3,  states, outputs, outputStates)
  error('Function reshuffle sym')
  sys = copy(sys,true);
  
  [iBlockInputs1   iPortInputs1]     = findPortWithMixedNames( sys.inputs, inputs1 );
  [iBlockInputs2   iPortInputs2]     = findPortWithMixedNames( sys.inputs, inputs2 );
  [iBlockInputs3   iPortInputs3]     = findPortWithMixedNames( sys.inputs, inputs3 );
  [iBlockStatesOut iPortStatesOut]   = findPortWithMixedNames( sys.states, outputStates );
  [iBlockStates    iPortStates]      = findPortWithMixedNames( sys.states, states );
  [iBlockOutputsOut iPortOutputsOut] = findPortWithMixedNames( sys.outputs, outputs );
  
  inputs1    = mergeBlocksWithPositionIndex(sys.inputs, iBlockInputs1, iPortInputs1, 'inputs1');
  inputs2    = mergeBlocksWithPositionIndex(sys.inputs, iBlockInputs2, iPortInputs2, 'inputs2');
  inputs3    = mergeBlocksWithPositionIndex(sys.inputs, iBlockInputs3, iPortInputs3, 'inputs3');
  States     = mergeBlocksWithPositionIndex(sys.states, iBlockStates, iPortStates, 'states');
  StatesOut  = mergeBlocksWithPositionIndex(sys.states, iBlockStatesOut, iPortStatesOut, 'statesOut');
  OutputsOut = mergeBlocksWithPositionIndex(sys.outputs, iBlockOutputsOut, iPortOutputsOut, 'outputsOut');
  
  %                      cell_mat  lines wanted                        cols wanted
  A = ssm.blockMatIndexSym(sys.amats, iBlockStates   ,  iPortStates   ,   iBlockStates   , iPortStates   );
  C = ssm.blockMatIndexSym(sys.cmats, iBlockOutputsOut, iPortOutputsOut,  iBlockStates   , iPortStates   );
  B = ssm.blockMatIndexSym(sys.bmats, iBlockStates   ,  iPortStates   ,   iBlockInputs1,   iPortInputs1);
  D = ssm.blockMatIndexSym(sys.dmats, iBlockOutputsOut, iPortOutputsOut,  iBlockInputs1,   iPortInputs1);
  E = ssm.blockMatIndexSym(sys.bmats, iBlockStates   ,  iPortStates   ,   iBlockInputs2,   iPortInputs2);
  F = ssm.blockMatIndexSym(sys.dmats, iBlockOutputsOut, iPortOutputsOut,  iBlockInputs2,   iPortInputs2);
  G = ssm.blockMatIndexSym(sys.bmats, iBlockStates   ,  iPortStates   ,   iBlockInputs3,   iPortInputs3);
  H = ssm.blockMatIndexSym(sys.dmats, iBlockOutputsOut, iPortOutputsOut,  iBlockInputs3,   iPortInputs3);
  
  Y       = eye(sum(sys.statesizes));
  Y       = ssm.blockMatRecut(Y, sys.statesizes, sys.statesizes);
  Cstates = ssm.blockMatIndex( Y, iBlockStatesOut, iPortStatesOut,  iBlockStates   , iPortStates    );
  
  sys.amats = {A};
  sys.bmats = {B E G };
  sys.cmats = {Cstates; C};
  sys.dmats = {[] zeros(size(Cstates,1),size(F,2)) zeros(size(Cstates,1), size(H,2)) ;...
    D F H };
  
  sys.inputs = [inputs1 inputs2 inputs3];
  sys.states = States   ;
  sys.outputs = [StatesOut OutputsOut];
  
  sys.validate;
end
