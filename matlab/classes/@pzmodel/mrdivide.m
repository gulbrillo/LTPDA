% MRDIVIDE overloads the division operator for pzmodels.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MRDIVIDE overloads the division operator for pzmodels.
%
% CALL:        pzm = mrdivide(pzm1, pzm2);
%              pzm = pzm1./pzm2;
%
% This just calls rdivide.m.
% 
% <a href="matlab:utils.helper.displayMethodInfo('pzmodel', 'mrdivide')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mrdivide(varargin)

  varargout{:} = rdivide(varargin{:});
  
end

