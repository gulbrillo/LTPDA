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
function a = blockMatAdd(varargin)
  a=varargin{1};
  b =varargin{2};
  Nrow = size(a,1);
  Ncol = size(a,2);
  if nargin ==4
    error('please remove the emptiness array as arguments, as they are not used anymore')
  else
    for ii=1:Nrow
      for jj=1:Ncol
        if  min(jj,Nrow)==min(ii,Ncol)
          % if we are on the extended diagonal, matrices should be there, add!
          try
            a{ii,jj} = a{ii,jj} + b{ii,jj};
          catch ME
            a{ii,jj} = sym(a{ii,jj}) + sym(b{ii,jj});
          end
        elseif ~isequal(a{ii,jj}, []) && ~isequal(b{ii,jj}, [])
          % if both matrices are non-empty
            try
              a{ii,jj} = a{ii,jj} + b{ii,jj};
            catch ME
              a{ii,jj} = sym(a{ii,jj}) + sym(b{ii,jj});
            end
        elseif ~isequal(b{ii,jj}, [])
            % if only the b is not empty
            a{ii,jj} = b{ii,jj};
        end
      end
    end
  end
end
