% MTIMES overloads the multiplication operator for pzmodels.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TIMES overloads the multiplication operator for pzmodels.
%
% CALL:        pzm = times(pzm1, pzm2);
%              pzm = pzm1*pzm2;
% 
% This just calls times.m.
%
% <a href="matlab:utils.helper.displayMethodInfo('pzmodel', 'mtimes')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mtimes(varargin)

  varargout{:} = times(varargin{:});

end

