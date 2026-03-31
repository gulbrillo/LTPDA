% NDEIGCSD calculates TFs from ND cross-correlated spectra.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:
%
%     Calculates TFs or WFs from Ndim cross correlated spectra. Input
%     elemnts of a cross-spectral matrix in 2D are assumed to be:
%
%                / csd11(f)  csd12(f) \
%      CSD(f) =  |                    |
%                \ csd21(f)  csd22(f) /
%
%
% CALL:             h = eigcsd(csd,varargin)
%
% INPUT:
%
%     csd are the elements of the cross spectra matrix. It is a (n,n,m)
%     matrix where n is the dimensionality of the system and m is the
%     number of frequency samples
% 
%     Input also the parameters specifying calculation options
%     
%     'OTP' define the output type. Allowed values are 'TF' output the
%     transfer functions or 'WF' output the whitening filters frequency
%     responses. Default 'TF'
%     'MTD' define the method for the calculation of the csd matrix of a
%     multichannel system. Admitted values are 'PAP' referring to Papoulis
%     [1] style calculation in which csd = TF*I*TF' and 'KAY' referring to
%     Kay [2] style calculation in which csd = conj(TF)*I*TF.'.
%     Default 'PAP'
%
% OUTPUT:
%
%     h are the TFs or WFs frequency responses. It is a (n,n,m) matrix in
%     which n is the dimensionality of the system and m is the number of
%     frequency samples.
% 
% REFERENCES:
% 
% [1] A. Papoulis, Probability Random Variable and Stochastic Processes,
% McGraw-Hill, third edition, 1991.
% [2] S. M. Kay, Modern Spectral Estimation, Prentice Hall, 1988.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h = ndeigcsd(csd,varargin)
  
  [l,m,npts] = size(csd);
  if m~=l
    error('!!! The first two dimensions of csd must be equal. csd must be a square matrix frequency by frequency.')
  end
  
  % Finding parameters
  
  % default
  otp = 'TF';
  mtd = 'PAP';
  
  if ~isempty(varargin)
    for j=1:length(varargin)
      if strcmp(varargin{j},'OTP')
        otp = upper(varargin{j+1});
      end
      if strcmp(varargin{j},'MTD')
        mtd = upper(varargin{j+1});
      end
    end
  end
  
  % Finding suppression  
  suppr = ones(l,l);
  for ii = 2:l
    k = ones(l,1);  
    for jj = ii-1:-1:1
      k(jj) = min(sqrt(csd(jj,jj,:)./csd(ii,ii,:)));
      if k(jj)>=1
        suppr(jj,ii) = floor(k(jj));
      else
        n=0;
        while k(jj)<1
          k(jj)=k(jj)*10;
          n=n+1;
        end
        k(jj) = floor(k(jj));
        suppr(jj,ii) = k(jj)*10^(-n);
      end
    end
    %     csuppr(ii) = prod(suppr(:,ii));
  end
  csuppr = prod(suppr,2);
  supmat = diag(csuppr);
  ssup = supmat*supmat.';
  
  supmat = rot90(rot90(supmat));
  isupmat = inv(supmat);
  
  % Core Calculation
  
  
  % initializing output dat
  
  h = ones(l,m,npts);
  
  for phi = 1:npts
    
    % Appliing suppression
    
    PP = csd(:,:,phi);
    PP = supmat*PP*supmat;
    
%     [V,D] = eig(PP,ssup);
    [V,D,U] = svd(PP,0);
%     [V,D] = eig(PP);
    
    % Correcting the output of eig
%     V = fliplr(V);
%     D = rot90(rot90(D));
    
%     % Correcting the output of eig
%     Vp = fliplr(V);
%     Lp = rot90(rot90(D));
%     
%     % Correcting the phase
%     [a,b] = size(PP);
%     for ii=1:b
%       Vp(:,ii) = Vp(:,ii).*(cos(angle(Vp(ii,ii)))-1i*sin(angle(Vp(ii,ii))));
%       Vp(ii,ii) = real(Vp(ii,ii));
%     end
%     
%     V = Vp;
%     D = Lp;
    
    
    % Definition of the transfer functions
    
    switch otp
      case 'TF'
        switch mtd
          case 'PAP'
%             HH = ssup*V*sqrt(D);
            HH = isupmat*V*sqrt(D);
%             HH = V*sqrt(D);
          case 'KAY'
%             HH = conj(ssup*V*sqrt(D));
            HH = conj(isupmat*V*sqrt(D));
%              HH = conj(V*sqrt(D));
        end
      case 'WF'
        switch mtd
          case 'PAP'
            %HH = inv(ssup*V*sqrt(D));
            HH = inv(isupmat*V*sqrt(D));
          case 'KAY'
            %HH = inv(conj(ssup*V*sqrt(D)));
            HH = inv(conj(isupmat*V*sqrt(D)));
        end
    end
    
    
    h(:,:,phi) = HH;
    
  end
  
  
end