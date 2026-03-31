% FQ2RI2 Convert frequency/Q pole/zero representation into real
% and imaginary conjugate pairs. Returns [ri conj(ri)]
%
% ri= fq2ri2(f0, Q)
%

function ri= fq2ri2(f0, Q)
  
  if(nargin==0)
    disp('usage: ri = fq2ri2(f0, Q)')
    return
  elseif(nargin==1)
    ri = (1/(2*pi*f0));
  elseif(nargin==2)
    if Q <= 0.5
      disp('working on Q < 0.5') %ri =1/(2*pi*f0);
    else
      w0 = 2*pi*f0;
      G = 1/(w0*w0);
      re = -w0/(2*Q);
      im = w0*sqrt(4*Q*Q-1)/(2*Q);
      tri = complex(re,im);
      ri = G.*[tri conj(tri)]';
    end
  end
end
% END
