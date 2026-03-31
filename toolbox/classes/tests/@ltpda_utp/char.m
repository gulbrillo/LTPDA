% CHAR convert a ltpda_utp object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert an ltpda_utp object into a string.
%
% CALL:        string = char(sw);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)

  %%% Get input

  pstr = [];
  for kk = 1:nargin
    utp = varargin{kk};

    pstr = [class(utp)];

    if kk<nargin
      pstr = [pstr ', '];
    end
  end

  varargout{1} = pstr;

end

