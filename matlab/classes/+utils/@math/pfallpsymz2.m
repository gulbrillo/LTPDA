% PFALLPSYMZ2 all pass filtering to stabilize TF poles and zeros.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% 
%     All pass filtering in order to stabilize transfer function poles and
%     zeros. It inputs a partial fraction expanded discrete model and
%     outputs a pole-zero minimum phase system
% 
% CALL:
% 
%     resp= pfallpz2(ip,mresp,f,fs)
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

function varargout = pfallpsymz2(ip,mresp,f,fs)

  [a,b] = size(ip);
  if a<b
    ip = ip.'; % reshape as a column vector
  end

  [a,b] = size(f);
  if a<b
    f = f.'; % reshape as a column vector
  end

  if isempty(fs)
    fs = 1;
  end
  [a,b] = size(fs);
  if a ~= b
    disp(' Fs has to be a number. Only first term will be considered! ')
    fs = fs(1);
  end
  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Nb = numel(ip);
  for nn = 1:Nb

    p = ip(nn).poles;

    % stabilizing poles
    sp = sym(p);
    unst = abs(p) > 1;
    sp(unst) = conj(sp(unst));

    pp = sym(p(unst));
    psp = sp(unst);
    syms z
    allpsym = 1;
    for jj=1:numel(psp)
      allpsym = allpsym.*((z-pp(jj))./(z*psp(jj)-1));
    end
    funcell{nn} = allpsym;

  end
  
  fullallprsp = 1;
  
  for nn = 1:Nb
    symexpr = funcell{nn};
    nterm = subs(symexpr,z,cos((2*pi/fs).*f) + 1i.*sin((2*pi/fs).*f));
    % willing to work with columns
    if size(nterm,2)>1
      nterm = nterm.';
    end
    
    fullallprsp = fullallprsp.*nterm;
    
  end
  
%   dballprsp = double(fullallprsp);
%   rallp = real(dballprsp);
%   iallp = imag(dballprsp);
%   ang = angle(dballprsp);
  
  for kk=1:Nb   
    sresp(:,kk) = mresp(:,kk).*fullallprsp;
%     resp(:,kk) = mresp(:,kk).*(cos(ang)+1i.*sin(ang));
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

 


