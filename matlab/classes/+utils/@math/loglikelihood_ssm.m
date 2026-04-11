%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute log-likelihood for SSM objects
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [loglk snr]= loglikelihood_ssm(xn,in,out,noise,model,params, spl, Amats, Bmats, Cmats, Dmats)
  
  loglk = 0;
  snr = 0;
  switch class(in)
    case 'ao'
      % parameters
      fs = noise(1).fs;
      N = length(noise(1).y);
      
      if (numel(in) == 1 && numel(out) == 1)
        
        f = noise(1).x;
        
        xn = double(xn);
        
        spl.pset('f', f);
        
        eval = copy(model,1);
        
        % set parameter values
        eval.doSetParameters(params, xn);
        
        % make numeric
        eval.doSubsParameters(params, true);
        
        % check if stable
        if ~isStable(eval,plist('debug',false))
          loglk = inf;
          snr = 0;
          return
        end
        
        % do bode
        h11  = bode(eval, spl);
        
        f = in.x;
        % spectra to variance
        C11 = (N*fs/2)*noise(1).y;
        
        % compute elements of inverse cross-spectrum matrix
        InvS11 = 1./C11;
        
        % compute log-likelihood terms first, all at once does not cancel the
        % imag part when multiplying x.*conj(x)
        v1v1 = conj(out(1).y - h11.y.*in(1).y).*(out(1).y - h11.y.*in(1).y);
        
        tmplt = h11.*in(1).y;
        
        %computing SNR
        snrexp = utils.math.stnr(tmplt,out(1).y,InvS11);
        
        snr = snr + 20*log10(snrexp);
        
        log1exp = sum(InvS11.*v1v1);
        
        loglk = loglk + log1exp;
        
      elseif (numel(in) == 2 && numel(out) == 2)
        
        f = noise(1).x;
        
        xn = double(xn);
        
        spl.pset('f', f);
        
        eval = copy(model,1);
        
        % set parameter values
        eval.doSetParameters(params, xn);
        
        % make numeric
        eval.doSubsParameters(params);
        
        % check if stable
        if ~isStable(eval,plist('debug',false))
          loglk = inf;
          snr = 0;
          return
        end
        
        % do bode
        h  = bode(eval, spl);
        h11 = h(1);
        h12 = h(2);
        h21 = h(3);
        h22 = h(4);
        
        % spectra to variance
        C11 = (N*fs/2)*noise(1).y;
        C22 = (N*fs/2)*noise(2).y;
        C12 = (N*fs/2)*noise(3).y;
        C21 = (N*fs/2)*noise(4).y;
        
        % compute elements of inverse cross-spectrum matrix
        InvS11 = (C22./(C11.*C22 - C12.*C21));
        InvS22 = (C11./(C11.*C22 - C12.*C21));
        InvS12 = (C21./(C11.*C22 - C12.*C21));
        InvS21 = (C12./(C11.*C22 - C12.*C21));
        
        % compute log-likelihood terms first, all at once does not cancel the
        % imag part when multiplying x.*conj(x)
        v1v1 = conj(out(1).y - h11.y.*in(1).y - h12.y.*in(2).y).*(out(1).y - h11.y.*in(1).y - h12.y.*in(2).y);
        v2v2 = conj(out(2).y - h21.y.*in(1).y - h22.y.*in(2).y).*(out(2).y - h21.y.*in(1).y - h22.y.*in(2).y);
        v1v2 = conj(out(1).y - h11.y.*in(1).y - h12.y.*in(2).y).*(out(2).y - h21.y.*in(1).y - h22.y.*in(2).y);
        v2v1 = conj(out(2).y - h21.y.*in(1).y - h22.y.*in(2).y).*(out(1).y - h11.y.*in(1).y - h12.y.*in(2).y);
        
        tmplt1 = h11.*in(1).y + h12.*in(2).y;
        tmplt2 = h21.*in(1).y + h22.*in(2).y;
        
        %computing SNR
        snrexp = utils.math.stnr([tmplt1 tmplt2],[out(1).y out(2).y],[InvS11 InvS22 InvS12 InvS21]);
        
        snr = snr + 20*log10(snrexp);
        
        log1exp = sum(InvS11.*v1v1 + InvS22.*v2v2 - InvS12.*v1v2 - InvS21.*v2v1);
        
        loglk = loglk + log1exp;
        
      else
        error('This method is only implemented for 1 input / 1 output model or for 2 inputs / 2 outputs models');
      end
      
    case 'matrix'
      % parameters
      
      fs = in(1).objs(1).fs;
      
      % num. experiments
      nexp = numel(in);
      
      noutChannels = numel(out(1).objs);
      
      N = length(noise(1).objs(1).y);
      
      loglk = 0;
      for nnn = 1:nexp
        
        if ((numel(in(1).objs) == 1) && numel(out(1).objs) == 1)
          
          freqs = noise(nnn).objs(1).data.getX;
          
          xn = double(xn);
          
          spl.pset('f', freqs);
          
          eval = copy(model,1);
          
          % set parameter values
          eval.doSetParameters(params, xn);
          
          % make numeric
          eval.doSubsParameters(params, true);
          
          % check if stable
          if ~isStable(eval,plist('debug',false))
            loglk = inf;
            snr = 0;
            return
          end
          
          % do bode
          h(:,1)  = bode(eval, spl);
          
          for j = 1:noutChannels^2
            % spectra to variance
            % (N*fs/2)* this multiplication is done now in mcmc
            C(:,j) = noise(nnn).objs(j).data.getY;
          end
          
          % compute elements of inverse cross-spectrum matrix
          InvS11 = 1./C(:,1);
          
          
          % compute log-likelihood terms first, all at once does not cancel the
          % imag part when multiplying x.*conj(x)
          in1 = in(nnn).objs(1).data.getY;
          out1 = out(nnn).objs(1).data.getY;
          
          % matrix index convention: H(1,1)->h(1)  H(2,1)->h(2)  H(1,2)->h(3)  H(2,2)->h(4)
          v1v1 = conj(out1 - h.*in1).*(out1 - h.*in1);
          
          tmplt = h.*in1;
          
          %computing SNR
          snrexp = utils.math.stnr(tmplt,out1,InvS11);
          
          snr = snr + 20*log10(snrexp);
          
          log1exp = sum(InvS11.*v1v1);
          
          loglk = loglk + log1exp;
          
        elseif ((numel(in(1).objs) == 2) && numel(out(1).objs) == 2)
          
          freqs = noise(nnn).objs(1).data.getX;
          
          xn = double(xn);
          
          spl.pset('f', freqs);
          
          eval = model;
          eval.setA(Amats);
          eval.setB(Bmats);
          eval.setC(Cmats);
          eval.setD(Dmats);
          
          % set parameter values
          eval.doSetParameters(params, xn);
          
          % make numeric
          eval.doSubsParameters(params, true);
          
          % check if stable
          if ~isStable(eval,plist('debug',false))
            loglk = inf;
            snr = 0;
            return
          end
          
          % do bode
          [h1 h2 h3 h4]  = bode(eval, spl);
          
          clear C;
          for j = 1:noutChannels^2
            % spectra to variance
            % (N*fs/2)* this multiplication is done now in mcmc
            C(:,j) = noise(nnn).objs(j).data.getY;
          end
          
          % compute elements of inverse cross-spectrum matrix
          detm = (C(:,1).*C(:,4) - C(:,2).*C(:,3));
          InvS11 = C(:,4)./detm; %1 4
          InvS22 = C(:,1)./detm; %4 1
          InvS12 = C(:,2)./detm; %2 2
          InvS21 = C(:,3)./detm; %3 3
          
          % compute log-likelihood terms first, all at once does not cancel the
          % imag part when multiplying x.*conj(x)
          in1 = in(nnn).objs(1).data.getY;
          in2 = in(nnn).objs(2).data.getY;
          out1 = out(nnn).objs(1).data.getY;
          out2 = out(nnn).objs(2).data.getY;
          
          % matrix index convention: H(1,1)->h(1)  H(2,1)->h(2)  H(1,2)->h(3)  H(2,2)->h(4)
          v1v1 = conj(out1 - h1.*in1 - h3.*in2).*(out1 - h1.*in1 - h3.*in2);
          v2v2 = conj(out2 - h2.*in1 - h4.*in2).*(out2 - h2.*in1 - h4.*in2);
          v1v2 = conj(out1 - h1.*in1 - h3.*in2).*(out2 - h2.*in1 - h4.*in2);
          v2v1 = conj(out2 - h2.*in1 - h4.*in2).*(out1 - h1.*in1 - h3.*in2);
          
          tmplt1 = h1.*in1 + h3.*in2;
          tmplt2 = h2.*in1 + h4.*in2;
          
          %computing SNR
          snrexp = utils.math.stnr([tmplt1 tmplt2],[out1 out2],[InvS11 InvS22 InvS12 InvS21]);
          
          snr = snr + 20*log10(snrexp);
          
          log1exp = sum(InvS11.*v1v1 + InvS22.*v2v2 - InvS12.*v1v2 - InvS21.*v2v1);
          
          loglk = loglk + log1exp;
        else
          error('This method is only implemented for 1 input / 1 output model or for 2 inputs / 2 outputs models');
        end
        
        
        
      end
  end
end

