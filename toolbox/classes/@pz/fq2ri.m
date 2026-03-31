% FQ2RI Convert frequency/Q pole/zero representation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FQ2RI Convert frequency/Q pole/zero representation into: 
%                  -Q=Nan: real pole/zero  [output: ri]
%                  -Q>0.5 real and imaginary conjugate pairs [ri conj(ri)]
%                  -Q=0.5 two equal real poles [ri ri]
%                  -Q<0.5 two real poles [ri ri]
% 
% CALL:        ri= fq2ri(f0, Q)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ri= fq2ri(f0, Q)

  if(nargin==0)
    disp('usage: ri = fq2ri2(f0, Q)')
    return
  elseif(nargin==1 || nargin==2 && isnan(Q))
    ri = -((2*pi*f0));
  elseif(nargin==2 && Q>=0)
    if Q < 0.5
      disp('!!! Q < 0.5! Splitting to two real poles/zeros;')
      a = 2*pi*f0/(2*Q)*(1+sqrt(1-4*Q^2));
      b = 2*pi*f0/(2*Q)*(1-sqrt(1-4*Q^2));
      ri = [a b];
    elseif Q == 0.5
      disp('!!! Q = 0.5! Returning two equal real poles/zeros;')
      w0  = 2*pi*f0;
      re  = w0/(2*Q);
      ri  = [re re];
    else
      w0  = 2*pi*f0;
      re  = -w0/(2*Q);
      im  = w0*sqrt(1-1/(4*Q^2));
      tri = complex(re,im);
      ri  = [tri; conj(tri)];
    end

  end

