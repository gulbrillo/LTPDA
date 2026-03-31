% PFRESP returns frequency response of a partial fraction TF.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:
%
% Returns frequency response of a partial fraction expanded function
% (continuous or discrete).
%
% Continuous case
% The expected model is:
%
%          r1             rN
% f(s) = ------ + ... + ------ + d1 + d2*s + ... + dK*s^{K-1}
%        s - p1         s - p1
%
% Discrete case
% The expected model is:
%
%         z*r1           z*rN
% f(z) = ------ + ... + ------ + d1 + d2*z^{-1} + ... + dK*z^{-(K-1)}
%        z - p1         z - p1
%
% NOTE: The function cannot handle poles multiplicity higher than 1 in
% z domain. Multiple poles in s-domain are accepted.
%
% CALL:   pfr = pfresp(pfparams)
%
% INPUT:
%
% pfparams is a struct containing input parameters
%   pfparams.type = 'cont' Assumes a continuous model
%   pfparams.type = 'disc' Assumes a discrete model
%   pfparams.freq set the frequencies vector in Hz
%   pfparams.res - set the vector of residues
%   pfparams.pol - set the vector of poles
%   pfparams.pmul - set the vectr flag with poles multiplicity (this option
%   is used only for continuous models)
%   pfparams.dterm - set the vector of direct terms
%   pfparams.fs - set the sampling frequency (Necessary for the discrete
%   case)
%
% OUTPUT:
%
% pfr is a struct containing output data and parameters
%   pfr.type = 'cont' if the model is continuous
%   pfr.type = 'disc' if the model is discrete
%   pfr.freq - frequencies vector
%   pfr.nfreq - normalized frequencies vector (Discrete case)
%   pfr.angfreq - angular frequencies vector
%   pfr.resp - frequency response data
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pfr = pfresp(pfparams)
  
  %%% switching between continuous and discrete
  
  switch pfparams.type
    case 'cont'
      % collecting input parameters
      f = pfparams.freq;
      % willing to work with row
      if size(f,1)>size(f,2)
        f = f.';
      end
      r = pfparams.res;
      p = pfparams.pol;
      pmul = pfparams.pmul;
      d = pfparams.dterm;
      % willing to work with row
      if ~isempty(d) && size(d,1)>size(d,2)
        d = d.';
      end
      
      N = length(p);
      
% substituted by faster code 03-Feb-2011      
%       Nf = length(f);
%       rsp = zeros(Nf,1);
%       indx = (0:length(d)-1).';
%       for ii = 1:Nf
%         for jj = 1:N
%           m = pmul(jj);
%           rsptemp = r(jj)/(1i*2*pi*f(ii)-p(jj))^m;
%           rsp(ii) = rsp(ii) + rsptemp;
%         end
%         % Direct terms response
%         rsp(ii) = rsp(ii) + sum((((1i*2*pi*f(ii))*ones(length(d),1)).^indx).*d);
%       end

% new code for a faster response calculation 03-Feb-2011
      rsp = zeros(size(f));
      for jj = 1:N
        m = pmul(jj);
        rsptemp = r(jj)./(1i*2*pi.*f-p(jj)).^m;
        rsp = rsp + rsptemp;
      end
      % get direct term response
      if ~isempty(d)
        Z = ones(numel(d),numel(f));
        ss = 2.*pi.*1i.*f;
        for jj=2:size(Z,1)
          Z(jj,:) = ss.^(jj-1);
        end
        rdtemp = d*Z;
        rsp = rsp + sum(rdtemp,1);
      end
      
      % Output
      pfr.type = 'cont';
      pfr.freq = f;
      pfr.angfreq = 2*pi*f;
      pfr.resp = rsp;
      
    case 'disc'
      % collecting input parameters
      f = pfparams.freq;
      fs = pfparams.fs;
      r = pfparams.res;
      p = pfparams.pol;
      d = pfparams.dterm;
      
      Nf = length(f);
      N = length(p);
      
      % Defining normalized frequencies
      fn = f./fs;
      
      rsp = zeros(Nf,1);
      indx = 0:length(d)-1;
      for ii = 1:Nf
        for jj = 1:N
          rsptemp = exp(1i*2*pi*fn(ii))*r(jj)/(exp(1i*2*pi*fn(ii))-p(jj));
          rsp(ii) = rsp(ii) + rsptemp;
        end
        % Direct terms response
        rsp(ii) = rsp(ii) + sum(((exp((1i*2*pi*f(ii))*ones(length(d),1))).^(-1.*indx)).*d);
      end
      
      % Output
      pfr.type = 'disc';
      pfr.freq = f;
      pfr.nfreq = fn;
      pfr.angfreq = 2*pi*f;
      pfr.resp = rsp;
  end
end