% Check that direct setting of LTPDA preferences is working.
% 
% M Hewitson
% 
% $Id$
% 
function test_LTPDAprefs_cl_set
  
  % Display
  LTPDAprefs('Display', 'verboseLevel', LTPDAprefs.verboseLevel)
  LTPDAprefs('Display', 'wrapstrings', LTPDAprefs.wrapStrings)
  
  % plot
  LTPDAprefs('plot', 'axesFontSize', LTPDAprefs.axesFontSize);
  LTPDAprefs('plot', 'axesFontWeight', LTPDAprefs.axesFontWeight);
  LTPDAprefs('plot', 'axesLineWidth', LTPDAprefs.axesLineWidth);
  LTPDAprefs('plot', 'gridStyle', LTPDAprefs.gridStyle);
  LTPDAprefs('plot', 'minorGridStyle', LTPDAprefs.minorGridStyle);
  
  % time
  LTPDAprefs('time', 'timezone', LTPDAprefs.timezone);
  LTPDAprefs('time', 'timeformat', LTPDAprefs.timeformat);
  
  % misc
  LTPDAprefs('misc', 'default_window', LTPDAprefs.default_window);
  
  
end