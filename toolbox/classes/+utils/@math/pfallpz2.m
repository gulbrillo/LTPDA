% PFALLPZ2 all pass filtering to stabilize TF poles and zeros.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% 
%     All pass filtering in order to stabilize transfer function poles and
%     zeros. It inputs a partial fraction expanded discrete model and
%     outputs a pole-zero minimum phase system
% 
% CALL:
% 
%     [resp,np] = pfallpz2(ip,mresp,f,fs)
% 
% INPUTS:
% 
%     ip: are poles
%     f: is the frequancies vector in (Hz)
%     fs: is the sampling frequency in (Hz)
%     
% OUTPUTS:
% 
%     resp: is the functions phase frequency response
%     np: are the new stable poles
%
% NOTE:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = pfallpz2(ip,mresp,f,fs)

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
  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  Nb = numel(ip);
  for nn = 1:Nb

    p = ip(nn).poles;

    % stabilizing poles
    sp = p;
    unst = abs(p) > 1;
    sp(unst) = conj(sp(unst));
    
    pp = p(unst);
    psp = sp(unst);
    allpstr = '(1';
    for jj = 1:numel(sp(unst))
      allpstr = [allpstr sprintf('.*((z-%0.20d)./(z*%0.20d-1))',pp(jj),psp(jj))];
    end
    allpstr = [allpstr ')'];
    
    funcell{nn} = allpstr;
    
  end
  
  z = cos((2*pi/fs).*f) + 1i.*sin((2*pi/fs).*f);
  fullallprsp = 1;
  
  for nn = 1:Nb
    
    nterm = eval(funcell{nn});
    % willing to work with columns
    if size(nterm,2)>1
      nterm = nterm.';
    end
    
    allprsp(:,nn) = nterm;
    
    fullallprsp = fullallprsp.*nterm;
    
  end
  
  phs = angle(fullallprsp);
  
  for kk=1:Nb   
    resp(:,kk) = mresp(:,kk).*(cos(phs)+1i.*sin(phs));
  end
  
  
  % output
  if nargout == 1
    varargout{1} = resp;
  else
    error('Too many output arguments!')
  end
end

 


