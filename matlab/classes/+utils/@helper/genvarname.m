% GENVARNAME is a wrapper for the different MATLAB versions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GENVARNAME is a wrapper for the different MATLAB versions.
%              Since the MATLAB version R2014a is the function 'genvarname'
%              obsolete. This version uses the new command
%              'matlab.lang.makeValidName'.
%
% CALL:        varname = genvarname(str)
%              varname = genvarname(str, exclusions)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = genvarname(varargin)
  
  persistent requiredMatlabVersion
  persistent currentMatlabVersion
  
  if isempty(currentMatlabVersion)
    v = ver('MATLAB');
    currentMatlabVersion = utils.helper.ver2num(v.Version);
    requiredMatlabVersion = 8.03;
  end
  
  if currentMatlabVersion < requiredMatlabVersion
    [varargout{1:nargout}] = genvarname(varargin{:});
  else
    [varargout{1:nargout}] = matlab.lang.makeValidName(varargin{:});
  end
  
end
