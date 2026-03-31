% FLSCOVSEGMENTS - Tool to perform a least square fit in frequency domain
%
% DESCRIPTION: The function averages the different nosie segments. Segments
% are input as elements of matrix objects. A typical application is the
% parameter estimation over noise segments of different days. 
%
% CALL: 
%       pest_obj = flscovSegments([m0, m1, m2 ..., mN],pl)
%
%       where the first object (m0) of the input array is considered to be
%       the output data in the realization 
%
%               m0 = c_1 * m1 + c_2 * m2 + ... + c_N * mN
%   
%       The c_i are the parameters to be estimated.
%
% INPUTS:
%             - m#:         matrix objects
%             - pl:         plist
%
%
%<a href="matlab:utils.helper.displayMethodInfo('ao', 'flscovSegments')">ParametersDescription</a>
%
% LF & DV & NK 2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = flscovSegments(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii);end; end
  
  % Collect all AOs and plists
  [aos, ~] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  pl       = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  in_aos = copy(aos, nargout);
  
  % Apply the defaults of the plist
  pl = applyDefaults(getDefaultPlist(), pl);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % extract parameters out of the plist
  pTol       = pl.find('p tol');
  maxiter    = pl.find('maxiter');
  paramNames = pl.find('fitparams');
  
  if isempty(paramNames)
    for ii = 1:numel(in_aos)-1
      paramNames{ii} = sprintf('p%d',ii);
    end
  end
  
  % define plists
  psdpl = plist('Win',   pl.find('win'),...
                'order', pl.find('order'),...
                'olap',  50);
                
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Perform FFT on the time series
  fss = performFFT(in_aos, pl);
   
  %idxselectall = 1:pl.find('k1'):numel(fs(1).x);
  %freqs = fs(1).x;
  % trovare una soluzione. o definire un giusto intervallo per select o
  % aggiustare il prodotto di split che non conserva la size dell'oggetto
  % in input!
  plk1 = plist('samples',5:pl.find('k1'):numel(fss(1).x));
  fss1 = select(fss,plk1); % This select does not work

  %fs = select(performFFT(in_aos, pl),plk1); % This select does not work
  %fine should find a fix
  
  % split in frequencies
  fpl   = plist('frequencies', pl.find('frequencies'));
  fs = split(fss1,fpl);
  fs = reshape(fs,size(fss1));
  
  % Initialise
  pest_obj = pest.initObjectWithSize(1, maxiter);
%   w        = ones(1,numel(double(fs(1)))); % initial weights
  w        = ones(1,numel(double(fs(1))))'; % initial weights

  % Perform the iterative least squares scheme 
  for iter = 1:maxiter
    
    % Do the least squares fit in frequency domain
    [p, invAnm] = lsf(fs, w);
    w0 = w;
    
    % Get correlation
    [ExpCorrC, ~] = utils.math.cov2corr(invAnm);
    
    % Define pest object
    pest_obj(iter) = pest(p);
    pest_obj(iter).setNames(paramNames{:});
    pest_obj(iter).setDy(sqrt(diag(invAnm)));
    pest_obj(iter).setCov(invAnm);
    pest_obj(iter).setCorr(ExpCorrC);
    pest_obj(iter).setYunits(pl.find('yunits'));
    pest_obj(iter).setName(sprintf('Parameter'));
    
     % Print message
    printMessage(iter);
    
    % Compute the residuals
    in_aos.simplifyYunits;
    [residuals, res_psd, w] = computeResiduals(in_aos, p, w, pl, psdpl,plk1);
    
    sw = sum(w)/sum(w0);
    fprintf('Chi square %f\n',sw);
    
    
    
    % Show results
    table(pest_obj(iter));
    
    % Stopping criterion
    if iter > 1
      % Get the stopping criterion
      dw = abs(sw - 1);

      % terminate?
      if all(dw < pTol)
        fprintf('\n')
        fprintf('*** \n')
        fprintf('*** Tolerance criterion satisfied. Stopping re-weighted least squares iterations. *** \n')
        fprintf('*** \n')
        fprintf('\n')
        break
      end
    end
   % store the values
   lastp0 = p;
  end
  
  % Get the residuals fsdata
  %residuals = select(psdSegments(residuals, psdpl),plk1); % select does
  %not work fine a workaround should be find
  residuals = psdSegments(residuals, psdpl);
  residuals.setName('Residuals');
  res_psd.setName('Residuals');
  orig      = psdSegments(in_aos(1).objs(:), psdpl);
  orig.setName('Original');
  
  % Plot?  
  if pl.find_core('doplot')  
    try
      
      % select the frequency bin of the target
      plk_plot = plist('samples',1:pl.find('k1'):numel(orig.x));
      target_ao_psd_select = select(orig,plk_plot);
      
      % select the frequency range of the analysis
      target_ao_psd_split = split(target_ao_psd_select, fpl);
      
      % plot psd of target versus residuals
      iplotPSD(target_ao_psd_split, res_psd, plist('errorbartype','area'));
      
