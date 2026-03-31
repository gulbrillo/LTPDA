% MCHNOISEGEN Generates multichannel noise data series given a model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    mchNoisegen generates multichannel noise data series given a
% mutichannel noise generating filter.
%
% DESCRIPTION:
%
%
% CALL:        out = mchNoisegen(mod, pl)
%
% INPUT:
%         mod: is a matrix containing a multichannel noise generating
%         filter aiming to generate colored noise from unitary variance
%         independent white data series. Each element of the multichannel
%         filter must be a parallel bank of filters as that produced by
%         matrix/mchNoisegenFilter or ao/Noisegen2D. The filter matrix must
%         be square.
%
% OUTPUT:
%         out: is a matrix containg a multichannel colored noise time
%         series which csd matrix is defined by mod'*mod.
%
% HISTORY:     19-10-2009 L Ferraioli
%              Creation
%
% ------------------------------------------------------------------------
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'mchNoisegen')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = mchNoisegen(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all ltpdauoh objects
  [mtxs, mtxs_invars] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  [pl, invars] = utils.helper.collect_objects(varargin(:), 'plist');
  
  inhists = mtxs.hist;
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  pl.getSetRandState();
  
  if numel(mtxs)>1 % the method work only with one matrix at the input
    error('### Please provide one matrix at the input.');
  end
  
  outm = copy(mtxs,nargout);
  
  % Get parameters and set params for fit
  Nsecs       = find_core(pl, 'nsecs');
  fs          = find_core(pl, 'fs');
  yunit       = find_core(pl, 'yunits');
  
  % total number of data in the series
  Ntot = round(Nsecs*fs);
  
  % chose case for input filter
  if isa(outm,'matrix') && isa(outm.objs(1),'filterbank')
    % discrete system
    sys = 'z';
    mfil = outm.objs;
    [nn,mm] = size(mfil);
    if nn~=mm
      error('!!! Filter matrix must be square')
    end
    % check if filter is a matrix built with noisegen2D
    fromnsg2D = false;
    if nn == 2
      nn11 = numel(mfil(1,1).filters);
      nn21 = numel(mfil(2,1).filters);
      if nn11 == nn21
        % get poles out of the filters
        pl11 = zeros(nn11,1);
        pl21 = zeros(nn21,1);
        for ii=1:nn11
          pl11(ii) = -1*mfil(1,1).filters(ii).b(2);
          pl21(ii) = -1*mfil(2,1).filters(ii).b(2);
        end
        % check if poles are equal that means they are produced with
        % noisegen2D
        if all((pl11-pl21)<eps)
          fromnsg2D = true;
        end
      end
    end
  elseif isa(outm,'matrix') && isa(outm.objs(1),'parfrac')
    % continuous system
    sys = 's';
    mfil = outm.objs;
    [nn,mm] = size(mfil);
    if nn~=mm
      error('!!! Filter matrix must be square')
    end
  else
    error('!!! Input filter must be a ''matrix'' of ''filterbank'' or ''parfrac'' objects.')
  end
  
  % init output
  out(nn,1) = ao;
  
  % switch between input filter type
  switch sys
    case 'z' % discrete input filters
      
      % init output data
      o = zeros(nn,Ntot);
      
      for zz=1:nn % moving along system dimension
        
        % extract residues and poles from input objects
        % run over matrix dimensions
        res = [];
        pls = [];
        filtsz = [];
        for jj=1:nn % collect filters coefficients along the columns zz
          bfil = mfil(jj,zz).filters;
          filtsz = [filtsz; numel(bfil)];
          for kk=1:numel(bfil)
            num = bfil(kk).a;
            den = bfil(kk).b;
            res = [res; num(1)];
            pls = [pls; -1*den(2)];
          end
        end
        
        % rescaling residues to get the correct result for univariate psd
        res = res.*sqrt(fs/2);
        
        
        %         Nrs = numel(res);
        %         % get covariance matrix
        %         R = zeros(Nrs);
        %         for aa=1:Nrs
        %           for bb=1:Nrs
        %             R(aa,bb) = (res(aa)*conj(res(bb)))/(1-pls(aa)*conj(pls(bb)));
        %           end
        %         end
        %
        %         % avoiding problems caused by roundoff errors
        %         HH = triu(R,0); % get upper triangular part of R
        %         HH1 = triu(R,1); % get upper triangular part of R above principal diagonal
        %         HH2 = HH1'; % do transpose conjugate
        %         R = HH + HH2; % reconstruct R in order to be really hermitian
        %
        %         % get singular value decomposition of R
        %         [U,S,V] = svd(R,0);
        %
        %         % conversion matrix
        %         A = V*sqrt(S);
        %
        %         % generate unitary variance gaussian random noise
        %         %ns = randn(Nrs,Ntot);
        %         ns = randn(Nrs,1);
        %
        %         % get correlated starting data points
        %         cns = A*ns;
        %
        %         % need to correct for roundoff errors
        %         % cleaning up results for numerical approximations
        %         idx = imag(pls(:,1))==0;
        %         cns(idx) = real(cns(idx));
        %
        %         % cleaning up results for numerical roundoff errors
        %         % states associated to complex conjugate poles must be complex
        %         % conjugate
        %         idxi = imag(pls(:,1))~=0;
        %         icns = cns(idxi);
        %         for jj = 1:2:numel(icns)
        %           icns(jj+1,1) = conj(icns(jj,1));
        %         end
        %         cns(idxi) = icns;
        
        cns = getinitz(res,pls,filtsz,fromnsg2D);
        
        y = zeros(sum(filtsz),2);
        rnoise = zeros(sum(filtsz),1);
        rns = randn(1,Ntot);
        %rns = utils.math.blwhitenoise(Ntot,fs,1/Nsecs,fs/2);
        %rns = rns.'; % willing to work with raw
        
        y(:,1) = cns;
        
        % start recurrence
        for xx = 2:Ntot+1
          rnoise(:,1) = rns(xx-1);
          y(:,2) = pls.*y(:,1) + res.*rnoise;
          idxr = 0;
          for kk=1:nn
            o(kk,xx-1) = o(kk,xx-1) + sum(y(idxr+1:idxr+filtsz(kk),2));
            idxr = idxr+filtsz(kk);
          end
          y(:,1) = y(:,2);
        end
        
      end
      
      clear rns
      
      % build output ao
      for dd=1:nn
        out(dd,1) = ao(tsdata(o(dd,:),fs));
        out(dd,1).setYunits(unit(yunit));
      end
      
      outm = matrix(out);
      
    case 's' % continuous input filters
      
      o = zeros(nn,Ntot);
      
      T = 1/fs; % sampling period
      
      for zz=1:nn % moving along system dimension
        
        % extract residues and poles from input objects
        % run over matrix dimensions
        res = [];
        pls = [];
        filtsz = [];
        for jj=1:nn % collect filters coefficients along the columns zz
          bfil = mfil(jj,zz);
          filtsz = [filtsz; numel(bfil.res)];
          res = [res; bfil.res];
          pls = [pls; bfil.poles];
        end
        
        % rescaling residues to get the correct result for univariate psd
        res = res.*sqrt(fs/2);
        
        Nrs = numel(res);
        
        % get covariance matrix for innovation
        Ri = zeros(Nrs);
        for aa=1:Nrs
          for bb=1:Nrs
            Ri(aa,bb) = (res(aa)*conj(res(bb)))*(exp((pls(aa) + conj(pls(bb)))*T)-1)/(pls(aa) + conj(pls(bb)));
          end
        end
        
        % avoiding problems caused by roundoff errors
        HH = triu(Ri,0); % get upper triangular part of R
        HH1 = triu(Ri,1); % get upper triangular part of R above principal diagonal
        HH2 = HH1'; % do transpose conjugate
        Ri = HH + HH2; % reconstruct R in order to be really hermitian
        
        % get singular value decomposition of R
        [Ui,Si,Vi] = svd(Ri,0);
        
        % conversion matrix for innovation
        Ai = Vi*sqrt(Si);
        
        % get covariance matrix for initial state
        Rx = zeros(Nrs);
        for aa=1:Nrs
          for bb=1:Nrs
            Rx(aa,bb) = -1*(res(aa)*conj(res(bb)))/(pls(aa) + conj(pls(bb)));
          end
        end
        
        % avoiding problems caused by roundoff errors
        HH = triu(Rx,0); % get upper triangular part of R
        HH1 = triu(Rx,1); % get upper triangular part of R above principal diagonal
        HH2 = HH1'; % do transpose conjugate
        Rx = HH + HH2; % reconstruct R in order to be really hermitian
        
        % get singular value decomposition of R
        [Ux,Sx,Vx] = svd(Rx,0);
        
        % conversion matrix for initial state
        Ax = Vx*sqrt(Sx);
        
        % generate unitary variance gaussian random noise
        %ns = randn(Nrs,Ntot);
        ns = randn(Nrs,1);
        
        % get correlated starting data points
        cns = Ax*ns;
        
        % need to correct for roundoff errors
        % cleaning up results for numerical approximations
        idx = imag(pls(:,1))==0;
        cns(idx) = real(cns(idx));
        
        % cleaning up results for numerical roundoff errors
        % states associated to complex conjugate poles must be complex
        % conjugate
        idxi = imag(pls(:,1))~=0;
        icns = cns(idxi);
        for jj = 1:2:numel(icns)
          icns(jj+1,1) = conj(icns(jj,1));
        end
        cns(idxi) = icns;
        
        y = zeros(sum(filtsz),2);
        rnoise = zeros(sum(filtsz),1);
        rns = randn(1,Ntot);
        %rns = utils.math.blwhitenoise(Ntot,fs,1/Nsecs,fs/2);
        %rns = rns.'; % willing to work with raw
        
        y(:,1) = cns;
        
        % start recurrence
        for xx = 2:Ntot+1
          %           innov = Ai*randn(sum(filtsz),1);
          rnoise(:,1) = rns(xx-1);
          innov = Ai*rnoise;
          % need to correct for roundoff errors
          % cleaning up results for numerical approximations
          innov(idx) = real(innov(idx));
          
          % cleaning up results for numerical roundoff errors
          % states associated to complex conjugate poles must be complex
          % conjugate
          iinnov = innov(idxi);
          for jj = 1:2:numel(iinnov)
            iinnov(jj+1,1) = conj(iinnov(jj,1));
          end
          innov(idxi) = iinnov;
          
          y(:,2) = diag(exp(pls.*T))*y(:,1) + innov;
          
          idxr = 0;
          for kk=1:nn
            o(kk,xx-1) = o(kk,xx-1) + sum(y(idxr+1:idxr+filtsz(kk),2));
            idxr = idxr+filtsz(kk);
          end
          y(:,1) = y(:,2);
        end
        
      end
      
      %       clear rns
      
      % build output ao
      for dd=1:nn
        out(dd,1) = ao(tsdata(o(dd,:),fs));
        out(dd,1).setYunits(unit(yunit));
      end
      
      outm = matrix(out);
      
  end
  
  outm.addHistory(getInfo('None'), pl, [mtxs_invars(:)], [inhists(:)]);
  
  % set output
  varargout{1} = outm;
  
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setArgsmin(1);
  ii.setOutmin(1);
  ii.setOutmax(1);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  pl = plist();
  
  % Nsecs
  p = param({'nsecs', 'Number of seconds in the desired noise data series.'}, {1, {1}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Fs
  p = param({'fs', 'The sampling frequency of the noise data series.'}, {1, {1}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Yunits
  p = param({'yunits','Unit on Y axis.'},  paramValue.STRING_VALUE(''));
  pl.append(p);
  
  % RAND_STREAM
  pl.append(copy(plist.RAND_STREAM, 1));
  
end

%--------------------------------------------------------------------------
% Local function
% Estimate init values for the z domain case
%--------------------------------------------------------------------------
function cns = getinitz(res,pls,filtsz,fromnsg2D)
  
  if fromnsg2D % init in the case of filters produced with noisegen2D
    % divide in 2 the problem
    res1 = res(1:filtsz(1));
    res2 = res(filtsz(1)+1:filtsz(2));
    pls1 = pls(1:filtsz(1));
    pls2 = pls(filtsz(1)+1:filtsz(2));
    
    %%% the first series %%%
    Nrs = numel(res1);
    % get covariance matrix
    R = zeros(Nrs);
    for aa=1:Nrs
      for bb=1:Nrs
        R(aa,bb) = (res1(aa)*conj(res1(bb)))/(1-pls1(aa)*conj(pls1(bb)));
      end
    end
    
    % avoiding problems caused by roundoff errors
    HH = triu(R,0); % get upper triangular part of R
    HH1 = triu(R,1); % get upper triangular part of R above principal diagonal
    HH2 = HH1'; % do transpose conjugate
    R = HH + HH2; % reconstruct R in order to be really hermitian
    
    % get singular value decomposition of R
    [U,S,V] = svd(R,0);
    
    % conversion matrix
    A = V*sqrt(S);
    
    % generate unitary variance gaussian random noise
    %ns = randn(Nrs,Ntot);
    ns = randn(Nrs,1);
    
    % get correlated starting data points
    cns1 = A*ns;
    
    % need to correct for roundoff errors
    % cleaning up results for numerical approximations
    idx = imag(pls1(:,1))==0;
    cns1(idx) = real(cns1(idx));
    
    % cleaning up results for numerical roundoff errors
    % states associated to complex conjugate poles must be complex
    % conjugate
    idxi = imag(pls1(:,1))~=0;
    icns1 = cns1(idxi);
    for jj = 1:2:numel(icns1)
      icns1(jj+1,1) = conj(icns1(jj,1));
    end
    cns1(idxi) = icns1;
    
    %%% the second series %%%
    Nrs = numel(res2);
    % get covariance matrix
    R = zeros(Nrs);
    for aa=1:Nrs
      for bb=1:Nrs
        R(aa,bb) = (res2(aa)*conj(res2(bb)))/(1-pls2(aa)*conj(pls2(bb)));
      end
    end
    
    % avoiding problems caused by roundoff errors
    HH = triu(R,0); % get upper triangular part of R
    HH1 = triu(R,1); % get upper triangular part of R above principal diagonal
    HH2 = HH1'; % do transpose conjugate
    R = HH + HH2; % reconstruct R in order to be really hermitian
    
    % get singular value decomposition of R
    [U,S,V] = svd(R,0);
    
    % conversion matrix
    A = V*sqrt(S);
    
    % generate unitary variance gaussian random noise
    %ns = randn(Nrs,Ntot);
    ns = randn(Nrs,1);
    
    % get correlated starting data points
    cns2 = A*ns;
    
    % need to correct for roundoff errors
    % cleaning up results for numerical approximations
    idx = imag(pls2(:,1))==0;
    cns2(idx) = real(cns2(idx));
    
    % cleaning up results for numerical roundoff errors
    % states associated to complex conjugate poles must be complex
    % conjugate
    idxi = imag(pls2(:,1))~=0;
    icns2 = cns2(idxi);
    for jj = 1:2:numel(icns2)
      icns2(jj+1,1) = conj(icns2(jj,1));
    end
    cns2(idxi) = icns2;
    
    %%% combine results %%%
    cns = [cns1;cns2];
    
  else % init in the case of filters produced with matrix constructor
    
    Nrs = numel(res);
    % get covariance matrix
    R = zeros(Nrs);
    for aa=1:Nrs
      for bb=1:Nrs
        R(aa,bb) = (res(aa)*conj(res(bb)))/(1-pls(aa)*conj(pls(bb)));
      end
    end
    
    % avoiding problems caused by roundoff errors
    HH = triu(R,0); % get upper triangular part of R
    HH1 = triu(R,1); % get upper triangular part of R above principal diagonal
    HH2 = HH1'; % do transpose conjugate
    R = HH + HH2; % reconstruct R in order to be really hermitian
    
    % get singular value decomposition of R
    [U,S,V] = svd(R,0);
    
    % conversion matrix
    A = V*sqrt(S);
    
    % generate unitary variance gaussian random noise
    %ns = randn(Nrs,Ntot);
    ns = randn(Nrs,1);
    
    % get correlated starting data points
    cns = A*ns;
    
    % need to correct for roundoff errors
    % cleaning up results for numerical approximations
    idx = imag(pls(:,1))==0;
    cns(idx) = real(cns(idx));
    
    % cleaning up results for numerical roundoff errors
    % states associated to complex conjugate poles must be complex
    % conjugate
    idxi = imag(pls(:,1))~=0;
    icns = cns(idxi);
    for jj = 1:2:numel(icns)
      icns(jj+1,1) = conj(icns(jj,1));
    end
    cns(idxi) = icns;
    
  end
  
end
