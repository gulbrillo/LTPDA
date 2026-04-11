% GROWT grows the time (x) vector if it is empty.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GROWT grows the time (x) vector if it is empty.
%
% CALL:        d    = growT(d)
%
% INPUT:       d - tsdata object
%
% OUTPUT:      d - tsdata object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = growT(varargin)

  d = varargin{1};

  %%% decide whether we modify the pz-object, or create a new one.
  d = copy(d, nargout);

  % Grow the time vector
  d.setX(linspace(0, d.nsecs-1/d.fs, d.nsecs*d.fs));

  varargout{1} = d;
end