%       iplotPSD(orig, residuals, plist('errorbartype','area'));
      
      
      
    catch ME
      fprintf('### Failed produce plot of the residuals. Error: %s \n', ME.message)
    end
  end
  
  % Delete empty pests
  pest_obj(iter+1:end) = [];
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Collect outputs
  out_obj = collection(pest_obj(end), residuals, orig);
  out_obj.setProcinfo(plist('history pests', pest_obj(1:iter-1)));
  out_obj = addHistory(out_obj,getInfo('None'), pl, [], []);
  
  % Set outputs
  if nargout > 0
    varargout{1} = out_obj;
  else
    error('### flscovSegments cannot be used as a modifier!');
  end
  
end

%--------------------------------------------------------------------------
% Compute the residuals
%--------------------------------------------------------------------------
function [residual, res_psd, w] = computeResiduals(ts, p, w, pl, psdpl, plk1)

  nSegments = times(ts(1).size(1),ts(1).size(2));
  
  model  = ao.initObjectWithSize(nSegments,1); 
  residual = ao.initObjectWithSize(nSegments,1);
  yunits = pl.find_core('Yunits');
  
  % check if isempty
  warn = ['### The Y-units of at least one of the parameters is empty. The residual computation '...
             'might fail if the result depends on their Y-units.'];
           
  if ~iscell(yunits) && isempty(yunits(1).exps)
    warning(warn);
    % fill the Yunits with empty objects
    for ii=1:numel(ts)-1
      yunits(ii) = unit();
    end
  elseif iscell(yunits) && isempty(yunits)
    warning(warn);
    % fill the Yunits with empty objects
      yunits = cell(1,numel(ts,1));
  end
  
  try
    % create AOs with the correct yunits and try to compute the residuals
    for jj=1:nSegments
      
      for ii=1:numel(ts)-1

        if iscell(yunits)

          param = ao(plist('yvals', p(ii), 'yunits', yunits{ii}));

        elseif strcmpi(class(yunits), 'unit')

          param = ao(plist('yvals', p(ii), 'yunits', yunits(ii)));

        else 
          error('### The Y-units of the parameters must be either in a cell array, or LTPDA unit objects...');
        end
        % evaluate the model
        if isempty(model(jj).data) % cope with the first step
          model(jj) = param.*ts(1+ii).getObjectAtIndex(jj);
        else
          model(jj) = model(jj) + param.*ts(1+ii).getObjectAtIndex(jj);
        end
      end
    
    
      % Fix y-units
      model(jj).toSI;
      target_ts = ts(1).getObjectAtIndex(jj);
      ts_jj = model(jj);
      [target_ts, ts_jj] = consolidate(target_ts, ts_jj, plist('truncate',0));
      % Calculate residuals
%       residual(jj) = ts(1).getObjectAtIndex(jj) - model(jj);
      residual(jj) = target_ts - ts_jj;

      % set name
      residual(jj).setName(sprintf('Residuals segment %s',num2str(jj)));
    
    end

    % split in frequencies
    fpl   = plist('frequencies', pl.find('frequencies'));
    
    % The PSD of the residuals
    %res_psd = split(select(psdSegments(residual, psdpl),plk1), fpl);
    res_psd = psdSegments(residual, psdpl); % select does not work fine a fix is needed
    plk = plist('samples',1:pl.find('k1'):numel(res_psd.x));
    res_psd = select(res_psd,plk);
    res_psd = split(res_psd, fpl); % select does not work fine a fix is needed

    % Update the weights for the n-th iteration
    w = double(res_psd);
  catch ME
    fprintf('### Failed to compute the residuals. Error: %s \n', ME.message)
    residual = ao();
    res_psd  = ao();
  end
  
end

