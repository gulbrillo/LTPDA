% CP2IIR Return a,b IIR filter coefficients for a complex pole designed using the bilinear transform.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CP2IIR Return a,b IIR filter coefficients for a complex pole
%              designed using the bilinear transform.
%
% CALL:        [a,b] = cp2iir(p, fs)
%
% REMARK:      This is just a helper function. This function should only be
%              called from class functions.
%
% INPUT:       p  - pole object
%              fs - the sample rate for the filter
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cp2iir(varargin)

  p  = varargin{1};
  fs = varargin{2};

  f0 = p.f;
  q  = p.q;

  w0  = f0*2*pi;
  w02 = w0^2;

  k    = (q*w02 + 4*q*fs*fs + 2*w0*fs) / (q*w02);
  b(1) =  1;
  b(2) = (2*w02-8*fs*fs) / (k*w02);
  b(3) = (q*w02 + 4*q*fs*fs - 2*w0*fs) / (k*q*w02);

  a(1) =  1/k;
  a(2) = -2/k;
  a(3) = -1/k;
  a    =  a*-2;

  varargout{1} = a;
  varargout{2} = b;
end

