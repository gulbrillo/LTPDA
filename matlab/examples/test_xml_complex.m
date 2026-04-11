% Test reading and writing complex data to XML file.
%
% M Hewitson 19-04-07
%
% $Id$
function test_xml_complex()
  
  % Make some response data
  poles = [pz(1,2) pz(40)];
  zeros = [pz(10,3) pz(100)];
  pzm = pzmodel(10, poles, zeros);
  a = resp(pzm);
  iplot(a)
  
  % Save to XML file
  save(pzm, 'pzm.xml')
  save(a,   'a.xml')
  
  % load files
  pzm_r = pzmodel('pzm.xml');
  a_r   = ao('a.xml');
  delete('pzm.xml')
  delete('a.xml')
  
  % compare objects
  isequal(pzm, pzm_r)
  isequal(a, a_r)
  
  close all
end