%--------------------------------------------------------------------------
% Do PSD for the segments
%--------------------------------------------------------------------------
function M = psdSegments(tsobj,plobj)

Nobjs = numel(tsobj);
sobj = ao.initObjectWithSize(Nobjs,1);
for ii=1:Nobjs
  sobj(ii) = psd(tsobj(ii),plobj);
end
% do average
M = sobj.average;

%   % Get number of windows
%   Nsegs = numel(tsobj);
%   Sxxk  = ao.initObjectWithSize(Nsegs,1);
%   Mn2xx = 0;
%   M     = 0;
%   
%   for ii=1:Nsegs
%     % Do the PSD over the segments
%     Sxxk(ii) = psd(tsobj(ii),plobj);
%     if ii == 1
%       M = Sxxk(ii);
%     else
%       Qxx = Sxxk(ii) - M;
%       M = M + Qxx/ii;
%       Mn2xx = Mn2xx + Qxx .* (Sxxk(ii) - M);
%     end
%   end
%     
%   if Nsegs == 1
%     Svxx = [];
%   else
%     Svxx = Mn2xx/(Nsegs-1)/Nsegs;
%     % Set the propper error
%     M.setDy(sqrt(double(4.*Svxx./(tsobj(1).fs)^2)));
%   end
end

% %--------------------------------------------------------------------------
% % Perform the least square fit in frequency domain
% %--------------------------------------------------------------------------
% function [p, invAnm] = lsf(fs, w, pl)
% 
%   % Initialise
%   N_fs   = numel(fs(:,1));
%   fs_all = [];
%   % number of averages
%   navs   = numel(fs(1,:));
%   newvar = zeros(N_fs, N_fs, navs);
% 
%   % Run over the number of averages
%   for nn = 1:navs
%     
%     % Put frequency-series to a matrix
%     for jj=1:N_fs
%       fs_all = [fs_all, double(fs(jj,nn))];
%       % fs_all = [fs1(nn).y, fs2(nn).y, fs3(nn).y, fs4(nn).y, fs5(nn).y, fs6(nn).y].';
%     end
%     fs_all = fs_all.';
%     
%     % Here, we try to fill a tridimensional array. The rows and the columns
%     % label the n_param x n_param multiplication of Fourier series, e.g.
%     % x_n[k]x_m*[k] and y[k]x_m*[k]. Each two-dimensional slice
%     % corresponds to a value of k (the frequency).
% 
%     % initialise
%     nbins  = numel(fs_all(1,:));
%     fs_new = zeros(N_fs,N_fs,nbins);
%     
%    
%     % Run over the rows
%     for jj = 1:N_fs
%       % Run over the columns
%       for kk = 1:N_fs
%         % Run over the third dimension of the array
%         for ll = 1:nbins
%           fs_new(jj,kk,ll) = fs_all(jj,ll)*conj(fs_all(kk,ll))./w(ll);
%         end
%       end
%     end
% 
%     % For each stretch, we store in a new tridimensional array the real part of the sum
%     % over the frequency of ts_new
%     newvar(:,:,nn) = real(sum(fs_new, 3));
%    
%     % Empty matrix
%     fs_all = [];
%   end
% 
%   % We average over the number the stretches
%   aver_matrix = sum(newvar,3);
%   
%   % Solve the linear system to find the parameters
%   % C      = aver_matrix(1,1);
%   
%   B      = 4*aver_matrix(2:end,1);
%   Anm    = 4*aver_matrix(2:end,2:end);
%   invAnm = Anm\eye(size(Anm));
%   p      = Anm\B;
%         
% end

%--------------------------------------------------------------------------
% Perform FFT on the time-series
%--------------------------------------------------------------------------
function fs = performFFT(ts, pl)
  
  %%% ------
  freqs = pl.find('frequencies');
  nSegments = times(ts(1).size(1),ts(1).size(2));
  
  % get # of time-series
  N_ts = numel(ts);
  ts_s = ao.initObjectWithSize(N_ts, nSegments);
  
  for jj = 1:N_ts
    for ii = 1:nSegments
      ts_s(jj,ii) = ts(jj).getObjectAtIndex(ii);
    end
  end
  

  fs = performFFTcore(ts_s,N_ts,nSegments,freqs,pl);

