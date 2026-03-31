% COMBINE combines multiple plotinfo objects into one.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COMBINE combines multiple plotinfo objects into one.
%
% CALL:        cmd = combine(pi1, pi2, ...)
%
% This simply returns the first plotinfo and is provided for backwards
% compatibility for when plotinfo was a simple plist.
% 
% INPUT:       plotinfo - plotinfo object
%
% OUTPUT:      the first input plotinfo object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = combine(varargin)

  % Collect all AOs
  pis = utils.helper.collect_objects(varargin(:), 'plotinfo');
  varargout{1} = copy(pis(1), nargout);
  
end

