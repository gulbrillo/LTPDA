%
% Initialize Object with size for the MCMC class
%
function obj = initObjectWithSize(varargin)
  obj = MCMC.newarray([varargin{:}]);
end
