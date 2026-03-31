% This builds an html version of the helptoc.XML file for use in on-line viewing.
%
% M Hewitson 24-07-07
%
% $Id$
%
function convertTOC()
  
  fprintf('\n  - Creating sitemap of the LTPDA documentation: ')
  
  if ispc
    error('### You can build the content documentation only on a linux or MAC OS');
  end
  
  helptocPath = createContentFile.getAbsPathToHelp();
  
  outfile = fullfile(helptocPath, 'helptoc.html');
  xmlfile = fullfile(helptocPath, 'helptoc.xml');
  
  % Read in XML
  xdoc = xmlread(xmlfile);
  
  ain = xdoc.getElementsByTagName('toc');
  a = ain.item(0);
  
  children = a.getChildNodes;
  
  %%% Write header
  headerFile = fullfile('+createContentFile', 'header.html');
  catFiles(headerFile, '>', outfile);
  
  %%% Write content
  try
    fid = fopen(outfile, 'a+');
    createContentFile.read_item(fid, a);
    fclose(fid);
  catch ex
    fprintf(2, '%s\n', ex.getReport());
    fclose(fid);
  end
  
  %%% Write tail
  tailFile = fullfile('+createContentFile', 'tail.html');
  catFiles(tailFile, '>>', outfile);
  
  fprintf('finished.\n')
  
end

function catFiles(f1, op, f2)
  
  cmd = sprintf('cat %s %s %s', f1, op, f2);
  [status,result] = system(cmd);
  
  if status ~= 0
    error('### Can not build the html content file.\n%s', result);
  end
  
end




