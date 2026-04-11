% Simple script to generate an HTML table of specwin types
% 
% M Hewitson
% 
% $Id$
% 

clear all;


fname = 'specwin_table.html';

fd = fopen(fname, 'w+');

wins = specwin('Types');
% {'Rectangular', 'Welch', 'Bartlett', 'Hanning', 'Hamming',... 
%      'Nuttall3', 'Nuttall4', 'Nuttall3a', 'Nuttall3b', 'Nuttall4a',...
%      'Nuttall4b', 'Nuttall4c', 'BH92', 'SFT3F', 'SFT3M', 'FTNI', 'SFT4F', 'SFT5F',...
%      'SFT4M', 'FTHP', 'HFT70', 'FTSRS', 'SFT5M', 'HFT90D', 'HFT95', 'HFT116D',...
%      'HFT144D', 'HFT169D', 'HFT196D', 'HFT223D', 'HFT248D'};
   
for wn = wins
  
  wn
  w = specwin(char(wn), 100);
  
	fprintf(fd, '<!-- %s -->\n', char(wn));
  fprintf(fd, '  <tr valign="top">\n');
  fprintf(fd, '    <td bgcolor="#F2F2F2">\n');
  fprintf(fd, '      <p>%s</p>\n', char(wn));
  fprintf(fd, '    </td>\n');
  fprintf(fd, '    <td bgcolor="#F2F2F2">\n');
  fprintf(fd, '      <p>%2.3f</p>\n', w.nenbw);
  fprintf(fd, '    </td>\n');
  fprintf(fd, '    <td bgcolor="#F2F2F2">\n');
  fprintf(fd, '      <p>-%2.1f</p>\n', w.psll);
  fprintf(fd, '    </td>\n');
  fprintf(fd, '    <td bgcolor="#F2F2F2">\n');
  fprintf(fd, '      <p>%2.1f</p>\n', w.rov);
  fprintf(fd, '    </td>\n');
  fprintf(fd, '  </tr>\n');
  
  
end


fclose(fd);

