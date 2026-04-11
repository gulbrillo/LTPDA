% EIGPSD calculates TFs from 2D cross-correlated spectra.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:
% 
%     Calculates TFs or WFs from 2dim cross correlated spectra
% 
% CALL: [h11,h12,h21,h22] = eigpsd(psd1,csd,psd2,varargin)
% 
% INPUT:
% 
%     psd1 is the first power spectral density
%     csd is the cross spectrum
%     psd2 is the second power spectral density
%     Input also the parameters specifying calculation options
%     'USESYM' define the calculation method, allowed values are 0
%     (double precision arithmetic) and 1 (symbolic toolbox variable
%     precision arithmetic)
%     'DIG' define the digits used in VPA calculation
%     'OTP' define the output type. Allowed values are 'TF' output the
%     transfer functions or 'WF' output the whitening filters frequency
%     responses
% 
% OUTPUT:
% 
%     h11, h12, h21 and h22 are the four innovation TFs frequency responses
%     or the four whitening filters frequency responses
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [h11,h12,h21,h22] = eigpsd(psd1,csd,psd2,varargin)

  % Init

  S11 = psd1;
  S22 = psd2;
  S12 = csd;
  S21 = conj(S12);

  npts = length(S11);

  % Finding parameters

  % default
  usesym = 1;
  dig = 50;
  otp = 'TF';

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
    end
  end

  % Defining calculation method
  if usesym == 1
    method = 'VPA';
  else
    method = 'NUM';
  end

  % Finding suppressio

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
  isupmat = [1 0;0 1/suppr];

  % Core Calculation

  switch method
    case 'NUM'

      % initializing output data
      h11 = ones(npts,1);
      h12 = ones(npts,1);
      h21 = ones(npts,1);
      h22 = ones(npts,1);

      for phi = 1:npts

        % Appliing suppression
        PP = supmat*[S11(phi) S12(phi);S21(phi) S22(phi)]*supmat;

        % Calculate eignevalues Matrix Lp
        k = (4*PP(1,2)*PP(2,1))/((PP(1,1)-PP(2,2))^2);

        Lp1 = (PP(1,1)+PP(2,2)+(PP(1,1)-PP(2,2))*sqrt(1+k))/2;
        Lp2 = (PP(1,1)+PP(2,2)-(PP(1,1)-PP(2,2))*sqrt(1+k))/2;

        % Calculate eigenvectors Matrix Vp, eigenvectors are on the columns
        Vp1 = (-1/sqrt(1+(k/((1+sqrt(1+k))^2))))*[1;2*PP(2,1)/((PP(1,1)-PP(2,2))*(1+sqrt(1+k)))];
        Vp2 = (1/sqrt(1+(((1-sqrt(1+k))^2)/k)))*[(PP(1,1)-PP(2,2))*(1-sqrt(1+k))/(2*PP(2,1));1];

        % Definition of the transfer functions
        switch otp
          case 'TF'
            HH = isupmat*[conj(Vp1) conj(Vp2)]*[sqrt(Lp1) 0;0 sqrt(Lp2)];
          case 'WF'
            HH = [1/sqrt(Lp1) 0;0 1/sqrt(Lp2)]*inv([conj(Vp1) conj(Vp2)])*supmat;
        end

        h11(phi,1) = HH(1,1);
        h12(phi,1) = HH(1,2);
        h21(phi,1) = HH(2,1);
        h22(phi,1) = HH(2,2);

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

        % Calculate eignevalues Matrix Lp
        k = (4*PP(1,2)*PP(2,1))/((PP(1,1)-PP(2,2))^2);

        Lp1 = (PP(1,1)+PP(2,2)+(PP(1,1)-PP(2,2))*sqrt(1+k))/2;
        Lp2 = (PP(1,1)+PP(2,2)-(PP(1,1)-PP(2,2))*sqrt(1+k))/2;

        % Calculate eigenvectors Matrix Vp, eigenvectors are on the columns
        Vp1 = (-1/sqrt(1+(k/((1+sqrt(1+k))^2))))*[1;2*PP(2,1)/((PP(1,1)-PP(2,2))*(1+sqrt(1+k)))];
        Vp2 = (1/sqrt(1+(((1-sqrt(1+k))^2)/k)))*[(PP(1,1)-PP(2,2))*(1-sqrt(1+k))/(2*PP(2,1));1];

        % Definition of the transfer functions
        switch otp
          case 'TF'
            HH = isupmat*[conj(Vp1) conj(Vp2)]*[sqrt(Lp1) 0;0 sqrt(Lp2)];
          case 'WF'
            HH = [1/sqrt(Lp1) 0;0 1/sqrt(Lp2)]*inv([conj(Vp1) conj(Vp2)])*supmat;
        end

        h11(phi,1) = HH(1,1);
        h12(phi,1) = HH(1,2);
        h21(phi,1) = HH(2,1);
        h22(phi,1) = HH(2,2);

      end
      h11 = double(h11);
      h12 = double(h12);
      h21 = double(h21);
      h22 = double(h22);
  end