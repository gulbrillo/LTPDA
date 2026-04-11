% Test saving AO to xml
%
%
% $Id$
%
function testing_xml()
  
  
  % Make test AOs
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  a2 = ao(pl);
  
  % Make LPSD of each
  
  % Window function
  w = specwin('Kaiser', 1000, 250);
  
  % use lpsd
  a3 = psd(a1);
  a4 = psd(a2);
  
  % multiply
  a5 = a3.*a4;
  iplot(a5)
  
  % Save to XML
  file_name = 'a5.xml';
  save(a5, file_name);
  
  % Load
  file_name = 'a5.xml';
  b = ao(file_name);
  iplot(b)
  
  % Rebuild from history
  a_out = rebuild(b);
  iplot(a_out)
  
  close all
end
