% SPSDSUBTRACTION makes a sPSD-weighted least-square iterative fit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SPSDSUBTRACTION makes a sPSD-weighted least-square iterative fit
%
% CALL: [MPest, plOut, aoResiduum, aoP, aoPini] = spsdSubtraction(ao_Y, [ao_U1, ao_U2, ao_U3 ...]);
%       [MPest, plOut, aoResiduum, aoP, aoPini] = spsdSubtraction(ao_Y, [ao_U1, ao_U2, ao_U3 ...], pl);
%
%  The function finds the optimal M that minimizes the sum of the weighted sPSD of
%  (ao_Y - M * [ao_U1 ao_U2 ao_U3 ...] )
%  if ao_Y is a vector of aos, the use the matrix/spsdSubtraction is
%  advised
%
%  OUTPUTS: - MPest: output PEST object with parameter estimates
%           - aoResiduum: residuum times series
%           - plOut: plist containing data like the parameter estimates
%           - aoP: last weight used in the optimization (fater last
%             Maximization/Expectation step)
%           - aoPini: initial weight used in the optimization (before first
%             Maximization/Expectation step)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'spsdSubtraction')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = spsdSubtraction(varargin)
  
  % use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  if ~nargin>1
    error('optSubtraction requires at least the two input aos as first and second entries')
  end
  
  %% retrieving the two input aos
  [aos_in, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  aosY = varargin{1};
  aosU = varargin{2};
  if (~isa(aosY, 'ao')) || (~isa(aosU, 'ao'))
    error('first two inputs should be two ao-arrays involved in the subtraction')
  end
  
  % Collect plist
  pl = utils.helper.collect_objects(varargin(:), 'plist');
  
  % Get default parameters
  pl = applyDefaults(getDefaultPlist, pl);
  
  %% checking data sizes
  NY = numel(aosY);
  if NY==0
    error('Nothing to subtract to!')
  end
  NU = size(aosU,2);
  if NU==0
    error('Nothing to subtract!')
  end
  if ~(size(aosY,2)==1)
    error('The input ao Y array should be a column vector')
  end
  if ~(size(aosU,1)==NY)
    error('The fields ''subtracted'' should be an array of aos with the height of numel(initial)')
  end
  
  %% collecting history
  if callerIsMethod
    % we don't need the history of the input
  else
    inhist  = [aosY(:).hist aosU(:).hist];
  end
  
  %% retrieving general quantities
  ndata = numel(aosY(1).y);
  Ts = 1/aosY(1).fs;
  nFreqs = floor(ndata/2);
  freqs = 1/(2*Ts) * linspace(0,1,nFreqs);
  
  %% produce window
  Win = find_core(pl, 'Win');
  if isa(Win, 'plist')
    Win = ao( combine(plist( 'length', ndata), Win) );
    W = Win.y;
  elseif isa(Win, 'ao')
    if ~isa(Win.data, 'tsdata')
      error('An ao window should be a time series')
    end
    W = Win.y;
    if ~length(W)==ndata
      error('signals and windows don''t have the same length')
    end
  else
    error('input option Win is not acceptable (not a plist nor an ao)!')
  end
  
  %% get initial M coefficient matrix
  M = pl.find_core('coefs');
  if isempty(M)
    M = zeros(1,NU);
  end
  
  %% get criterion thinness
  linCoef = pl.find_core('lincoef');
  logCoef = pl.find_core('logcoef');
  
  %% getting the input data Y and taking FFT
  Y = zeros(NY, nFreqs);
  YLocNorm = zeros(NY,1);
  
  for ii=1:NY
    if isempty(aosY(ii).data)
      error('One ao for Y is empty!')
    end
    if ~(length(aosY(ii).y)==ndata)
      error('various Y vectors do not have the same length')
    end
    yLoc = fft(aosY(ii).y .* W, ndata);
    YLocNorm(ii) = norm(aosY(ii).y .* W)/sqrt(ndata);
    Y(ii,:) = yLoc(1:nFreqs)/YLocNorm(ii);
  end
  
  %% getting the data U norm
  ULocNorm = zeros(NY,NU);
  for iU=1:NU
    for iY=1:NY
      if ~isempty(aosU(iY,iU).data)
        ULocNorm(iY,iU,:) = norm(aosU(iY,iU).y  .* W)/sqrt(ndata);
      end
    end
  end
  ULocNorm = max(ULocNorm,[],1);
  
  %% getting the input data U and taking FFT
  U = zeros(NY,NU, nFreqs);
  for iY=1:NY
    for iU=1:NU
      if ~isempty(aosU(iY,iU).data)
        if ~(length(aosU(iY,iU).y)==ndata)
          error('various U vectors do not have the same length as Y')
        end
        uLoc = fft(aosU(iY,iU).y .* W, ndata);
        U(iY,iU,:) = uLoc(1:nFreqs)/ (YLocNorm(iY) * ULocNorm(iU));
      end
    end
  end
  
  %% getting the weight powAvgWeight
  weightingMethod =pl.find_core('weightingMethod');
  switch lower(weightingMethod)
    case 'pzmodel'
      weightModel =pl.find_core('pzmodelWeight');
      if numel(weightModel)~=NY
        error('there should be as many pzmodels as weighted entries')
      end
      for ii=1:NY
        weight = weightModel(ii).resp(freqs);
        weight = abs(weight).^2;
        pow = [0 ; weight.y(2:nFreqs)];
        [freqsAvg, powAvgs, nFreqsAvg, nDofs, binningMatrix] = ltpda_spsd(freqs, pow, linCoef, logCoef);
        powAvgWeight(ii,:) = powAvgs; %#ok<AGROW>
      end
    case 'ao'
      weight = pl.find_core('aoWeight');
      if numel(weight)~=NY
        error('there should be as many AOs as weighted entries')
      end
      for ii=1:NY
        if ~isa(weight(ii).data, 'fsdata')
          error('if weight is an ao, it should be a FSdata')
        elseif length(weight(ii).y)~=nFreqs
          error(['length of FS weight is not length of the FFT vector : ' num2str(length(weight(ii).y)) ' instead of ' num2str(nFreqs)])
        else
          pow = weight(ii).y;
          [freqsAvg, powAvgs, nFreqsAvg, nDofs, binningMatrix] = ltpda_spsd(freqs, pow, linCoef, logCoef);
          powAvgWeight(ii,:) = powAvgs; %#ok<AGROW>
          %% add unit check here!!
        end
      end
    case 'residual'
      [freqsAvg, powAvgWeight, nFreqsAvg, nDofs, binningMatrix] = computeWeight(Y, M, U, freqs, linCoef, logCoef);
    otherwise
      error('weighting method requested does not exist!')
  end
  powAvgInv = (powAvgWeight.*(nFreqsAvg.')./(nDofs.')).^-1;
  
  %% get ME iterations termination conditions
  iterMax = pl.find_core('iterMax');
  normCoefs = pl.find_core('normCoefs');
  normCriterion = pl.find_core('normCriterion');
  
  %% Maximization Expectation iterations loop
  for i_iter = 1:iterMax
    utils.helper.msg(utils.const.msg.PROC3, ['starting iteration ', num2str(i_iter)]);
    
    %% initializing history
    if i_iter==1 % storing intial weight
      Pini = powAvgWeight;
      MHist(1,:) = reshape(M, [1, numel(M)] );
    end
    fValIni = optimalCriterion(Y, M, U, powAvgInv, linCoef, logCoef);
    
    %% solving LSQ problem
    [M, hessian] = solveProblem(M, Y, U, powAvgInv, nFreqsAvg, binningMatrix);
    fval = optimalCriterion(Y, M, U, powAvgInv, linCoef, logCoef);
    
    %% store history
    fValHist(i_iter) = fval/fValIni; %#ok<AGROW>
    MHist(i_iter+1,:) = reshape(M, [1, numel(M)] ); %#ok<AGROW>
    
    %% updating weight, recomputing residuum power
    [freqsAvg, powAvgWeight, nFreqsAvg, nDofs] = computeWeight(Y, M, U, freqs, linCoef, logCoef);
    powAvgInv = (powAvgWeight.*(nFreqsAvg.')./(nDofs.')).^-1;
    
    %% deciding whether to pursue or not ME iterations
    if strcmpi( weightingMethod, 'pzmodel')
      display('One iteration for Pzmodel weighting only')
      break
    elseif strcmpi( weightingMethod, 'ao')
      display('One iteration for ao weighting only')
      break
    elseif norm(fValHist(i_iter)-1) < normCriterion && norm(MHist(i_iter+1,:)-MHist(i_iter,:))<normCoefs
      display(['Iterations stopped at iteration ' num2str(i_iter) ' because not enough progress was made (see parameter "normCriterion" and "normCoefs")'])
      break
    elseif i_iter == iterMax
      display(['Iterations stopped at maximum number of iterations ' num2str(i_iter) ' (see parameter "iterMax")'])
      break
    end
  end
  
  %% creating output pest
  MVals = M * diag( ULocNorm.^-1 );
  MStd = diag(diag(ULocNorm) * hessian * diag(ULocNorm)).^-0.5;
  MCov = diag(ULocNorm)^-1 * hessian^-1 * diag(ULocNorm)^-1;
  
  % prepare model, units, names
  model = [];
  for jj = 1:NU
    names{jj} = ['U' num2str(jj)]; %#ok<AGROW>
    units{jj} = aosY(1).yunits / aosU(1,jj).yunits; %#ok<AGROW>
    xunits{jj} = aosU(1,jj).yunits; %#ok<AGROW>
    MNames{jj} = ['M' num2str(jj)]; %#ok<AGROW>
    if jj == 1
      model = ['M' num2str(jj) '*U' num2str(jj)];
    else
      model = [model ' + M' num2str(jj) '*U' num2str(jj)]; %#ok<AGROW>
    end
  end
  
  model = smodel(plist('expression', model, ...
    'params', MNames, ...
    'values', MVals.', ...
    'xvar', names, ...
    'xunits', xunits, ...
    'yunits', aosY(1).yunits ...
    ));
  
  % collect inputs names
  argsname = aosY(1).name;
  for jj = 1:numel(NU)
    argsname = [argsname ',' aosU(jj).name];
  end
  
  % Build the output pest object
  MPest = pest;
  MPest.setY( MVals.' );
  MPest.setDy(MStd);
  MPest.setCov(MCov);
  MPest.setChi2(0);
  MPest.setNames(names{:});
  MPest.setYunits(units{:});
  MPest.setModels(model);
  MPest.name = sprintf('optSubtraction(%s)', argsname);
  
  % Set procinfo object
  MPest.procinfo = plist('MPsdE', 0);
  % Propagate 'plotinfo'
  plotinfo = [aosY(:).plotinfo aosU(:).plotinfo];
  if ~isempty(plotinfo)
    MPest.plotinfo = combine(plotinfo);
  end
  
  %% creating output plist
  plOut = plist;
  
  p = param({ 'criterion' , 'last value of the criterion in the last optimization'}, fval );
  plOut.append(p);
  p = param({ 'M' , 'Best fitting value'}, MVals );
  plOut.append(p);
  p = param({ 'Mhist' , 'History of the best fit, through iteration'}, MHist * diag( ULocNorm.^-1 ) );
  plOut.append(p);
  p = param({ 'fValHist' , 'History of the criterion value, through iteration'}, fValHist );
  plOut.append(p);
  p = param({ 'hessian' , 'fitting hessian'},  diag(ULocNorm) * hessian * diag(ULocNorm) );
  plOut.append(p);
  %add history and use Mdata/Pest instead
  
  %% creating aos for the weights used
  if nargout>2
    aoP = ao.initObjectWithSize(NY, 1);
    aoPini = ao.initObjectWithSize(NY, 1);
    for ii=1:NY
      aoP(ii).data = fsdata(freqsAvg, YLocNorm(ii)^2 * powAvgWeight(ii,:));
      aoP(ii).setName('final weight');
      aoP(ii).setXunits(unit.Hz);
      aoP(ii).setYunits(aosY(ii).yunits^2 * unit('Hz^-1'));
      aoP(ii).setDescription(['final weight in the channel "' aosY(ii).name '"']);
      aoP(ii).setT0(aosY(ii).t0+aosY(ii).x(1));
      aoPini(ii).data = fsdata( freqsAvg, YLocNorm(ii)^2 * Pini(ii,:));
      aoPini(ii).setName('initial weight');
      aoPini(ii).setXunits(unit.Hz);
      aoPini(ii).setYunits(aosY(ii).yunits^2 * unit('Hz^-1'));
      aoPini(ii).setDescription(['initial weight in the channel "' aosY(ii).name '"']);
      aoPini(ii).setT0(aosY(ii).t0+aosY(ii).x(1));
    end
  end
  
  %% creating residuum time-series
  if nargout>2
    aoResiduum = ao.initObjectWithSize(NY,1);
    for ii=1:NY
      aoResiduumValue = aosY(ii).y;
      for jj = 1:NU
        aoResiduumValue = aoResiduumValue - MVals(jj)*aosU(ii,jj).y;
      end
      aoResiduum(ii).data = tsdata(aoResiduumValue, aosY(ii).fs);
      aoResiduum(ii).setName(['residual in the channel "' aosY(ii).name '"' ]);
      aoResiduum(ii).setXunits(unit.seconds);
      aoResiduum(ii).setYunits(aosY(ii).yunits);
      aoResiduum(ii).setDescription(['residual corresponding to "' aosY(ii).description '"' ]);
      aoResiduum(ii).setT0(aosY(ii).t0);
    end
  end
  
  %% adding history
  if callerIsMethod
    % we don't need to set the history
  else
    MPest.addHistory(getInfo('None'), pl, ao_invars, inhist);
    if nargout>2
      for ii=1:NY
        aoP(ii).addHistory(getInfo('None'), pl, ao_invars, inhist);
        aoPini(ii).addHistory(getInfo('None'), pl, ao_invars, inhist);
        aoResiduum(ii).addHistory(getInfo('None'), pl, ao_invars, inhist);
      end
    end
  end
  
  %% return coefficients and hessian and Jfinal and powAvgWeight
  if nargout>2
    varargout = {MPest, plOut, aoResiduum, aoP, aoPini};
  else
    varargout = {MPest, plOut};
  end
end

%% weight for optimal criterion
function [freqsAvg, powAvgWeight, nFreqsAvg, nDofs, binningMatrix] = computeWeight(Y, M, U, freqs, linCoef, logCoef)
  errDft =  subtraction( Y, M, U);
  errPow = real(errDft).^2 + imag(errDft).^2;
  for ii=1:size(errDft,1)
    [freqsAvg, powAvgs, nFreqsAvg, nDofs, binningMatrix] = ltpda_spsd(freqs, errPow, linCoef, logCoef);
    powAvgWeight(ii,:) = powAvgs;  %#ok<AGROW>
  end
end

%% optimal criterion
function j = optimalCriterion(Y, M, U, powAvgInv, linCoef, logCoef)
  errDft = subtraction(Y, M, U);
  errPow = real(errDft).^2 + imag(errDft).^2;
  j = 0;
  for ii=1:size(errDft,1)
    [freqsAvg, powAvgs, nFreqsAvg, nDofs] = ltpda_spsd([], errPow, linCoef, logCoef); %#ok<ASGLU>
    powSum = powAvgs .* nDofs; % binning frequencies as in sPSD
    j  = j + sum( powSum .* powAvgInv(:,ii) );
    %     alpha = 4;
    %     logProbaDensityFactor =  - nFreqsAvg * log(2) - gammaln(nFreqsAvg);
    %     normlzChi2Sum = ((alpha*2)*powSum) .* powAvgInv(:,ii); % divide the sum by the expected average of each terms, so the chi2 is normalized
    %     logProbaDensities = logProbaDensityFactor + (nFreqsAvg-1).*log(normlzChi2Sum) - normlzChi2Sum/2 ; % here computing log of probability
    %     j = j - sum(logProbaDensities); % better than taking product of probabilities
  end
end

%% time-series subtraction function
function Y = subtraction( Y, M, U)
  ndata = size(Y,2);
  for ii=1:size(Y,1)
    for j=1:numel(M)
      Y(ii,:) = Y(ii,:) - reshape( M(j)*U(ii,j,:) , [1,ndata] );
    end
  end
end

%% Direct solver
function [M, hessian] = solveProblem(M, Y, U, powAvgInv, nFreqsAvg, binningMatrix)
  errDft = subtraction(Y, M, U);
  NU = size(U,2);
  NFreqs = size(binningMatrix,2);
  ATB = zeros(NU,1);
  ATA = zeros(NU,NU);
  % matrix for frequency binning & Weighting & Summing :
  matBSW = powAvgInv * binningMatrix;
  for iiParam = 1:NU
    Uii = reshape(U(1,iiParam,:), [1 NFreqs]);
    ATB(iiParam) = 2 * ( matBSW * real( Uii .* conj(errDft) ).' );
    for jjParam = 1:NU
      Ujj = reshape(U(1,jjParam,:), [1 NFreqs]);
      ATA(iiParam,jjParam) = 2 * ( matBSW * real( Uii .* conj(Ujj) ).' );
    end
  end
  try
    MUpdate = ATA^-1 * ATB;
    M = M + MUpdate.';
  catch
    warning('Numerical accuracy limited the number of iterations')
  end
  hessian = ATA;
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist;
  
  % initial coefficients for subtraction initialization
  p = param({ 'coefs' , 'initial subtracted coefficients, must be a nY*nU double array. If not provided zeros are assumed'},  [] );
  pl.append(p);
  
  % weighting scheme
  p = param({ 'weightingMethod' , 'choose to define a frequency weighting scheme'},  {1, {'residual', 'ao', 'pzmodel'}, paramValue.SINGLE} );
  pl.append(p);
  
  p = param({ 'aoWeight' , 'ao to define a frequency weighting scheme (if chosen in ''weightingMethod'')'},  paramValue.EMPTY_DOUBLE );
  pl.append(p);
  
  p = param({ 'pzmodelWeight' , 'pzmodel to define a frequency weighting scheme (if chosen in ''weightingMethod'')'},  paramValue.EMPTY_DOUBLE );
  pl.append(p);
  
  p = param({ 'lincoef' , 'linear coefficient for scaling frequencies in chi2'},  5 );
  pl.append(p);
  
  p = param({ 'logcoef' , 'logarithmic coefficient for scaling frequencies in chi2'},  0.3 );
  pl.append(p);
  
  % iterations convergence stop criterion
  p = param({ 'iterMax' , 'max number of Mex/Exp iterations'},  20 );
  pl.append(p);
  
  p = param({ 'normCoefs' , 'tolerance on inf norm of coefficient update (used depending on ''CVCriterion'')'},  1e-15 );
  pl.append(p);
  
  p = param({ 'normCriterion' , 'tolerance on norm of criterion variation (used depending on ''CVCriterion'')'},  1e-15 );
  pl.append(p);
  
  % windowing options
  p = param({ 'win' , 'window to operate FFT, may be a plist/ao'},  plist('win', 'levelledHanning', 'PSLL', 200, 'levelOrder', 4 ) );
  pl.append(p);
    
end


