% Linear fit with singular value decomposition
% 
% INPUT:
%   - exps: is a N dimensional struct whose fields are fitdata
%   (experimental data), fitbasis (basis for the fit) and params (cell
%   array with the names of the parameters used in the experiment).
%   - groundexps: a M dim struct containing results from on ground experiments.
%   Fuields are: pos (parameter position number), value (on ground measurement
%   result) and err (experimental error on the on ground measurement).
%   - sThreshold it's a threshold for singular values. It is a
%     number, typically 1. It will remove singular values larger
%     than sThreshold which corresponds to removing svd parameters estimated
%     with an error larger than sThreshold.
% 
% OUTPUT:
%   a:      params values
%   Ca:     fit covariance matrix for A
%   Corra:  fit correlation matrix for A
%   Vu:     is the complete conversion matrix
%   Cbu:    is the new variables covariance matrix
%   Fbu:    is the information matrix for the new variable
%   mse:    is the fit Mean Square Error
%   dof:    degrees of freedom for the global estimation
%   ppm:    number of svd parameters per measurements, provides also the
%   number of independent combinations of parameters per each singular
%   measurement. The coefficients of the combinations are then stored in Vu
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = linfitsvd(varargin)
  
  % get inputs
  if nargin == 1 % no ground experiment
    exps = varargin{1};
    groundexps = [];
    remerr = false;
  elseif nargin == 2
    exps = varargin{1};
    if isnumeric(varargin{2})
      sThreshold = varargin{2};
      remerr = true;
      groundexps = [];
    else
      groundexps = varargin{2};
      remerr = false;
    end
  elseif nargin == 3
    exps = varargin{1};
    groundexps = varargin{2};
    sThreshold = varargin{3}; % admitted threshold for singular values
    remerr = true;
    if ~isnumeric(sThreshold)
      sThreshold = inf;
    end
  end
  
  % init collect results struct
  
  % init union matrices
  Vu = [];
  Fbu = [];
  wFbu = [];
  bu = [];
%   eCbu = [];
  Cbu = [];
  ppm = []; % number of svd parameters per measurements
  
  N = numel(exps);
  % run over input experiments
  for ii=1:N
    % get data of the experiments out of the input struct
    y = exps(ii).fitdata;
    X = exps(ii).fitbasis;
    
    % willing to work with columns
    if size(y,1)<size(y,2)
      y = y.';
    end
    if size(X,1)<size(X,2)
      X = X.';
    end
    
    % get svd of X
    [U,W,V] = svd(X,0);
    
    % removing zero singular values
    svals = diag(W);    
    idx = svals==0;    
    svals(idx) = [];
    
    % removing columns of U and V corresponding to zero svalues
    U(:,idx) = [];
    V(:,idx) = [];
    
    if remerr
      % Find params combinations with error larger than 1
      idx = svals<sThreshold;
      svals(idx) = [];

      % removing columns of U and V corresponding to params combinations with
      % error larger than 1
      U(:,idx) = [];
      V(:,idx) = [];
    end
    
    % Sanity check
    % if svals is empty you are going to gain no information from the
    % current data series
    if ~isempty(svals) % go with the fit
      % rebuild W
      W = diag(svals);
      
      % update ppm with the number of parameters for the given experiment
      ppm = [ppm; numel(svals)];

      % get new basis for the fit
      K = U*W;

      % get expected covariance matrix for b, assuming white noise
      Fb = W*W; % information matrix for parameters b

      % get b params with errors, mse is the mean square error, Cb is the
      % covariance matrix of fitted b. It should be equal to eCb.*mse
      [b,stdxb,mseb,Cb] = lscov(K,y);

      % information matrix weighted for fit results Cb = inv(wFb)
      wFb = Fb./mseb;

      % add params from present experiment
      % get union matrices
      Vu = [Vu;V.'];
      Fbu = blkdiag(Fbu,Fb);
      wFbu = blkdiag(wFbu,wFb);
      Cbu = blkdiag(Cbu,Cb);
      bu = [bu;b];
    
    else % no information, no fit
      % update ppm with the number of parameters for the given experiment
      ppm = [ppm; 0];
    end
      
    
    
  end
  
  % insert values from on-ground measured parameters if applicable
  if nargin == 2
    
    for jj = 1:numel(groundexps)

      % get values
      pos = groundexps(jj).pos;
      val = groundexps(jj).value;
      err = groundexps(jj).err;

      tV = zeros(1,size(Vu,2));
      tV(1,pos) = 1;
      Vu = [Vu;tV];
      bu = [bu;val];
      Cbu = blkdiag(Cbu,err^2);
      Fbu = blkdiag(Fbu,1/(err^2));
      wFbu = blkdiag(wFbu,1/(err^2));
      ppm = [ppm; 1];

    end
    
  end
    
  % get results on physical parameters, solve the system with proper weights
  a = lscov(Vu,bu,1./diag(Cbu));
    
  % get params covariance
  Ca = inv(Vu'*wFbu*Vu);
  
  % get params correlation matrix
  Corra = Ca;
  for tt=1:size(Corra,1)
    for hh=1:size(Corra,2)
      Corra(tt,hh) = Ca(tt,hh)/(sqrt(Ca(tt,tt))*sqrt(Ca(hh,hh)));
    end
  end
  
  % get chi square assuming unitary variance white noise
  N = numel(exps);
  mse = 0;
  tL = 0;
  % run over input experiments
  for ii=1:N
    % get data of the experiments out of the input struct
    y = exps(ii).fitdata;
    X = exps(ii).fitbasis;
    
    mse = mse + sum((y - X*a).^2);
    tL = tL + numel(y);
  end
  dof = tL-numel(a);
  mse = mse./dof;

end









