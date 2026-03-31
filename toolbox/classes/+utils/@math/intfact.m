% INTFACT computes integer factorisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INTFACT tries to find two integers, P and Q, that satisfy
%
%          y = P/Q * x
%
%   >> [p,q] = intfact(y,x)
%
% The following call returns a parameter list object that contains the
% default parameter values:
%
% >> pl = intfact(utils, 'Params')
%
% The following call returns a string that contains the routine CVS version:
%
% >> version = intfact(utils,'Version')
%
% The following call returns a string that contains the routine category:
%
% >> category = intfact(utils,'Category')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = intfact(varargin)
  
  % Get input sample rates
  fs2 = floor(1e16*varargin{1});
  fs1 = floor(1e16*varargin{2});
  
  oncleanup = onCleanup(@() warning('on', 'MATLAB:gcd:largestFlint'));
  warning('off', 'MATLAB:gcd:largestFlint');
  g = gcd(fs2,fs1);
  
  varargout{1} = fs2/g;
  varargout{2} = fs1/g;
  
end
% END
