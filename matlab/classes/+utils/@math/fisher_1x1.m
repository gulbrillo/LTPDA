%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute Fisher matrix
%
%  Parameters are:
%   i1        - input 1st channel (ao)
%   n         - noise both channels (matrix 1x1)
%   mdl       - model (matrix or ssm)
%   params    - parameters
%   numparams - numerical value of parameters
%   freqs     - frequnecies being evaluated
%   N         - number of fft frequencies
%   pl        - plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FisMat step] = fisher_1x1(i1,S11,mdl,params,numparams,freqs,N,fs,pl,inNames,outNames)

import utils.const.*

if ~isempty(mdl) && all(strcmp(class(mdl),'matrix'))
    % compute built-in matrix
    for i = 1:numel(mdl.objs)
        % set Xvals
        h(i) = mdl.getObjectAtIndex(i).setXvals(freqs);
        % set alias
        h(i).assignalias(mdl.objs(i),plist('xvals',freqs));
        % set paramaters
        h(i).setParams(params,numparams);
    end
    % differentiate and eval
    for i = 1:length(params)
        utils.helper.msg(msg.IMPORTANT, sprintf('computing symbolic differentiation with respect %s',params{i}), mfilename('class'), mfilename);
        % differentiate symbolically
        dH11 = diff(h(1),params{i});
        % evaluate
        d11(i) = eval(dH11);
    end
    
elseif ~isempty(mdl) && all(strcmp(class(mdl),'ssm'))
    
    meval = copy(mdl,1);
    % set parameter values
%     meval.doSetParameters(params, numparams);
    meval.setParameters(params, numparams);

    % get the differentiation step
    step = find(pl,'diffstep');
    % case no diff. step introduced
    if isempty(step)
        utils.helper.msg(msg.IMPORTANT, ...
            sprintf('computing optimal differentiation steps'), mfilename('class'), mfilename);
        ranges = find(pl,'stepRanges');
        if isempty(ranges)
            error('### Please input upper and lower ranges for the parameters: ''ranges''')
        end
        ngrid = find(pl,'ngrid');
        if isempty(ngrid)
            error('### Please input a number of points for the grid to compute the diff. step : ''ngrid''')
        end
        % look for numerical differentiation step
        step = utils.math.diffStepFish_1x1(fs,i1,S11,N,meval,params,numparams,ngrid,ranges,freqs,inNames,outNames);
    end
    
    % differentiate and eval
    for i = 1:length(params)
        utils.helper.msg(msg.IMPORTANT, ...
            sprintf('computing numerical differentiation with respect %s, Step:%4.2d ',params{i},step(i)), mfilename('class'), mfilename);
        % differentiate numerically
        dH = meval.parameterDiff(plist('names', params(i),'values',step(i)));
        % create plist with correct outNames (since parameterDiff change them)
        out1 = strrep(outNames{1},'.', sprintf('_DIFF_%s.',params{i})); % 2x2 case
        spl = plist(...
            'outputs', out1, ...
            'inputs', inNames, ...
            'reorganize', true,...
            'f', freqs);
        % do bode
        d  = bode(dH, spl);
        % assign according matlab's matrix notation: H(1,1)->h(1)  H(2,1)->h(2)  H(1,2)->h(3)  H(2,2)->h(4)
        d11(i) = d.objs(1);
    end
    
else
    error('### please introduce models for the transfer functions')
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

end