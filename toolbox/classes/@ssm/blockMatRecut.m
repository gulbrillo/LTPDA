% cuts a matrix into blocks stored inside cell array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: blockMatRecut  cuts a matrix into blocks stored inside cell
% array. Blocks with zeros are nullified, except in the diagonal (to
% preserve information on matrix size)
%
% CALL: [cell3] = ssm.blockMatRecut(mat1,rowsizes,colsizes)
%
% INPUTS:
%       mat1     - numeric array to be cut in pieces
%       rowsizes - vector giving block height
%       colsizes - vector giving block width
%
% OUTPUTS:
%       cell3 - cell array of matrices representing a matrix by blocs.
%               blocs may be empty
%
% NOTE:   function is private to the ssm class
%
% TO DO:  check ME in case of mixed symbolic and double
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function a_out = blockMatRecut(a, rowsizes, colsizes)
  % to deal with matrices whose size is not defined
  rowrank = cumsum([1 rowsizes]);
  colrank = cumsum([1 colsizes]);
  Nrow = length(rowsizes);
  Ncol = length(colsizes);
  a_out = cell(Nrow, Ncol);
  
  for i=1:Nrow
    for j=1:Ncol
      % getting position
      rowmin = rowrank(i);
      rowmax = rowrank(i+1)-1;
      colmin = colrank(j);
      colmax = colrank(j+1)-1;
      % selecting data
      content = a(rowmin:rowmax, colmin:colmax);
      
      % filling block data
      if min(i, Ncol)==min(j, Nrow)
        % if we are on the extended diagonal
        
        if isa(content, 'sym')
          % try convert the sym to a double
          try
            a_out{i,j} = double(content);
          catch
            a_out{i,j} = content;
          end
        else
          % cut a piece and keep the class appartenance (ex for logical)
          a_out{i,j} = content;
        end
        
      else
        
        % if we are not on the extended diagonal
        if isempty(content)
           % delete it if it is empty
           a_out{i,j} = [];
        elseif isa(a, 'sym')
          try
            % try convert the sym to a double
            content = double(content);
            if norm(content)==0
              % delete it if it is a double filled with zeros
              a_out{i,j} = [];
            else
              a_out{i,j} = content;
            end
          catch
            a_out{i,j} = content;
          end
        elseif isa(content, 'logical')
          % keep the logical as it is
          a_out{i,j} = content;
        elseif norm(content)==0
          % delete it if it is a double filled with zeros
          a_out{i,j}=[];
        else
          % copy it is a non-zero double
          a_out{i,j} = content;
        end
        
      end
      
      clear content
    end
  end
end
