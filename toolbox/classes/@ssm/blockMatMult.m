% multiplies block defined matrix stored inside cell array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: cell_mult multiplies block defined matrix stored inside cell
% array
%
% CALL: [cell3] = ssm.blockMatMult(cell1,cell2,isnotempty_1,isnotempty_2)
%
% INPUTS:
%       cell1 - cell array of matrices representing a matrix by blocs.
%               blocs may be empty
%       cell2 - cell array of matrices representing a matrix by blocs.
%               blocs may be empty
%
% OPTIONNAL INPUTS:
%       isnotempty_1 - logical array tells ~isequal(cell1{ii,jj},[])
%       isnotempty_2 - logical array tells ~isequal(cell2{ii,jj},[])
%
% OUTPUTS:
%       cell3 - cell array of matrices representing a matrix by blocs.
%               blocs may be empty
%
% NOTE:   function is private to the ssm class
%
% TO DO:  check ME in case of mixed symbolic and double
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function c = blockMatMult(varargin)
  a=varargin{1};
  b =varargin{2};
  n1 = size(a,1);
  n2 = size(a,2);
  n3 = size(b,2);
  if nargin == 4
    sizes1 = varargin{3};
    sizes3 = varargin{4};
    if numel(sizes1)~=n1
      error('Incompatible user input (3rd argument does not correctly indicate final line heights)');
    elseif numel(sizes3)~=n3
      error('Incompatible user output (4th argument does not correctly indicate final column widths)');
    end
  end
  c = cell(n1,n3);
  if isempty(a)||isempty(b)
    % if the content matrix is empty
    if n2==0 && n1>0 && n3>0
      if nargin == 4

        c = ssm.blockMatFillDiag(c,sizes1,sizes3);
      else
        error('cannot build proper matrices')
      end
    end
  else
    % if matrices are not empty
    isnotempty_a = not(cellfun(@isempty, a));
    isnotempty_b = not(cellfun(@isempty, b));
    % extra check for the extended diagonal
    for ii=1:max(n1, n2)
      isnotempty_a(min(ii,n1),min(ii,n2)) = true;
    end
    for ii=1:max(n2, n3)
      isnotempty_b(min(ii,n2), min(ii,n3)) = true;
    end
    isempty_c = true(n1,n3);
    for ii=1:n1
      for kk=1:n2
        if isnotempty_a(ii,kk)
          for jj=1:n3
            if isnotempty_b(kk,jj)
              if isempty_c(ii,jj)
                % note that the matrix multiplication preserves a non-empty block diagonal
                if  (isempty(a{ii,kk}) || isempty(b{kk,jj}))
                  % exception for the case where you have one or more empty matrix
                  c{ii,jj} = zeros(size(a{ii,kk},1), size(b{kk,jj},2));
                else
                  c{ii,jj} = a{ii,kk}*b{kk,jj};
                end
                isempty_c(ii,jj) = false;
              else
                if (isempty(a{ii,kk}) || isempty(b{kk,jj}))
                  % exception for the case where you have one or more empty matrix
                else
                  c{ii,jj} = c{ii,jj} + a{ii,kk}*b{kk,jj};
                end
              end
            end
          end
        end
      end
    end
  end
end
