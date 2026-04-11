% adds corresponding matrices of same sizes or empty inside cell array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: blockMatAdd adds corresponding matrices of same sizes or empty inside
% cell array
%
% CALL: [cell3] = ssm.blockMatAdd(cell1,cell2)
%
% INPUTS:
%       cell1 - cell array of matrices representing a matrix by blocs.
%               blocs may be empty
%       cell2 - cell array of matrices representing a matrix by blocs.
%               blocs may be empty
%
% OUTPUTS:
%       cell3 - cell array of matrices representing a matrix by blocs.
%               blocs may be empty
%
% NOTE:   function is private to the ssm class
%
% TO DO:  check ME in case of mixed symbolic and double
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = blockMatIndex(amats, blockIndex1, portIndex1, blockIndex2, portIndex2 )
  %% filling binary array to check is location is empty
  isEmpty = cellfun(@isempty, amats);
 
  Nrow = size(amats,1);
  Ncol = size(amats,2);

  n1 = numel(blockIndex1);
  n2 = numel(blockIndex2);
  a = zeros(n1, n2);

  %% rebuilding input indexing vector
  [groupedBlockIndex1, groupedPortIndex1, groupSize1, nGroups1, globalPortIndex1] = ssmblock.groupIndexes(blockIndex1, portIndex1);
  [groupedBlockIndex2, groupedPortIndex2, groupSize2, nGroups2, globalPortIndex2] = ssmblock.groupIndexes(blockIndex2, portIndex2);
  %% Copying content
  for ii=1:nGroups1
    bi = groupedBlockIndex1(ii);
    pi = groupedPortIndex1{ii};
    for jj=1:nGroups2
      bj = groupedBlockIndex2(jj);
      if ~isEmpty(bi, bj) || min(bi,Nrow)==min(bj,Ncol)
        % if we have a non-empty cell or we are on the extended diagonal
        val = amats{bi, bj}(pi,groupedPortIndex2{jj});
        if isa(val, 'sym') && ~isa(a, 'sym')
          a = sym(a);
        end
        a(globalPortIndex1{ii},globalPortIndex2{jj}) = val;

      end
    end
  end
  
end



