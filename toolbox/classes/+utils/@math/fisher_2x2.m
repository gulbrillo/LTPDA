%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute Fisher matrix
%
%  Parameters are:
%   i1        - input 1st channel (ao)
%   i2        - input 2nd channel (ao)
%   n         - noise both channels (matrix 2x1)
%   mdl       - model (matrix or ssm)
%   params    - parameters
%   numparams - numerical value of parameters
%   freqs     - frequnecies being evaluated
%   N         - number of fft frequencies
%   pl        - plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FisMat step]= fisher_2x2(i1,i2,S,mdl,params,numparams,freqs,N,fs,pl,inNames,outNames)

import utils.const.*

S11 = S(:,1);
S12 = S(:,3);
S22 = S(:,4);
S21 = S(:,2);

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
        dH12 = diff(h(3),params{i});  % taking into account matrix index convention h(2) > H(2,1)
        dH21 = diff(h(2),params{i});
        dH22 = diff(h(4),params{i});
        % evaluate
        d11(i) = eval(dH11);
        d12(i) = eval(dH12);
        d21(i) = eval(dH21);
        d22(i) = eval(dH22);
    end
    
elseif ~isempty(mdl) && all(strcmp(class(mdl),'ssm'))
    
    meval = copy(mdl,1);
    % set parameter values
    meval.doSetParameters(params, numparams);
    % get the differentiation step
    in_step = find(pl,'diffStep');
    if isa(in_step,'ao')
            step = in_step.y;
    else
            step = in_step;
    end
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
        step = utils.math.diffStepFish(fs,i1,i2,S11,S12,S21,S22,N,meval,params,ngrid,ranges,freqs,inNames,outNames);
    end
    
    % differentiate and eval
    for i = 1:length(params)
        utils.helper.msg(msg.IMPORTANT, ...
            sprintf('computing numerical differentiation with respect %s, Step:%4.2d ',params{i},step(i)), mfilename('class'), mfilename);
        % differentiate numerically
        dH = meval.parameterDiff(plist('names', params(i),'values',step(i)));
        % create plist with correct outNames (since parameterDiff change them)
        out1 = strrep(outNames{1},'.', sprintf('_DIFF_%s.',params{i})); % 2x2 case
        out2 =strrep(outNames{2},'.', sprintf('_DIFF_%s.',params{i}));
        % 'set', 'for bode', ...
        spl = plist(...
            'outputs', {out1,out2}, ...
            'inputs', inNames, ...
            'reorganize', true,...
            'f', freqs);
        % do bode
        d  = bode(dH, spl);
        % assign according matlab's matrix notation: H(1,1)->h(1)  H(2,1)->h(2)  H(1,2)->h(3)  H(2,2)->h(4)
        d11(i) = d.objs(1);
        d21(i) = d.objs(2);
        d12(i) = d.objs(3);
        d22(i) = d.objs(4);
    end
    
else
    error('### please introduce models for the transfer functions')
end

% scaling of PSD
% PSD = 2/(N*fs) * FFT *conj(FFT)
C11 = N*fs/2.*S11;
C22 = N*fs/2.*S22;
C12 = N*fs/2.*S12;
C21 = N*fs/2.*S21;

% compute elements of inverse cross-spectrum matrix
InvS11 = (C22./(C11.*C22 - C12.*C21));
InvS22 = (C11./(C11.*C22 - C12.*C21));
InvS12 = (C21./(C11.*C22 - C12.*C21));
InvS21 = (C12./(C11.*C22 - C12.*C21));

% compute Fisher Matrix (only upper triangle, it must be symmetric)
for i =1:length(params)
    for j =i:length(params)
        
        v1v1 = conj(d11(i).y.*i1 + d12(i).y.*i2).*(d11(j).y.*i1 + d12(j).y.*i2);
        v2v2 = conj(d21(i).y.*i1 + d22(i).y.*i2).*(d21(j).y.*i1 + d22(j).y.*i2);
        v1v2 = conj(d11(i).y.*i1 + d12(i).y.*i2).*(d21(j).y.*i1 + d22(j).y.*i2);
        v2v1 = conj(d21(i).y.*i1 + d22(i).y.*i2).*(d11(j).y.*i1 + d12(j).y.*i2);
        
        FisMat(i,j) = sum(real(InvS11.*v1v1 + InvS22.*v2v2 - InvS12.*v1v2 - InvS21.*v2v1));
    end
end

% fill lower triangle
for j =1:length(params)
    for i =j:length(params)
        FisMat(i,j) = FisMat(j,i);
    end
end


end