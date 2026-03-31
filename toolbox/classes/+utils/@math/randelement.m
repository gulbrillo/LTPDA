% RANDELEMENT(VECTOR,J) returns J random samples chosen in the VECTOR array.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RANDELEMENT(VECTOR,N) returns N random samples chosen in the
%                                    VECTOR array. If VECTOR is a scalar,
%                                    than it answers with N samples from
%                                    1:1:VECTOR.
%
% CALL:       out = randelement(arr, j)
%
% INPUTS:     arr - numerical vector array or cell vector array; can be
%                   single line or single column.
%             j   - number of samples to extract
%
% OUTPUTS:    out - numerical vector array or cell vector array, shaped as
%                   the input 'arr', containing j elements chosen among 
%                   those included in 'arr'.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = randelement(arr, j)
  
   if nargin < 2
      error('randelement:tooFewInputs','The randelement function requires two input arguments.');
   elseif ~isa(arr,'double') && ~isa(arr,'cell')
      error('randelement:wrongInput','The input to the randelement function must be a numerical or cell array.')
   elseif ~isvector(arr)
      error('randelement:wrongShape','The input to the randelement function must be a vector.')
   end
   
   N = length(arr);
   if N==1
       if iscell(arr), arr = num2cell([1:1:arr{1}]);
       else arr = [1:1:arr];
       end
       N = length(arr);
   end
   out = arr(randi(N,1,j));
  
   if size(arr,1)==1 % reshape as a row vector
      out = reshape(out,1,[]);
   else              % reshape as a column vector
      out = reshape(out,[],1);
   end
  
end
% END

