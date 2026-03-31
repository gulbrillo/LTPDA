% EIGCSD calculates TFs from 2D cross-correlated spectra.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:
% 
%     Calculates TFs or WFs from 2dim cross correlated spectra. Input the
%     elemnts of a cross-spectral matrix
% 
%                / csd11(f)  csd12(f) \
%      CSD(f) =  |                    |
%                \ csd21(f)  csd22(f) /
% 
%     and output the frequency response of four innovation transfer
%     functions or four whitening filters that can be used to color white
%     noise or to whitening colored noise.
% 
% CALL: [h11,h12,h21,h22] = eigcsd(csd11,csd12,csd21,csd22,varargin)
%       [h11,h12,h21,h22] = eigcsd(csd11,csd12,[],csd22,varargin)
%       [h11,h12,h21,h22] = eigcsd(csd11,[],csd21,csd22,varargin)
% 
% INPUT:
% 
%     csd11, csd12, csd21 and csd22 are the elements of the cross spectral
%     matrix
%     Input also the parameters specifying calculation options
%     'USESYM' define the calculation method, allowed values are 0
%     (double precision arithmetic) and 1 (symbolic toolbox variable
%     precision arithmetic)
%     'DIG' define the digits used in VPA calculation
%     'OTP' define the output type. Allowed values are 'TF' output the
%     transfer functions or 'WF' output the whitening filters frequency
%     responses
%     'KEEPVAR' get a whitening filter that preserve the variance of
%     the input data. Values are true or false
%     'VARS' first and second channels variance
% 
% OUTPUT:
% 
%     h11, h12, h21 and h22 are the four innovation TFs frequency responses
%     or the four whitening filters frequency responses
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [h11,h12,h21,h22] = eigcsd(csd11,csd12,csd21,csd22,varargin)

  % Init

  S11 = csd11;
  S22 = csd22;
  
  if isempty(csd12) && isempty(csd21)
    error(' You must input csd12 or csd21 ')
  end
  
  if isempty(csd12)
    S12 = conj(csd21);
  else
    S12 = csd12;
  end
  if isempty(csd21)
    S21 = conj(csd12);
  else
    S21 = csd21;
  end
  
  npts = length(S11);

  % Finding parameters

  % default
  usesym = 0;
  dig = 50;
  otp = 'TF';
  kv = false;
  vars = [1 1];
%   fs = 10;

  if ~isempty(varargin)
    for j=1:length(varargin)
      if strcmp(varargin{j},'USESYM')
        usesym = varargin{j+1};
      end
      if strcmp(varargin{j},'DIG')
        dig = varargin{j+1};
      end
      if strcmp(varargin{j},'OTP')
        otp = varargin{j+1};
      end
      if strcmp(varargin{j},'KEEPVAR')
        kv = varargin{j+1};
      end
      if strcmp(varargin{j},'VARS')
        vars = varargin{j+1};
      end
    end
  end

  % Defining calculation method
  if usesym == 1
    method = 'VPA';
  else
    method = 'NUM';
  end

  % Finding suppression

  k = min(sqrt(S11./S22));
  if k>=1
    suppr = floor(k);
  else
    n=0;
    while k<1
      k=k*10;
      n=n+1;
    end
    k = floor(k);
    suppr = k*10^(-n);
  end

  supmat = [1 0;0 suppr];
  % isupmat = [1 0;0 1/suppr];
  isupmat = inv(supmat);
  
  % check for keep variance option
  if isequal(otp,'WF') && kv
    % get mean of spectra
    s1 = sqrt(vars(1));
    s2 = sqrt(vars(2));
  end

  % Core Calculation

  switch method
    case 'NUM'

      % initializing output data
      h11 = ones(npts,1);
      h12 = ones(npts,1);
      h21 = ones(npts,1);
      h22 = ones(npts,1);
      
      % T = zeros(2,2,npts);
      % D = zeros(2,2,npts);

      for phi = 1:npts

        % Appliing suppression
        PP = supmat*[S11(phi) S12(phi);S21(phi) S22(phi)]*supmat;
        
        [V,D] = eig(PP);
        
        % Correcting the output of eig
        Vp = fliplr(V);
        Lp = rot90(rot90(D));
        
        % Correcting the phase
        [a,b] = size(PP);
        for ii=1:b
          Vp(:,ii) = Vp(:,ii).*(cos(angle(Vp(ii,ii)))-1i*sin(angle(Vp(ii,ii))));
          Vp(ii,ii) = real(Vp(ii,ii));
        end
                
        % Definition of the transfer functions
        switch otp
          case 'TF'
            HH = isupmat*[Vp(:,1) Vp(:,2)]*[sqrt(Lp(1,1)) 0;0 sqrt(Lp(2,2))];
          case 'WF'
            HH = [1/sqrt(Lp(1,1)) 0;0 1/sqrt(Lp(2,2))]*inv(Vp)*supmat;
            % HH = [1/sqrt(Lp(1,1)) 0;0 1/sqrt(Lp(2,2))]*(Vp')*supmat;
        end

        if isequal(otp,'WF') && kv
          h11(phi,1) = s1*HH(1,1);
          h12(phi,1) = s1*HH(1,2);
          h21(phi,1) = s2*HH(2,1);
          h22(phi,1) = s2*HH(2,2);
        else
          h11(phi,1) = HH(1,1);
          h12(phi,1) = HH(1,2);
          h21(phi,1) = HH(2,1);
          h22(phi,1) = HH(2,2);
        end
        
        % T(:,:,phi) = conj(HH)*[S11(phi) S12(phi);S21(phi) S22(phi)]*HH.';
        % D(:,:,phi) = conj(HH)*HH.' - [S11(phi) S12(phi);S21(phi) S22(phi)];

      end

    case 'VPA'
      % Define the numerical precision
      digits(dig)

      % initializing output data
      h11 = vpa(ones(npts,1));
      h12 = vpa(ones(npts,1));
      h21 = vpa(ones(npts,1));
      h22 = vpa(ones(npts,1));

      SS11 = vpa(S11);
      SS12 = vpa(S12);
      SS21 = vpa(S21);
      SS22 = vpa(S22);
      
      for phi = 1:npts

        % Appliing suppression
        PP = supmat*[SS11(phi) SS12(phi);SS21(phi) SS22(phi)]*supmat;
        
        [V,D] = eig(PP);
        Vp1 = V(:,1);
        Vp2 = -1.*V(:,2);
        Lp1 = D(1,1);
        Lp2 = D(2,2);

        % Definition of the transfer functions
        switch otp
          case 'TF'
            HH = isupmat*[Vp1 Vp2]*[sqrt(Lp1) 0;0 sqrt(Lp2)];
          case 'WF'
            % HH = [1/sqrt(Lp1) 0;0 1/sqrt(Lp2)]*inv([Vp1 Vp2])*supmat;
            HH = inv(isupmat*[Vp1 Vp2]*[sqrt(Lp1) 0;0 sqrt(Lp2)]);
        end

        if isequal(otp,'WF') && kv
          h11(phi,1) = s1*HH(1,1);
          h12(phi,1) = s1*HH(1,2);
          h21(phi,1) = s2*HH(2,1);
          h22(phi,1) = s2*HH(2,2);
        else
          h11(phi,1) = HH(1,1);
          h12(phi,1) = HH(1,2);
          h21(phi,1) = HH(2,1);
          h22(phi,1) = HH(2,2);
        end
        
      end
      h11 = double(h11);
      h12 = double(h12);
      h21 = double(h21);
      h22 = double(h22);
  end
  
