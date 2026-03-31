% CRBOUND computes the inverse of the Fisher Matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CRBOUND computes the Cramer-Rao lowe bound for parametric
%              model given the input signals and the noise. The method
%              accepts 2D (2 input/2 output) models and 1D models
%              (1 input/1 output) and (2 input/1 output)
%
% CALL:        bs = crbound(in,noise,pl)
%
% INPUTS:      in      - analysis objects with input signals to the system
%                        (x1) if 1 input 
%                        (x2) if 2 input 
%              noise   - analysis objects with measured noise 
%                        (x1) if 1 input: S11 
%                        (x4) if 2 input: (S11,S12,S21,S22) 
%              model   - symbolic model (smodel) containing the evaluated
%                        transfer function models
%                        (x1) if 1 input/1 output
%                        (x2) if 2 input/1 output
%                        (x4) if 2 input/2 output
%              pl      - parameter list
%
% OUTPUTS:     bs   - covariance matrix AO
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'crbound')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = crbound(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### crbound cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs smodels and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % get params
  params = find_core(pl,'params');
  numparams = find_core(pl,'paramsValues');
  mdl2 = find_core(pl,'models');
  bmdl = find_core(pl,'built-in');
  f1 = find_core(pl,'f1');
  f2 = find_core(pl,'f2');
  freqs = find_core(pl,'frequencies');
  pseudoinv = find_core(pl,'pinv');
  tol = find_core(pl,'tol');
  %   ninputs = find_core(pl,'Ninputs');
  
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  if ~isempty(mdl2)
    mdl = copy(mdl2, nargout);
  end
  
  if numel(bs) == 2
    % implementing here for 1D
    in(1) = bs(1);
    n(1) = bs(2);
    
    
    
    % fft
    i1 = fft(in(1));
    Nsamples = length(i1.x);
    if ~isempty(f1) &&  ~isempty(f2)
      i1 = split(i1,plist('frequencies',[f1 f2]));
    elseif ~isempty(freqs)
      i1 = split(i1,plist('frequencies',freqs));
      i1 = join(i1);
    end
    
    % get frequency vector
    f = i1.x;
    
    if ~isempty(mdl)
      % get model
      h(1) = mdl;
      h(1).setXvals(f);
    else
      error('### One model should be introduced, please check the help.')
    end
    
  elseif numel(bs) == 3
    if numel(mdl) == 2
      in(1) = bs(1);
      in(2) = bs(2);
      n(1) = bs(3);
      
      % fft
      i1 = fft(in(1));
      Nsamples = length(i1.x);
      i2 = fft(in(2));
      
      % Get rid of fft f =0, reduce frequency range if needed
      if ~isempty(f1) &&  ~isempty(f2)
        i1 = split(i1,plist('frequencies',[f1 f2]));
        i2 = split(i2,plist('frequencies',[f1 f2]));
      elseif ~isempty(freqs)
        i1 = split(i1,plist('frequencies',freqs));
        i1 = join(i1);
        i2 = split(i2,plist('frequencies',freqs));
        i2 = join(i2);
      end
      
      % get frequency vector
      f = i1.x;
      
      if ~isempty(mdl)
        % compute built-in matrix
        h(1) = mdl(1);
        h(1).setXvals(f);
        h(2) = mdl(2);
        h(2).setXvals(f);
      else
        error('### One model should be introduced, please check the help.')
      end
    elseif numel(mdl) == 1
      error('Check the model or use crbound with the matrix class')
    end
    % Get input objects
  elseif numel(bs) == 4
    in(1) = bs(1);
    in(2) = bs(2);
    n(1) = bs(3);
    n(2) = bs(4);
    
    % fft
    i1 = fft(in(1));
    Nsamples = length(i1.x);
    i2 = fft(in(2));
    
    % Get rid of fft f =0, reduce frequency range if needed
    if ~isempty(f1) &&  ~isempty(f2)
      i1 = split(i1,plist('frequencies',[f1 f2]));
      i2 = split(i2,plist('frequencies',[f1 f2]));
    elseif ~isempty(freqs)
      i1 = split(i1,plist('frequencies',freqs));
      i1 = join(i1);
      i2 = split(i2,plist('frequencies',freqs));
      i2 = join(i2);
    end
    
    % get frequency vector
    f = i1.x;
    
    if ~isempty(bmdl)
      % compute built-in smodels
      for i = 1:4
        if strcmp(bmdl{i},'0');
          h(i) = smodel('0');
          h(i).setXvar('f');
          h(i).setXvals(f);
        else
          h(i) = smodel(plist('built-in',bmdl{i},'f',f));
          % set all params to all models. It is not true but harmless
          for k = 1:numel(params)
            vecparams(k) = {numparams(k)*ones(size(f))};
          end
          h(i).setParams(params,vecparams);
        end
      end
    elseif ~isempty(mdl)
      % compute built-in matrix
      h(1) = mdl{1};
      h(1).setXvals(f);
      h(2) = mdl{2};
      h(2).setXvals(f);
      h(3) = mdl{3};
      h(3).setXvals(f);
      h(4) = mdl{4};
      h(4).setXvals(f);
    end
    
  else
    error('### The number of input in crbound objects is not correct, please check the help.')
  end
  
  % Set params
  for i = 1:numel(h)
    h(i).setParams(params,numparams);
  end
  
  if numel(bs) == 2
    % Compute psd
    n1  = psd(n(1), pl);
    
    % interpolate to fft frequencies
    S11 = interp(n1,plist('vertices',f));
    
    for i = 1:length(params)
      utils.helper.msg(msg.IMPORTANT, sprintf('computing symbolic differentiation with respect %s',params{i}), mfilename('class'), mfilename);
      % differentiate symbolically
      dH11 = diff(h(1),params{i});
      % evaluate
      d11(i) = eval(dH11);
    end
    
    % get some parameters used below
    fs = S11.fs;
%     N = len(S11);
    Navs = find_core(pl,'Navs');
    
    % scaling of PSD
    % PSD = 2/(N*fs) * FFT *conj(FFT)
    C11 = Nsamples*fs/2.*S11.y;

    InvS11 = 1./C11;

    % compute Fisher Matrix
    for i =1:length(params)
      for j =1:length(params)
        v1v1 = conj(d11(i).y.*i1.y).*(d11(j).y.*i1.y);

        FisMat(i,j) = sum(real(InvS11.*v1v1));
      end
    end
    
  elseif numel(bs) == 3
  
    if numel(mdl) == 2
      % Compute psd
      n1  = psd(n(1), pl);
      
      % interpolate to fft frequencies
      S11 = interp(n1,plist('vertices',f));
      
      for i = 1:length(params)
        utils.helper.msg(msg.IMPORTANT, sprintf('computing symbolic differentiation with respect %s',params{i}), mfilename('class'), mfilename);
        % differentiate symbolically
        dH11 = diff(h(1),params{i});
        dH12 = diff(h(2),params{i});
        
        % evaluate
        d11(i) = eval(dH11);
        d12(i) = eval(dH12);    
      end
      
      % get some parameters used below
      fs = S11.fs;
%       N = len(S11);
      Navs = find_core(pl,'Navs');
      
      % scaling of PSD
      % PSD = 2/(N*fs) * FFT *conj(FFT)
      C11 = Nsamples*fs/2.*S11.y;
      
      % compute elements of inverse cross-spectrum matrix
      InvS11 = 1./C11;
      
      % compute Fisher Matrix
      for i =1:length(params)
        for j =1:length(params)
          v1v1 = conj(d11(i).y.*i1.y + d12(i).y.*i2.y).*(d11(j).y.*i1.y + d12(j).y.*i2.y);
          
          FisMat(i,j) = sum(real(InvS11.*v1v1));
        end
      end
      
    elseif numel(mdl) == 1
      error('Please check model sizes')
    end
    
    
  elseif numel(bs) == 4
    
    % Compute psd
    n1  = psd(n(1), pl);
    n2  = psd(n(2), pl);
    n12 = cpsd(n(1),n(2), pl);
    
    % interpolate to fft frequencies
    S11 = interp(n1,plist('vertices',f));
    S12 = interp(n12,plist('vertices',f));
    S22 = interp(n2,plist('vertices',f));
    S21 = conj(S12);
    
    for i = 1:length(params)
      utils.helper.msg(msg.IMPORTANT, sprintf('computing symbolic differentiation with respect %s',params{i}), mfilename('class'), mfilename);
      % differentiate symbolically
      dH11 = diff(h(1),params{i});
      dH12 = diff(h(2),params{i});
      dH21 = diff(h(3),params{i});
      dH22 = diff(h(4),params{i});
      % evaluate
      d11(i) = eval(dH11);
      d12(i) = eval(dH12);
      d21(i) = eval(dH21);
      d22(i) = eval(dH22);
    end
    
    % get some parameters used below
    fs = S11.fs;
%     N = len(S11);
    Navs = find_core(pl,'Navs');
    
    % scaling of PSD
    % PSD = 2/(N*fs) * FFT *conj(FFT)
    C11 = Nsamples*fs/2.*S11.y;
    C22 = Nsamples*fs/2.*S22.y;
    C12 = Nsamples*fs/2.*S12.y;
    C21 = Nsamples*fs/2.*S21.y;
    
    % compute elements of inverse cross-spectrum matrix
    InvS11 = (C22./(C11.*C22 - C12.*C21));
    InvS22 = (C11./(C11.*C22 - C12.*C21));
    InvS12 = (C21./(C11.*C22 - C12.*C21));
    InvS21 = (C12./(C11.*C22 - C12.*C21));
    
    % compute Fisher Matrix
    for i =1:length(params)
      for j =1:length(params)
        
        v1v1 = conj(d11(i).y.*i1.y + d12(i).y.*i2.y).*(d11(j).y.*i1.y + d12(j).y.*i2.y);
        v2v2 = conj(d21(i).y.*i1.y + d22(i).y.*i2.y).*(d21(j).y.*i1.y + d22(j).y.*i2.y);
        v1v2 = conj(d11(i).y.*i1.y + d12(i).y.*i2.y).*(d21(j).y.*i1.y + d22(j).y.*i2.y);
        v2v1 = conj(d21(i).y.*i1.y + d22(i).y.*i2.y).*(d11(j).y.*i1.y + d12(j).y.*i2.y);
        
        FisMat(i,j) = sum(real(InvS11.*v1v1 + InvS22.*v2v2 - InvS12.*v1v2 - InvS21.*v2v1));
      end
    end
    
  end
  
  % inverse is the optimal covariance matrix
  if pseudoinv && isempty(tol)
    cov = pinv(FisMat);
  elseif pseudoinv
    cov = pinv(FisMat,tol);
  else
    cov = FisMat\eye(size(FisMat));
  end
  
  % create AO
  out = ao(cov);
  % Fisher Matrix in the procinfo
  out.setProcinfo(plist('FisMat',FisMat));
  
  varargout{1} = out;
end


%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls  = [];
  else
    sets = {'Default'};
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
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
  pl = copy(plist.WELCH_PLIST,1);
  pset(pl,'Navs',1);
  
  p = plist({'params', 'Parameters of the model'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = plist({'models','Symbolic models of the system'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = plist({'frequencies','Array of start/sop frequencies where the analysis is performed'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = plist({'pinv','Use the Penrose-Moore pseudoinverse'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = plist({'tol','Tolerance for the Penrose-Moore pseudoinverse'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end
