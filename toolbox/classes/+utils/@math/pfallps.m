% PFALLPS all pass filtering in order to stabilize TF poles and zeros.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% 
%     All pass filtering in order to stabilize transfer function poles and
%     zeros. It inputs a partial fraction expanded discrete model and
%     outputs a pole-zero minimum phase system
% 
% CALL:
% 
%     [resp,np] = pfallps(ir,ip,id,mresp,f)
%     [resp,np] = pfallps(ir,ip,id,mresp,f,minphase)
%     [resp,np,nz] = pfallps(ir,ip,id,mresp,f,minphase)
% 
% INPUTS:
% 
%     ir: are residues
%     ip: are poles
%     id: is direct term
%     f: is the frequancies vector in (Hz)
%     minphase: is a flag assuming true (output a minimum phase system) or
%     false (output a stable non minimum phase system) values. Default,
%     true
%     
% OUTPUTS:
% 
%     resp: is the minimum phase frequency response
%     np: are new stable poles
%     nz: are new stable zeros, this will be set only if minphase is set to
%     false
%
% NOTE:
% 
%     This function make use of signal analysis toolbox functions
%     
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = pfallps(ir,ip,id,mresp,f,varargin)
  
  % Reshaping
  [a,b] = size(ir);
  if a<b
    ir = ir.'; % reshape as a column vector
  end

  [a,b] = size(ip);
  if a<b
    ip = ip.'; % reshape as a column vector
  end

  [a,b] = size(f);
  if a<b
    f = f.'; % reshape as a column vector
  end

  [a,b] = size(id);
  if a > b
    id = id.'; % reshape as a row
    id = id(1,:); % taking the first row (the function can handle only simple constant direct terms)
  end
  
  if nargin == 6
    minphase = varargin{1};
  else
    minphase = false;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % stabilizing poles
  sp = p;
  unst = real(sp) > 0;
  sp(unst) = -1*conj(sp(unst));

  [Na,Nb] = size(r);
  for nn = 1:Nb
    
    s = 1i.*2.*pi.*f;
    pp = p(unst);
    psp = sp(unst);
    for ii = 1:length(s)
      nterm = 1;
      for jj = 1:length(sp(unst))
        nterm = nterm.*(s(ii)-pp(jj))./(s(ii)-psp(jj));
      end
      phs(ii,1) = angle(nterm);
    end
    
    resp(:,nn) = mresp(:,nn).*(cos(phs)+1i.*sin(phs));
    
    % output stable poles
    np(:,nn) = sp;
    
    if minphase
      % finding zeros
      [num,den] = residue(r,p,d);
      zrs = roots(num);
      
      % stabilizing zeros
      szrs = zrs;
      zunst = abs(zrs) > 1;
      szrs(zunst) = 1./conj(zrs(zunst));
      
      zzrs = zrs(zunst);
      zszrs = szrs(zunst);
      for ii = 1:length(s)
        nterm = 1;
        for jj = 1:length(szrs(zunst))
          nterm = nterm.*(s(ii)-zszrs(jj))./(s(ii)-zzrs(jj));
        end
        zphs(ii,1) = angle(nterm);
      end

      resp(:,nn) = resp(:,nn).*(cos(zphs)+1i.*sin(zphs));
      
      % output stable zeros
      nz(:,nn) = szrs;
    end  
  end
  % output
  if nargout == 1
    varargout{1} = resp;
  elseif nargout == 2
    varargout{1} = resp;
    varargout{2} = np;
  elseif (nargout == 3) && minphase
    varargout{1} = resp;
    varargout{2} = np;
    varargout{3} = nz;
  else
    error('Too many output arguments!')
  end
end