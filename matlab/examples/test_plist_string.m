% Tests string method of plist class.
%
% M Hewitson 29-03-07
%
% $Id$
%
function test_plist_string()
  
  pl = plist('a', 1, 'b', 2);
  
  eval(string(pl))
  
end