% NUM2CELL Convert numeric array into cell array.
%
%
function c = num2cell(a, dims)
  
  narginchk(1, 2);
  if nargin == 1
    if numel(a) == 1
      % Special case if a is a single mfh-object
      % This is necessary because we have overloaded subsref
      % and indexing to a single mgh-object doesn't work.
      c = {a};
    else
      c = cell(size(a));
      for ii = 1:numel(a)
        c{ii} = a(ii);
      end
    end
  else
    error('### Code this local mfh/num2cell up for two inputs.')
  end
  
end



