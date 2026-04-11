% RZ2IIR Return a,b IIR filter coefficients for a real zero designed using the bilinear transform.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RZ2IIR Return a,b IIR filter coefficients for a real zero
%              designed using the bilinear transform.
%
% CALL:        [a,b] = rz2iir(z, fs)
%
% REMARK:      This is just a helper function. This function should only be
%              called from class functions.
%
% INPUT:       z  - zero object
%              fs - the sample rate for the filter
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = rz2iir(varargin)

  z  = varargin{1};
  fs = varargin{2};
  
  f0 = z.f;
  w0 = f0*2*pi;

  a(1) = (2*fs + w0) / w0;
  a(2) = (-2*fs + w0) / w0;

  b(1) = 1;
  b(2) = 1;

  varargout{1} = a;
  varargout{2} = b;
end