%   % initialise
%   fs   = ao.initObjectWithSize(N_ts, nSegments);
%   
%   % Define fft plist
%   plfft = plist('win',         pl.find('win'),'scale',1);
%   splk0 = plist('samples',     [pl.find('K0') inf]);
%   fpl   = plist('frequencies', freqs);
%   
%    % Compute scale factor to compensate for the window power
%   win    = pl.find_core('win');
%   nfs     = numel(ts_s(1,1).y);
%   winVals = specwin(win, nfs).win.';
%   K       = sqrt(winVals'*winVals);
%  
%   for ii = 1:N_ts
%     fs(ii,:) = split(split(fft(ts_s(ii,:), plfft), fpl), splk0); 
%   end
%   
%   fs = fs/K;
  
end

%--------------------------------------------------------------------------
% Print message at each loop function
%--------------------------------------------------------------------------
function printMessage(iter)

  fprintf(' \n')
  fprintf('************* Finished loop %d ************* \n', iter)
  fprintf(' \n')
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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
  
  p = param({'FITPARAMS', 'A cell array containing the names of the parameters to be estimated.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
  p = param({'FREQUENCIES','The frequency range. Must be a [2x1] array with the minimum and maximum frequencies of the analysis.'},  paramValue.DOUBLE_VALUE([]));
  pl.append(p);
  
  p = param({'NAME','The name of the result of the fit.'},  paramValue.STRING_VALUE('Frequency domain chi^2 fit'));
  pl.append(p);

  p = param({'TRIM','A 2x1 vector that denotes the samples to split from the star and end of the time-series (split in offsets).'},  paramValue.DOUBLE_VALUE([]));
  pl.append(p);

  p = param({'WIN','The window to apply to the data.'},  paramValue.STRING_VALUE('BH92'));
  pl.append(p);
  
  p = param({'NOISE MODEL',['The given noise model. It may be a) an AO time-series with the appropriate Y units, b) '...
                                  'an AO frequency-series of the correct size (NoutputsXNoutputs), c) a SMODEL (function of freqs) '...
                                  'of the correct size (NoutputsXNoutputs) d) a MFH object. ']},  paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'INTERPOLATION METHOD', 'The interpolation method for the computation of the inverse cross-spectrum matrix.'}, ...
    {2, {'nearest', 'linear', 'spline', 'pchip', 'cubic', 'v5cubic'}, paramValue.SINGLE});
  pl.append(p);

  p = param({'ORDER',['The order of segment detrending:<ul>', ...
                      '<li>-1 - no detrending</li>', ...
                      '<li>0 - subtract mean</li>', ...
                      '<li>1 - subtract linear fit</li>', ...
                      '<li>N - subtract fit of polynomial, order N</li></ul>']}, paramValue.DETREND_ORDER);
  p.val.setValIndex(-1);
  pl.append(p);

  p = param({'YUNITS', 'The Y units of the parameters to be estimated. The ''UNIT'' objects must be used.'}, unit());
  pl.append(p);

  p = param({'DOPLOT', 'True-False flag to plot the residual time series.'}, paramValue.TRUE_FALSE);
  pl.append(p);

  p = plist({'BIN DATA','Set to true to re-bin the measured noise data.'}, paramValue.TRUE_FALSE);
  pl.append(p);

  p = plist({'FIT NOISE MODEL','Set to true to attempt a fit on the noise spectra using the ''polyfitSpectrum'' function.'}, paramValue.FALSE_TRUE);
  pl.append(p);

  p = plist({'POLYNOMIAL ORDER','The order of the polynomial to be used in the ''polyfitSpectrum'' function.'}, paramValue.DOUBLE_VALUE(-10:10));
  pl.append(p);
  
  p = param({'k0','The first FFT coefficient of the analysis. All K<K1 coefficients are dropped.'},  paramValue.DOUBLE_VALUE(5));
  pl.append(p);
  
  p = param({'k1','The k1 coefficient to downsample in frequency domain. More info found in Phys. Rev. D 90, 042003. If left empty, all the spectra is used.'},  paramValue.DOUBLE_VALUE(4));
  pl.append(p);
  
  p = param({'P TOL', 'The tolerance for terminating the outer loop. The iterations will stop if the change in the p0-p0_previous is less than this value.'}, paramValue.DOUBLE_VALUE(1e-6));
  pl.append(p);
  
  p = param({'MAXITER', 'The maximum number of iterations of the outer chi^2 loop.'}, paramValue.DOUBLE_VALUE(30));
  pl.append(p);
  
end

% END
