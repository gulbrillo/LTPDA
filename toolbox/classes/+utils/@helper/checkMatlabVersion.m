function checkMatlabVersion
% CHECKMATLABVERSION checks the current MATLAB version.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% DESCRIPTION: CHECKMATLABVERSION checks the current MATLAB version
% complies with that required by LTPDA.
% 
%  out = utils.helper.checkMatlabVersion()
% 
% The MATLAB version is retrieved from the base application variable
% 'matlab_version' which is set by ltpda_startup.
% 
% The required version is retrieved from 'ltpda_required_matlab_version'
% which is also set by ltpda_startup.
% 
% If the current MATLAB version does not meet the requirement, then an
% error is thrown.
% 
% The following call returns an info object for this method.
%
% >> ii = utils.helper.checkMatlabVersion('INFO')
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% required version
rv = getappdata(0, 'ltpda_required_matlab_version');  
% current version
cv = strtok(getappdata(0, 'matlab_version'));

if isempty(rv)
  error('### Could not obtain the info about the Matlab version required for LTPDA. Did you run ltpda_startup?');
end

if isempty(cv)
  error('### Could not obtain the info about the Matlab version installed. Did you run ltpda_startup?');
end

rparts = getParts(rv);
cparts = getParts(cv);

if (sign(cparts - rparts) * [1; .1; .01]) < 0
  error('### This MATLAB version is not supported by LTPDA. You require version %s or higher', rv)
end

% This is copied directly from MATLAB's verLessThan function
function parts = getParts(V)
    parts = sscanf(V, '%d.%d.%d')';
    if length(parts) < 3
       parts(3) = 0; % zero-fills to 3 elements
    end
