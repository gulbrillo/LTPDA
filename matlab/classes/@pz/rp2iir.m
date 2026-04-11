% RP2IIR Return a,b coefficients for a real pole designed using the bilinear transform.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RP2IIR Return a,b coefficients for a real pole designed using
%              the bilinear transform.
%
% CALL:        filt = rpole(p, fs)
%
% REMARK:      This is just a helper function. This function should only be
%              called from class functions.
%
% INPUT:       p  - pole object
%              fs - the sample rate for the filter
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = rp2iir(varargin)

  p  = varargin{1};
  fs = varargin{2};

  f0 = p.f;
  w0 = f0*2*pi;
  a(1) = w0 / (2*fs + w0);
  a(2) = a(1);
  b(1) = 1;
  b(2) = (w0-2*fs) / (w0+2*fs);

  varargout{1} = a;
  varargout{2} = b;
end

