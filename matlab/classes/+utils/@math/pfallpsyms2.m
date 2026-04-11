% PFALLPSYMS2 all pass filtering to stabilize TF poles and zeros.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% 
%     All pass filtering in order to stabilize transfer function poles and
%     zeros. It inputs a partial fraction expanded discrete model and
%     outputs a pole-zero minimum phase system
% 
% CALL:
% 
%     resp= pfallpsyms2(ip,mresp,f,fs)
% 
% INPUTS:
% 
%     ip: is a struct with fields named poles
%     mresp: is a vector with functions response
%     f: is the frequancies vector in (Hz)
%     fs: is the sampling frequency in (Hz)
%     
% OUTPUTS:
% 
%     resp: is the stable functions frequency response
%
% NOTE:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = pfallpsyms2(ip,mresp,f)

  [a,b] = size(ip);
  if a<b
    ip = ip.'; % reshape as a column vector
  end

  [a,b] = size(f);
  if a<b
    f = f.'; % reshape as a column vector
  end
  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Nb = numel(ip);
  for nn = 1:Nb

    p = ip(nn).poles;

    % stabilizing poles
    sp = sym(p);
    unst = real(p) > 0;
    sp(unst) = conj(sp(unst));

    pp = sym(p(unst));
    psp = sp(unst);
    syms s
    allpsym = 1;
    for jj=1:numel(psp)
      allpsym = allpsym.*((s-pp(jj))./(s+psp(jj)));
    end
    funcell{nn} = allpsym;

  end
  
  fullallprsp = 1;
  
  for nn = 1:Nb
    symexpr = funcell{nn};
    nterm = subs(symexpr,s,(1i*2*pi).*f);
    % willing to work with columns
    if size(nterm,2)>1
      nterm = nterm.';
    end
    
    fullallprsp = fullallprsp.*nterm;
    
  end
  
%   rallp = real(fullallprsp);
%   iallp = imag(fullallprsp);
%   ang = atan(iallp./rallp);
  
  for kk=1:Nb   
    sresp(:,kk) = mresp(:,kk).*fullallprsp;
%     sresp(:,kk) = mresp(:,kk).*(cos(ang)+1i.*sin(ang));
  end
  
  for kk=1:Nb   
    resp(:,kk) = double(sresp(:,kk));
  end
  
  
  % output
  if nargout == 1
    varargout{1} = resp;
  else
    error('Too many output arguments!')
  end
end

 


