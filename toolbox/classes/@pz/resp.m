
% RESP returns the complex response of the pz object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RESP returns the complex response of the pz object. The
%              response is computed assuming that object represents a pole.
%              If the object represents a zero, just take the inverse of
%              the returned response: 1./r.
%
% CALL:        [f,r] = resp(p, f);          % compute response for vector f
%              [f,r] = resp(p, f1, f2, nf); % compute response from f1 to f2
%                                           % in nf steps.
%              [f,r] = resp(p, f1, f2, nf, scale); % compute response from f1 to f2
%                                                  % in nf steps using scale ['lin' or 'log'].
%              [f,r] = resp(p);             % compute response
%
% REMARK:      This is just a helper function. This function should only be
%              called from class functions.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f,r] = resp(varargin)

  %%% Input objects checks
  if nargin < 1
    error('### incorrect number of inputs.')
  end

  %%% look at inputs
  p = varargin{1};
  if ~isa(p, 'pz')
    error('### first argument should be a pz object.');
  end

  %%% decide whether we modify the pz-object, or create a new one.
  p = copy(p, nargout);

  %%% Now look at the pole
  f0 = p.f;
  Q  = p.q;

  %%% Define frequency vector
  f = [];

  if nargin == 1
    f1 = f0/10;
    f2 = f0*10;
    nf = 1000;
    scale = 'lin';
  elseif nargin == 2
    f = varargin{2};
  elseif nargin == 4
    f1 = varargin{2};
    f2 = varargin{3};
    nf = varargin{4};
    scale = 'lin';
  elseif nargin == 5
    f1    = varargin{2};
    f2    = varargin{3};
    nf    = varargin{4};
    scale = varargin{5};
  else
    error('### incorrect number of inputs.');
  end

  %%% Build f if we need it
  if isempty(f)
    switch lower(scale)
      case 'lin'
        f   = linspace(f1, f2, nf);
      case 'log'
        f = logspace(log10(f1), log10(f2), nf);
    end
  end

 %%% Now compute the response 
  if Q>=0.5
    r = pz.resp_pz_Q_core(f, f0, Q);
  else
    r = pz.resp_pz_noQ_core(f, f0);
  end
end

