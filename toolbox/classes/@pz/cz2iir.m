% CZ2IIR return a,b IIR filter coefficients for a complex zero designed using the bilinear transform.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CZ2IIR return a,b IIR filter coefficients for a complex zero
%              designed using the bilinear transform.
%
% CALL:        [a,b] = cz2iir(z, fs)
%
% REMARK:      This is just a helper function. This function should only be
%              called from class functions.
%
% INPUTS:      z  - zero object
%              fs - the sample rate for the filter
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cz2iir(varargin)

  z  = varargin{1};
  fs = varargin{2};

  f0 = z.f;
  q  = z.q;

  w0  = f0*2*pi;
  w02 = w0^2;

  a(1) = (-q*w02/2 - 2*q*fs*fs - w0*fs) / (q*w02);
  a(2) = (-w02+4*fs*fs) / w02;
  a(3) = (-q*w02/2 - 2*q*fs*fs + w0*fs) / (q*w02);

  b(1) =  1;
  b(2) = -2;
  b(3) = -1;

  varargout{1} = a;
  varargout{2} = b;
end

