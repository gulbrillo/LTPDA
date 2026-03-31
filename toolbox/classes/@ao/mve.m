% MVE: Minimum Volume Ellipsoid estimator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Minimum Volume Ellipsoid estimator 
%              for robust outlier detection.
%
% CALL:        ao_out = mve(ao_in);
%              ao_out = mve(ao_in, pl);
% 
% The ao_out is the weighted covariance matrix of the data. Other
% information, like the weighted mean, the volume and the center of 
% the ellipsoid are stored in ao_out.procinfo.
%
% Uses the method described in P. Rousseeuw "Robust Regresion and outlier
% Detection, 1987" in pages 258-261. 
%
% **Also in http://www.kimvdlinde.com/professional/pcamve.html
%
% NK 2013  
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'mve')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mve(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### MVE cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs pests and plists
  [aos,   aos_invars]   = utils.helper.collect_objects(varargin(:), 'ao',    in_names);
  pl                    = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  m = find_core(pl, 'm');
  
  % Initialize
  if ~isempty(aos)
    
    A  = aos.y;
    
    if ~ismatrix(A)
      error('### MVE can process only data of the form of 2 dimensional matrices.');
    end
    
  else
    
    error('### MVE can process only AO or PEST objects.');
    
  end
  
  burnin = find_core(pl,'Discard');
  if burnin ~= 0
    A = A(burnin:end,:);
  end
  
  [n ~] = size(A);
  
  % Perform Principal Component Analysis
  if find_core(pl,'pca')

    mu = mean(A);
    sd = std(A);

    % Standardize the data
    sA = (A - repmat(mu,[n 1])) ./ repmat(sd,[n 1]);

    [V ~] = eig(cov(sA));

    % Flip it
    Vf = fliplr(V);

    A = sA*Vf;

  end
  
  % Keep only unique data-points (Useful for the case of MCMC chains)
  A = unique(A,'rows');
  [n p] = size(A);
  
  if m == 0
    % All the possible combinations of the data points
    C = nchoosek(n,p+1);
    if C > 1e6
      warning('LTPDA:mve',['### The number of iterations is greater than '...
                           '1e6! Consider filling the ''m'' key in the plist.'])
    end
    r = combnk(1:n,p+1);
  else
    % Since n is too large, we draw random sub-samples from the data-set:
    if n < m
      error(['### ''m'' is grater than the number of data. Please select '...
             'an appropriate ''m'' from the plist.'])
    end
    
    r = zeros(m,p+1);
    r(1,1:p+1) = randperm(n-1,p+1);
    kk = 2;
    
    while kk <= m
      r(kk,1:p+1) = randperm(n-1,p+1);
      while all(ismember(r(kk,:),r(1:kk-1,:),'rows'))
        r(kk,1:p+1) = randperm(n-1,p+1);
      end
      kk = kk+1;
    end
    
    C = size(r,1);
  end

  % Initialize
  minvol     = Inf;
  calc       = zeros(n,1);
  halfpoints = zeros(floor(n/2),1);
  
  for i = 1:C

    D = A(r(i,:),:);

    if rank(D) == p

      % C. 7, eq. 1.23
      Cj = cov(D);
      
      mu = mean(D);

      % C. 7, eq. 1.24 
      for j=1:n
        calc(j)=(A(j,:) - mu)*inv(Cj)*(A(j,:) - mu)';
      end

      med2 = median(calc);

      med  = sqrt(med2);

      % C. 7, eq. 1.25 
      vol  = sqrt(det(Cj))*med^p; 

      if vol < minvol
        
        minvol = vol;

        % C. 7, eq. 1.26 
        center = mean(D);
        infCov = med2*Cj/chi2inv(0.5,p); 

        % The 50% of the points contained in the MVE
        halfpoints = A(calc <= med2);
         
      end
    end

  end
  
  w = zeros(n,1);
  % Calculate weights
  for j=1:n
    if (A(j,:)-center)*inv(infCov)*(A(j,:) - center)' <= chi2inv(0.975,p)
      w(j) = 1;
    else
      w(j) = 0;
    end
  end
  
  wD                 = bsxfun(@times, w, A);
  wD(all(wD==0,2),:) = []; % Remove zero rows
  
  % Calculate weighted mean (1.27)
  wmu  = mean(wD);
  
  % Calculate weighted covariance (1.28)
  wcov = cov(wD);

  % Set output object
  bs = ao(wcov);
  
  bs.setProcinfo(plist('halfpoints',   halfpoints,...
                       'center',       center, ...
                       'wmean',        wmu,...
                       'inflated cov', infCov,...
                       'minvol',       minvol));
  % Add History
  bs = addHistory(bs,getInfo('None'), pl, aos_invars(:), [aos(:).hist]);
  % Set outputs
  varargout = utils.helper.setoutputs(nargout, bs);
    
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

function plout = buildplist(varargin)
  
plout = plist();
  
  % Perform Principal Component Analysis
  p = param({'pca','Set to true to perform Principal Component Analysis.'}, paramValue.FALSE_TRUE);
  plout.append(p);
  
  % m
  p = param({'m',['Number ''m'' of random sub-samples to be drawn from the data. '...
                  'If set to zero, the method will attempt to proceed taking into acount '...
                  'all possible sub-samples. ATTENTION: If the data-set is too large, this computation '...
                  'is practically unfeasible!']}, paramValue.DOUBLE_VALUE(100));
  plout.append(p);
  
  % Discard
  p = param({'Discard','Discard the first number of samples.'}, paramValue.DOUBLE_VALUE(0));
  plout.append(p);
  
end


