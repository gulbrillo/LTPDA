% fusions a block defined matrix stored inside cell array into one matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: blockMatFusion fusions a block defined matrix stored inside cell
% array into one matrix
%
% CALL: [mat3] = ssm.blockMatFusion(cell1, rowsizes, colsizes)
%
% INPUTS:
%       cell1    - cell array of matrices representing a matrix by blocs.
%                  blocs may be empty
%       rowsizes - vector giving block height
%       colsizes - vector giving block width
%
% OUTPUTS:
%       mat3 - double or symbolic array
%
% NOTE:   function is private to the ssm class
%
% TO DO:  check ME in case of mixed symbolic and double
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function a_out = blockMatFusion(a, rowsizes, colsizes)
  % to deal with matrices whose size is not defined
  rowrank = cumsum([1 rowsizes]);
  colrank = cumsum([1 colsizes]);
  Nrow = length(rowsizes);
  Ncol = length(colsizes);
  isEmpty = cellfun(@isempty, a);

  a_out = zeros(rowrank(Nrow+1)-1, colrank(Ncol+1)-1);
  for ii=1:Nrow
    for jj=1:Ncol
      if ~isEmpty(ii,jj)
        rowmin = rowrank(ii);
        rowmax = rowrank(ii+1)-1;
        colmin = colrank(jj);
        colmax = colrank(jj+1)-1;
        try
          a_out(rowmin:rowmax, colmin:colmax) = a{ii,jj};
        catch ME
          a_out = sym(a_out);
          a_out(rowmin:rowmax, colmin:colmax) = sym(a{ii,jj});
        end
      end
    end
  end
end
