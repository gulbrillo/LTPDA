% RESPCORE returns the complex response of one rational object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RESPCORE returns the complex response of one rational object
%              as a data-vector. This function should only be used by the
%              resp method of the ltpda_tf class.
%
% CALL:        r = respCore(obj, f);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function r = respCore(varargin)
  
  %%% Get Inputs
  obj = varargin{1};
  f   = varargin{2}; % Row vector

  %%% Compute response
  s = 2*pi*1i*f;
  numr = polyval(obj.num, s);
  denr = polyval(obj.den, s);
  r = numr./denr; % Row vector
  
end

