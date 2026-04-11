% blockMatPRUNE selects lines and columns of a block defined matrices stored in a cell array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: cell_select selects lines and columns of a block defined
%              matrices stored in a cell array
%
% CALL: [cell2] = ssm.cell_array_prune(cell1,rowindex,colindex)
%
% INPUTS:
%       cell1    - block defined matrix in cell array
%       rowsizes - vector giving block height
%       colsizes - vector giving block width
%
% OUTPUTS:
%       cell2 - cell array of matrices representing a matrix by blocs.
%               blocs may be empty
%
% NOTE : function is private to the ssm class
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout  = blockMatPrune(varargin)
  
  cell_in = varargin{1};
  rowindex = varargin{2};
  colindex = varargin{3};
  Nrows = numel(rowindex);
  Ncols = numel(colindex);
  
  %% selecting content
  cell_out = cell(Nrows, Ncols);
  for ii=1:Nrows
    for jj=1:Ncols
      if ~isequal(cell_in{ii,jj}, []) ||  min(ii, Ncols)==min(jj, Nrows)
        % if we have a non-empty cell or we are on the extended diagonal
        % however, if we have an empty symbol then just set an empty array
        % otherwise we get problems later.
        val = cell_in{ii,jj}(rowindex{ii},colindex{jj});
        if isa(val, 'sym') && isempty(val)
          cell_out{ii,jj} = [];
        else
          cell_out{ii,jj} = val;
        end
      end
    end
  end
  
  varargout = {cell_out};
end
