% Testing features of 'recreate from history'.
%
% M Hewitson 16-03-07
%
% $Id$
%
function test_recreate_1()
  
  % Create constant AO
  
  a1 = ao(2:20);
  d = a1.data;
  disp(['vals = ' num2str(d.y)])
  iplot(a1)
  
  % Create from plist
  a2 = ao(plist('fcn', 'complex(randn(100,1), randn(100,1))'));
  d = a2.data;
  d.y;
  iplot(a2)
  
  
  % Reproduce from history
  a_out = rebuild(a1);
  iplot(a_out)
  a_out = rebuild(a2);
  iplot(a_out)
  
  close all
end

% END