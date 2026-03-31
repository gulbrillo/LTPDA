%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Look for differentiation step for a given parameter and
%
%  Parameters are:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function best = diffStepFish_1x1(fs,i1,S11,N,meval,params,numparams,ngrid,ranges,freqs,inNames,outNames)

import utils.const.*

% remove aux file if existing
if exist('diffStepFish.txt') == 2
    ! rm diffStepFish.txt
end

step = ones(ngrid,numel(params));

% initialize matrix of steps
for ii = 1:numel(params)
    step(:,ii) = ranges(1)*numparams(ii);
end

% step(:,1) = logspace(ranges(1,1),ranges(2,1),ngrid);

for kk = 1:length(params)
    step(:,kk) = numparams(kk)*logspace(log10(ranges(1)),log10(ranges(2)),ngrid);
    Rmat = [];
    for jj = 1:ngrid
        for ii = 1:length(params)
            % differentiate numerically
            dH = meval.parameterDiff(plist('names', params(ii),'values',step(jj,ii)));
            % create plist with correct outNames (since parameterDiff change them)
            out1 = strrep(outNames{1},'.', sprintf('_DIFF_%s.',params{ii})); % 2x2 case
            spl = plist(...
                'outputs', {out1}, ...
                'inputs', inNames, ...
                'reorganize', true,...
                'f', freqs);
            % do bode
            d  = bode(dH, spl);
            % assign according matlab's matrix notation:
            % H(1,1)->h(1)  H(2,1)->h(2)  H(1,2)->h(3)  H(2,2)->h(4)
            d11(ii) = d.objs(1);
        end
        
        % scaling of PSD
        % PSD = 2/(N*fs) * FFT *conj(FFT)
        C11 = N*fs/2.*S11;
        
        % compute elements of inverse cross-spectrum matrix
        InvS11 = 1./C11;
        
        % compute Fisher Matrix
        for i =1:length(params)
            for j =1:length(params)
                
                v1v1 = conj(d11(i).y.*i1).*(d11(j).y.*i1);
                FisMat(i,j) = sum(real(InvS11.*v1v1));
            end
        end
        
        detFisMat = det(FisMat);
        R = [step(jj,:) detFisMat];
        % only file diffStepFish.txt stores all iterations. Rmat is
        % initialized for each loop
        save('diffStepFish.txt','R','-ascii','-append');
        Rmat = [Rmat; R];
    end
    
    % look for the stable step: compute diff and
    % look for the smallest one in absolute value
    % The smallest slope marks the plateau
    diffDetFisMat = abs(diff(Rmat(:,end)));
    lowdet = diffDetFisMat(1);
    ind = 2;
    for k = 1:numel(diffDetFisMat)
        if diffDetFisMat(k) < lowdet
            lowdet = diffDetFisMat(k);
            ind = k+1; % index give by diff = x(2) - x(1). We take the step corresponding to x(2)
        end
    end
    % display message
    utils.helper.msg(msg.IMPORTANT, ...
        sprintf('Best numerical diff. step with respect %s: %d',params{kk}, step(ind,kk)), mfilename('class'), mfilename);
    % reassing all current column to the best step
    step(:,kk) = step(ind,kk)*ones(ngrid,1);
    
    figure
    diffDetFisMat(diffDetFisMat == 0) = 1e-20; % to avoid zeros in loglog plot
    loglog(Rmat(1:end-1,kk)/numparams(kk),diffDetFisMat,'--ks','LineWidth',2,'MarkerSize',10)
    title(sprintf('Parameter: %s',params{kk}))
    ylabel('\Delta FisMat / \Delta\theta')
    xlabel('Normalised \Delta\theta')
    
end
best = step(1,:);
end

