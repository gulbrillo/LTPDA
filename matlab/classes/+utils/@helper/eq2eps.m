% EQ2EPS returns True if the two values are equal to within 2*eps of the
% second value.
% 
% USAGE: result = eq2eps(val1, val2);
% 
% val1 and val2 can be (equal length) vectors.
% 

function result = eq2eps(val1, val2)
  
  if size(val1) == size(val2)
    result = all(abs(val1 - val2) <= 2*eps(val2));
  else
    result = false;
  end
  
end
