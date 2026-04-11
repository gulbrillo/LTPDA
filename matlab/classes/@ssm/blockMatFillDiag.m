% adds corresponding matrices of same sizes or empty inside cell array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: blockMatFillDiag ensures the extended diagonal terms contain
%              the matrix size information
%
% CALL: a = blockMatFillDiag(a, isizes, jsizes)
% INPUTS:
%       a      - cell array of matrices representing a matrix by blocs.
%                blocs may be empty
%       isizes - heigth of the elements in the lines
%       jsizes - width of the elements in the rows
%
%
% OUTPUTS:
%       cell3 - cell array of matrices representing a matrix by blocs.
%               blocs may be empty
%
% NOTE : function is private to the ssm class
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function a = blockMatFillDiag(a, isizes, jsizes)
  if ~isempty(a) % checking the cell array is not of empty size
    ni = numel(isizes);
    nj = numel(jsizes);
    for p=1:(max(ni, nj))
      ii = min(p, ni);
      jj = min(p, nj);
      if isempty(a{ii,jj})
        a{ii,jj} = zeros(isizes(ii), jsizes(jj));
      end
    end
  end
end
