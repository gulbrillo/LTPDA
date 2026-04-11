%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute log-likelihood
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [loglk snr]= loglikelihood_matrix(xn,in,out,noise,model,params,inModel,outModel)
% parameters
fs = in(1).objs(1).fs;

% num. experiments
nexp = numel(in);
% num. transfer functions
nmod = numel(model(1).objs(:));
noutChannels = sqrt(numel(noise(1).objs));

% loop over experiments
loglk = 0;
snr = 0;
for i = 1:nexp
    if ((numel(in(1).objs) == 1) && numel(out(1).objs) == 1)
        
        freqs = in(i).objs(1).data.getX;
        % evaluate models
        if(isempty(outModel))
            h11 = model(1).objs(1).setParams(params,xn).double;
        elseif (~isempty(outModel))
            h11 = outModel(1,1).y * model(1).getObjectAtIndex(1,1).setParams(params,xn).double';
        end
    
        % spectra to variance
        % (N*fs/2)* this multiplication is done now in mcmc
        C11 = noise(1).objs(1).data.getY;
    
        % compute elements of inverse cross-spectrum matrix
        InvS11 = 1./C11;
    
        % compute log-likelihood terms first, all at once does not cancel the
        % imag part when multiplying x.*conj(x)
        in1 = in(i).objs(1).data.getY;
        out1 = out(i).objs(1).data.getY;
        
        tmplt1 = h11.*in1;
        
        v1v1 = conj(out1 - tmplt1).*(out1 - tmplt1);
    
        %computing SNR
        snrexp = utils.math.stnr(tmplt1,out1,InvS11);
    
        snr = snr + 20*log10(snrexp); 
          
        log1exp = sum(InvS11.*v1v1);
        
        loglk = loglk + log1exp;
        
    elseif ((numel(in(1).objs) == 2) && numel(out(1).objs) == 2)
        freqs = in(i).objs(1).data.getX;
        % loop over models
        
        if(isempty(outModel))
            for j = 1:nmod
                % evaluate models
                h(:,j) = model.objs(j).setParams(params,xn).double;
            end
        elseif (~isempty(outModel))
            h(:,1) = outModel(1,1).y * model.getObjectAtIndex(1,1).setParams(params,xn).double';
            h(:,2) = outModel(2,1).y * model.getObjectAtIndex(1,1).setParams(params,xn).double';
            h(:,3) = outModel(1,2).y * model.getObjectAtIndex(2,2).setParams(params,xn).double';
            h(:,4) = outModel(2,2).y * model.getObjectAtIndex(2,2).setParams(params,xn).double';
        end
        
        for j = 1:noutChannels^2
            % spectra to variance
            % (N*fs/2)* this multiplication is done now in mcmc
            C(:,j) = noise(i).objs(j).data.getY;
        end
        
        % compute elements of inverse cross-spectrum matrix
        detm = (C(:,1).*C(:,4) - C(:,2).*C(:,3));
        InvS11 = C(:,4)./detm; %1 4
        InvS22 = C(:,1)./detm; %4 1
        InvS12 = C(:,2)./detm; %2 2
        InvS21 = C(:,3)./detm; %3 3
        
        % compute log-likelihood terms first, all at once does not cancel the
        % imag part when multiplying x.*conj(x)
        in1 = in(i).objs(1).data.getY;
        in2 = in(i).objs(2).data.getY;
        out1 = out(i).objs(1).data.getY;
        out2 = out(i).objs(2).data.getY;
        
        tmplt1 = h(:,1).*in1 + h(:,3).*in2;
        tmplt2 = h(:,2).*in1 + h(:,4).*in2;
        
        % matrix index convention: H(1,1)->h(1)  H(2,1)->h(2)  H(1,2)->h(3)  H(2,2)->h(4)
        v1v1 = conj(out1 - tmplt1).*(out1 - tmplt1);
        v2v2 = conj(out2 - tmplt2).*(out2 - tmplt2);
        v1v2 = conj(out1 - tmplt1).*(out2 - tmplt2);
        v2v1 = conj(out2 - tmplt2).*(out1 - tmplt1);
        
        %computing SNR
        snrexp = utils.math.stnr([tmplt1 tmplt2],[out1 out2],[InvS11 InvS22 InvS12 InvS21]);
        
        snr = snr + 20*log10(snrexp); 
        
        log1exp = sum(InvS11.*v1v1 + InvS22.*v2v2 - InvS12.*v2v1 - InvS21.*v1v2);
        
        loglk = loglk + log1exp;
        
    elseif ((numel(in(1).objs) == 4) && numel(out(1).objs) == 3)
        % here we are implementing only the magnetic case
        % We have 4 inputs (the 4 conformator waveforms of the magnetic
        % analysis and
        % 3 outputs (that correspond to the IFO.x12 and IFO.ETA1 and
        % IFO.PHI1
        
        
        for j = 1:noutChannels^2
            % spectra to variance
            
            % (N*fs/2)*   this factor multiplication is done now in mcmc,
            % before splitting
            C(:,j) = noise(i).objs(j).data.getY;
        end
        if( isempty(inModel) && ~isempty(outModel))
            
            freqs = in(i).objs(1).data.getX;
            
            % faster this way
            h(:,1) = outModel(1,1).y * model.getObjectAtIndex(1,1).setParams(params,xn).double;
            h(:,2) = outModel(2,1).y * model.getObjectAtIndex(1,1).setParams(params,xn).double;
            h(:,3) = outModel(3,1).y * model.getObjectAtIndex(1,1).setParams(params,xn).double;
            h(:,4) = outModel(1,1).y * model.getObjectAtIndex(1,2).setParams(params,xn).double;
            h(:,5) = outModel(2,1).y * model.getObjectAtIndex(1,2).setParams(params,xn).double;
            h(:,6) = outModel(3,1).y * model.getObjectAtIndex(1,2).setParams(params,xn).double;
            h(:,7) = outModel(1,2).y * model.getObjectAtIndex(2,3).setParams(params,xn).double;
            h(:,8) = outModel(2,2).y * model.getObjectAtIndex(2,3).setParams(params,xn).double;
            h(:,9) = outModel(3,2).y * model.getObjectAtIndex(2,3).setParams(params,xn).double;
            h(:,10) = outModel(1,3).y * model.getObjectAtIndex(3,4).setParams(params,xn).double;
            h(:,11) = outModel(2,3).y * model.getObjectAtIndex(3,4).setParams(params,xn).double;
            h(:,12) = outModel(3,3).y * model.getObjectAtIndex(3,4).setParams(params,xn).double;
            
            
            % compute elements of inverse cross-spectrum matrix
            detm = (C(:,1).*C(:,5).*C(:,9) + ...
                C(:,2).*C(:,6).*C(:,7) + ...
                C(:,3).*C(:,4).*C(:,8) -...
                C(:,7).*C(:,5).*C(:,3) -...
                C(:,8).*C(:,6).*C(:,1) -...
                C(:,9).*C(:,4).*C(:,2));
            
            
            InvS11 = (C(:,5).*C(:,9) - C(:,8).*C(:,6))./detm;
            InvS12 = -(C(:,4).*C(:,9) - C(:,7).*C(:,6))./detm;
            InvS13 = (C(:,4).*C(:,8) - C(:,7).*C(:,5))./detm;
            InvS21 = -(C(:,2).*C(:,9) - C(:,8).*C(:,3))./detm;
            InvS22 = (C(:,1).*C(:,9) - C(:,7).*C(:,3))./detm;
            InvS23 = -(C(:,1).*C(:,8) - C(:,7).*C(:,2))./detm;
            InvS31 = (C(:,2).*C(:,6) - C(:,5).*C(:,3))./detm;
            InvS32 = -(C(:,1).*C(:,6) - C(:,4).*C(:,3))./detm;
            InvS33 = (C(:,1).*C(:,5) - C(:,4).*C(:,2))./detm;
            
            % compute log-likelihood terms first, all at once does not cancel the
            % imag part when multiplying x.*conj(x)
            for ll = 1:noutChannels
                outV(:,ll) = out(i).objs(ll).data.getY;
            end
            for kk = 1:model.ncols
                inV(:,kk) = in(i).objs(kk).data.getY;
            end
            
            % faster this way
            v(:,1) = outV(:,1) - h(:,1).*inV(:,1) - h(:,4).*inV(:,2) - h(:,7).*inV(:,3) - h(:,10).*inV(:,4);
            v(:,2) = outV(:,2) - h(:,2).*inV(:,1) - h(:,5).*inV(:,2) - h(:,8).*inV(:,3) - h(:,11).*inV(:,4);
            v(:,3) = outV(:,3) - h(:,3).*inV(:,1) - h(:,6).*inV(:,2) - h(:,9).*inV(:,3) - h(:,12).*inV(:,4);
            
            v1v1 = conj(v(:,1)).*v(:,1);
            v1v2 = conj(v(:,1)).*v(:,2);
            v1v3 = conj(v(:,1)).*v(:,3);
            v2v1 = conj(v(:,2)).*v(:,1);
            v2v2 = conj(v(:,2)).*v(:,2);
            v2v3 = conj(v(:,2)).*v(:,3);
            v3v1 = conj(v(:,3)).*v(:,1);
            v3v2 = conj(v(:,3)).*v(:,2);
            v3v3 = conj(v(:,3)).*v(:,3);
            
            log1exp = sum(InvS11.*v1v1 +...
                InvS12.*v1v2 +...
                InvS13.*v1v3 +...
                InvS21.*v2v1 +...
                InvS22.*v2v2 +...
                InvS23.*v2v3 +...
                InvS31.*v3v1 +...
                InvS32.*v3v2 +...
                InvS33.*v3v3);
            
            loglk = loglk + log1exp;
            
            
        else
            error('For the magnetic case, implement an outModel and leave your inModel blank')
        end
        
    else
        error('Implemented cases: 1 input / 1output, 2 inputs / 2outputs (TN3045 analysis), and 4 inputs / 3 outpus (magnetic complete analysis model. Other cases have not been implemented yet. Sorry for the inconvenience)');
    end
    
end
end

