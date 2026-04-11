% PFALLPS2 all pass filtering to stabilize TF poles and zeros.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% 
%     All pass filtering in order to stabilize transfer function poles and
%     zeros. It inputs a partial fraction expanded discrete model and
%     outputs a pole-zero minimum phase system
% 
% CALL:
% 
%     [resp,np] = pfallps2(ip,mresp,f)
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

function varargout = pfallps2(ip,mresp,f)

  [a,b] = size(ip);
  if a<b
    ip = ip.'; % reshape as a column vector
  end

  [a,b] = size(f);
  if a<b
    f = f.'; % reshape as a column vector
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  Nb = numel(ip);
  for nn = 1:Nb

    p = ip(nn).poles;

    % stabilizing poles
    sp = p;
    unst = real(p) > 0;
    
    sp(unst) = conj(sp(unst));
    
    
    
    pp = p(unst);
    psp = sp(unst);
    allpstr = '(1';
    for jj = 1:numel(sp(unst))
      allpstr = [allpstr sprintf('.*((s-%0.20d)./(s+%0.20d))',pp(jj),psp(jj))];
    end
    allpstr = [allpstr ')'];
    
    funcell{nn} = allpstr;
    
  end
  
  
  s = (1i*2*pi).*f;
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

 


