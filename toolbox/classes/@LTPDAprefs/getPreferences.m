% GETPREFERENCES returns the LTPDA preference instance.
%
% Call:        LTPDAprefs.getPreference()
%
% Parameters:
%         -
%

function prefs = getPreferences
  prefs = getappdata(0, 'LTPDApreferences');
  if isempty(prefs)
    error('### No LTPDA Preferences found in memory. Please run ltpda_startup.');
  end
end
