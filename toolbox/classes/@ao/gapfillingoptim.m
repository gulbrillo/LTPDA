% GAPFILLINGOPTIM fills possible gaps in data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GAPFILLINGOPTIM minimizes a chi square based on the signal's
%              expected PSD. It uses ao/optSubtraction for the small scale
%              algorithm, optSubstitution for the large scale algorithm.
%
% CALL:        [aoGapsFilled, plOut, aoP, aoPini, aoWindow, aoWindowShift] = ao.gapfilling(plist)
%
% INPUTS:      ao_data - data segment with the signal to reconstitue
%              pl - parameter list
%
% OUTPUTS:     aoGapsFilled  - data segment containing ao_data, with filled data gaps
%              plOut         - output plist containing the output of
%                              gapFillingOptim
%              aoP, aoPini   - final and initial frequency PSD used to weight
%                              the optimal problem
%              aoWindow      - window used for estmating spectrum
%              aoWindowShift - shifted window used for optimizing spectrum
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'gapfillingoptim')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = gapfillingoptim(varargin)
  % y ycalib fs isgap iscalib freq_weight ncalib ndata nfft ngaps
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  %% Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [aos, ao_invars]  = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pli               = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Get default parameters
  pl = applyDefaults(getDefaultPlist, pli);
  
  %% declaring global optData variable
  clear global optData
  global optData
  
  %% getting time-series to fill, and usefull data (frequencies, number of frequencies... )
  if numel(aos)==0
    error('Nothing to fill gaps!')
  elseif numel(aos)>1
    error('The filling algorithm only works for one single signal at a time')
  end
  optData.nData  = numel(aos.y);
  optData.yNorm  = norm(aos.y) / optData.nData;
  optData.y      = aos.y / optData.yNorm;
  optData.Ts     = 1/aos(1).fs;
  optData.nFreqs = floor(optData.nData/2)+1;
  optData.freqs  = linspace(0, 1/(2*optData.Ts), optData.nFreqs);
  optData.keepFreqs = [true(1,sum(optData.nFreqs)) false(1,sum(optData.nFreqs)-1)];
  
  %% finding gaps
  aoGaps = pl.find_core('isgap');
  if isempty(aoGaps)
    error('no gap vector provided!')
  elseif isequal(aoGaps,'zeros')
    optData.isGap = (aos.y==0);
  elseif numel(isempty(aoGaps))>1
    error('please provide only one gap vector!')
  elseif isa(aoGaps.y, 'double')
    optData.isGap = (aoGaps.y==0);
  elseif  isa(aoGaps.y, 'logical')
    optData.isGap = aoGaps.y;
  else
    error('wrong type for parameter "isGap"')
  end
  optData.gapsPos = find(optData.isGap);
  optData.nGaps = numel(optData.gapsPos);
  clear aoGaps
  
  %% checking number of gaps is not zero
  if numel(optData.gapsPos)==0
    error('No gap to fill!')
  end
  if numel(optData.isGap) ~= optData.nData
    error('gap vector is not the same length as the gapped vector!')
  end
  
  %% produce LF window
  Win = find_core(pl, 'Win');
  if isa(Win, 'plist')
    Win = ao( combine(plist( 'length', optData.nData), Win) );
    optData.lfWin = Win.y;
  elseif isa(Win, 'ao')
    if ~isa(Win.data, 'tsdata')
      error('An ao window should be a time series')
    end
    optData.lfWin = Win.y;
    if ~length(optData.lfWin)==optData.nData
      error('signals and windows don''t have the same length')
    end
  else
    error('input option Win is not acceptable (not a plist nor an ao)!')
  end
  
  %% produce HF window
  [shiftVals, shiftCounts, winHF, winsHfShift] = makeHFWindows(optData.nData, optData.gapsPos);
  optData.nShifts     = numel(shiftVals);
  optData.shiftVals   = shiftVals;
  optData.shiftCounts = shiftCounts;
  optData.hfWin       = winHF;
  optData.win         = optData.lfWin .* optData.hfWin;
  optData.winsHfShift = winsHfShift;
  optData.winsShift   = winsHfShift;
  for iiShift = 1:(2*optData.nShifts)
    optData.winsShift(:, iiShift) = optData.winsHfShift(:, iiShift) .* optData.lfWin;
  end
  clear shiftVals shiftCounts winHF winsHfShift
  
  %% get initial M coefficient matrix
  M = pl.find_core('coefs');
  if isempty(M)
    M = zeros(1,optData.nGaps);
  end
  
  %% detrending (with a windowing agains HF noise)
  trends          = [ones(optData.nData,1) linspace(-1,1,optData.nData).' ]; % two orthogonal vectors to subtract
  trendsWindowed  = trends .* [optData.win optData.win]; % windowing is applied to estimate trends
  yWindowed       = optData.y .* optData.win;   % windowing is applied to de-trened data to be consistent
  optData.trend   = pinv(trendsWindowed) * yWindowed; % solution of the least-square problem
  trendCorrection = trends * optData.trend; % trend is removed from the data while filling gaps. It is re-added later on.
  optData.y       = optData.y - trendCorrection; % detrended vector
  optData.y(optData.gapsPos) = zeros(size(optData.gapsPos)); % setting to zero the gap-data
  
  %% get sPSD averaging linear-scaling averaging-width coefficient
  optData.linCoef = pl.find_core('linCoef');
  optData.logCoef = pl.find_core('logCoef');
  
  %% get MAX/EXP iterations termination conditions
  iterMax = pl.find_core('iterMax');
  optData.criterion = pl.find_core('fitCriterion');
  normCriterion = pl.find_core('normCriterion');
  normCoefs = pl.find_core('normCoefs');
  
  %% set optim CVG options
  options.MaxFunEvals = pl.find_core('maxCall');
  options.Display     = pl.find_core('display');
  options.TolFun      = min( pl.find_core('normCriterion'), 1e-12 );
  options.TolX        = min( pl.find_core('normCoefs'), 1e-14 );
  options.MaxIter     = pl.find_core('maxCall');
  doHessian           = pl.find_core('Hessian');
  if ~isempty(doHessian)
    error('Hessian option is now deactivated as it is too demanding computationaly')
  end
  
  %% computing various useful quantities used for the criterion computation
  weightingMethod =pl.find_core('weightingMethod');
  switch weightingMethod
    case 'pzmodel'
      weightModel = pl.find_core('pzmodelWeight');
      if numel(weightModel) ~= 1
        error('there should be only one pzmodel')
      end
      weight = weightModel.resp(optData.freqs);
      weight = abs(weight).^2;
      Ploc = weight.y;
      [freqsAvg, pAvg, nFreqsAvg, nDofs, sumMat] = ltpda_spsd(optData.freqs, Ploc, optData.linCoef, optData.logCoef); %#ok<ASGLU>
    case 'ao'
      weight =pl.find_core('aoWeight');
      if numel(weight)~=1
        error('there should be as many pzmodels as weighted entries')
      end
      if ~isa(weight.data, 'tsdata')
        error('if the weight is an ao, it should be a FSdata')
      elseif length(weight.y)==optData.nFreqs
        error(['length of FS weight is not length of the FFT vector : ' num2str(length(weight.y)) 'instead of ' num2str(optData.nFreqs)])
      else
        Ploc = weight.y;
        [freqsAvg, pAvg, nFreqsAvg, nDofs, sumMat] = ltpda_spsd(optData.freqs, Ploc, optData.linCoef, optData.logCoef); %#ok<ASGLU>
      end
    case 'residual'
      [pAvg, freqsAvg, powSigma, sumMat, nFreqsAvg ] = computeWeight( optData.y, M, optData.gapsPos, optData.freqs);
    otherwise
      error('weighting method requested does not exist!')
  end
  
  %% Maximization Expectation iteration loop
  for i_iter = 1:iterMax
    utils.helper.msg(utils.const.msg.PROC3, ['starting iteration ', num2str(i_iter)]);
    
    %% setting weight in optData
    optData.sumMat    = sumMat;
    optData.nFreqsAvg = nFreqsAvg;
    optData.powInv    = pAvg.^-1;
    optData.logProbaDensityFactor =  - nFreqsAvg * log(2) - gammaln(nFreqsAvg);
    
    %% initializing historical outputs
    if i_iter==1 % storing intial weight
      Pini = pAvg;
      MHist(1,:) = reshape(M, [1, numel(M)] );
    end
    fValIni = optimalCriterion(M);
    
    %% minimizing the criterion
    switch lower(optData.criterion)
      case 'ftest'
        M = solveProblemFTest( optData.gapsPos, optData.powInv, optData.nFreqsAvg); % very fast direct solver in this case
        fval = optimalCriterion(M);
      case 'ftest-nohfwin'
        M = solveProblemFTestNoHFWin( optData.gapsPos, optData.powInv, optData.nFreqsAvg); % very fast direct solver in this case
        fval = optimalCriterion(M);
      otherwise
        M = solveProblemFTest( optData.gapsPos, optData.powInv, optData.nFreqsAvg); % initialize with fast solver (with the wrong criterion, but it doesn't matter so much)
        [M, fval] = fminunc(@optimalCriterion,M,options); % further non-linear minimzation steps with correct criterion
    end
    
    %% updating weight
    [pAvg, freqsAvg] = computeWeight(optData.y, M, optData.gapsPos, optData.freqs);
    
    %% store history
    fValHist(i_iter) = fval/fValIni; %#ok<AGROW>
    MHist(i_iter+1,:) = reshape(M, [1, numel(M)] ); %#ok<AGROW>
    
    %% deciding whether to pursue or not ME (=bootstrap) iterations
    if strcmpi( weightingMethod, 'pzmodel')
      display('One iteration for Pzmodel weighting only')
      break
    elseif strcmpi( weightingMethod, 'ao')
      display('One iteration for ao weighting only')
      break
    elseif norm(fValHist(i_iter)-1) < normCriterion
      display(['Iterations stopped at iteration ' num2str(i_iter) ' because criterion did not make enough progress (see parameter "normCriterion")'])
      break
    elseif i_iter == iterMax
      display(['Iterations stopped at maximum number of iterations ' num2str(i_iter) ' (see parameter "iterMax")'])
      break
    elseif norm(MHist(i_iter+1,:)-MHist(i_iter,:))<normCoefs
      display(['Iterations stopped at iteration ' num2str(i_iter) ' because parameters did not make enough progress (see parameter "normCoefs")'])
      break
    end
  end % ending loop over MAX/EXP iterations
  
  %% creating output plist
  plOut = plist;
  p = param({ 'criterion' , 'last value of the criterion in the last optimization'}, fval );
  plOut.append(p);
  p = param({ 'M' , 'Best fitting value'}, (M + trendCorrection(optData.gapsPos).') * optData.yNorm );
  plOut.append(p);
  
  %% creating output aos for weights
  aoP = ao( fsdata(freqsAvg, pAvg * (optData.yNorm^2 * optData.Ts / optData.nData) ) );
  aoP.setName('final weight');
  aoP.setXunits(unit.Hz);
  aoP.setYunits(aos.yunits^2 * unit('Hz^-1'));
  aoP.setDescription(['final weight for gap-filling after ' num2str(i_iter) ' iterations (identical to )']);
  aoP.setT0(aos.t0);
  
  aoPini = ao( fsdata(freqsAvg, Pini * (optData.yNorm^2 * optData.Ts / optData.nData) ) );
  aoPini.setName('initial weight');
  aoPini.setXunits(unit.Hz);
  aoPini.setYunits(aos.yunits^2 * unit('Hz^-1'));
  aoPini.setDescription(['initial weight for gap-filling']);
  aoPini.setT0(aos.t0);
  
  %% creating filled output
  aoGapsFilled = ao( plist('yvals', ( trendCorrection + substitution( optData.y, M, optData.gapsPos)) * optData.yNorm, 'fs', 1/optData.Ts, 'type', 'tsdata' ));
  aoGapsFilled.setName('filled time-series');
  aoGapsFilled.setXunits(unit.seconds);
  aoGapsFilled.setYunits(aos.yunits);
  aoGapsFilled.setDescription(['Filled time-series using the criteiron: ' optData.criterion ]);
  aoGapsFilled.setT0(aos.t0);
  aoGapsFilled.addHistory( getInfo('None'), pl , ao_invars, aos.hist );

    %% creating output windows
  aoWindow = ao( plist('yvals', optData.win, 'fs', 1/optData.Ts, 'type', 'tsdata' ));
  aoWindow.setName('initial window used to evaluate the spectrum');
  aoWindow.setXunits(unit.seconds);
  aoWindow.setT0(aos.t0);
  aoWindow.addHistory( getInfo('None'), pl , ao_invars, aos.hist );
  
  if strcmpi(optData.criterion,'FTest-NoHfWin')
    aoWindowShift = ao( plist('yvals', optData.lfWin, 'fs', 1/optData.Ts, 'type', 'tsdata' ));
  else
    aoWindowShift = ao( plist('yvals', optData.winsShift(:, 1) , 'fs', 1/optData.Ts, 'type', 'tsdata' ));
  end
  aoWindowShift.setName('window used to optimize the spectrum');
  aoWindowShift.setXunits(unit.seconds);
  aoWindowShift.setDescription(['one of the ' num2str(optData.nShifts) ' windows involved in the criterion']);
  aoWindowShift.setT0(aos.t0);
  aoWindowShift.addHistory( getInfo('None'), pl , ao_invars, aos.hist );
  
  %% assigning output
  varargout = {aoGapsFilled, plOut, aoP, aoPini, aoWindow, aoWindowShift};
  
  %%  clearing optData from global workspace
  clear global optData
  
end

%% usefull function to compute the weights from the residual
function [powAvgs, freqsAvg, powStd, sumMat, nFreqsAvg] = computeWeight(Y, M, gapsPos, freqs)
  global optData
  yFilled =  substitution( Y, M, gapsPos);
  if strcmpi(optData.criterion,'FTest-NoHfWin')
    win = optData.lfWin;
  else
    win = optData.win;
  end
  errDft = fft( yFilled .* win, optData.nData);
  errDft = errDft(optData.keepFreqs); % removing aliased frequencies
  pow = imag(errDft).^2 + real(errDft).^2; % power
  
  [freqsAvg, powAvgs, nFreqsAvg, nDofs, sumMat] = ltpda_spsd(freqs, pow, optData.linCoef, optData.logCoef);
  powStd = powAvgs./sqrt(nDofs);
end

%% optimal criterion
function j = optimalCriterion(M)
  global optData
  j = 0;
  yFilled = substitution(optData.y, M,  optData.gapsPos);
  if strcmpi(optData.criterion, 'FTest-NoHfWin')
    errDft = fft( yFilled .* optData.lfWin, optData.nData); % FFT algirthm gets DFT, only a LF window is used here
    errDft = errDft(optData.keepFreqs); % keeping positive frequencies
    pow = imag(errDft).^2 + real(errDft).^2; % PSD of signal
    powSum = optData.sumMat * pow; % binning frequencies as in sPSD
    j = sum( powSum .* optData.powInv ); % summing FTest
  elseif strcmpi(optData.criterion, 'FTest')
    for iiWin=1:numel(optData.nShifts)
      for iiDirection = [0 1] % positive/negative window shift
        errDft = fft( yFilled .* optData.winsShift(:, 2*iiWin-1+iiDirection), optData.nData); % FFT algirthm gets DFT
        errDft = errDft(optData.keepFreqs); % keeping positive frequencies
        pow = imag(errDft).^2 + real(errDft).^2; % PSD of signal
        powSum = optData.sumMat * pow; % binning frequencies as in sPSD
        j = j + sum( powSum .* optData.powInv ) * optData.shiftCounts(iiWin);
      end
    end
  elseif strcmpi(optData.criterion, 'Chi2')
    for iiWin=1:numel(optData.nShifts)
      for iiDirection = [0 1] % positive/negative window shift
        errDft = fft( yFilled .* optData.winsShift(:, 2*iiWin-1+iiDirection), optData.nData); % FFT algirthm gets DFT
        errDft = errDft(optData.keepFreqs); % keeping positive frequencies
        pow = imag(errDft).^2 + real(errDft).^2; % PSD of signal
        powSum = optData.sumMat * pow; % binning frequencies as in sPSD
        normlzChi2Sum = (2*powSum) .* optData.powInv; % divide the sum by the expected average of each terms, so the chi2 is normalized
        logProbaDensities = optData.logProbaDensityFactor + (optData.nFreqsAvg-1).*log(normlzChi2Sum) - normlzChi2Sum/2 ; % here computing log of probability
        j = j - sum(logProbaDensities); % better than taking product of probabilities
      end
    end
  else
    error(['criterion badly specified' optData.criterion])
  end
end

%% function subtituting gaps in time-series
function Y = substitution( Y, M, gapsPos)
  Y(gapsPos) = M;
end

%% Direct solver for "FTest" quadratic criterion
function [M, hessian] = solveProblemFTest( gapsPos, powAvgInv, nFreqsAvg)
  global optData
  computeDuration = 1.3e-8 * 2 * optData.nShifts * numel(gapsPos)^2 * sum(nFreqsAvg);
  display(['expected time for linear solver: ' num2str(computeDuration) 's'])
  gapsPhase = exp( -1i*2*pi * (gapsPos-1)/numel(optData.y) ); % FFT value of a gap sample at base frequency
  nGaps = numel(gapsPos); % number of gaps
  nAvgs = numel(nFreqsAvg); % number of frequency bins
  B = zeros(nGaps,1);
  A = zeros(nGaps,nGaps);
  %% frequency weighted criterion
  for iiWin=1:numel(optData.nShifts) % loop on different shifts for HF window
    for iiDirection = [0 1] % positive/negative window shift
      W = optData.winsShift(:, 2*iiWin-1+iiDirection);
      errDft = fft( optData.y .* W, optData.nData); % FFT algirthm gets DFT
      errDft = errDft(optData.keepFreqs); % keeping positive frequencies
      gapsAmplitude = W(gapsPos); % amplitude of gaps once windowed
      gapsPhaseAtFreq = gapsPhase.^0; % FTF at fundamental : it is only the mean value
      iiFreq = 0; % frequency (before averaging with binning)
      for iiFreqAvg = 1:nAvgs % loop on frequency bins
        BLocal = zeros(nGaps,1);
        ALocal = zeros(nGaps,nGaps);
        for iiFreqInAvg = 1:nFreqsAvg(iiFreqAvg) % loop on frequencies inside frequency bin
          iiFreq = iiFreq + 1; % current frequency index (starting with 1!)
          gapDFT = reshape( gapsAmplitude .* gapsPhaseAtFreq , [nGaps,1]); % DFT of each windowed gap data at the frequency number iiFreq-1
          %           gapDFT = reshape( gapsAmplitude .* gapsPhase.^(iiFreq-1) , [nGaps,1]); % DFT of each windowed gap data at the frequency number iiFreq-1
          gapsPhaseAtFreq = gapsPhaseAtFreq .* gapsPhase; % updating phase for future DFT samples at next frequency
          BLocal = BLocal +  2 * real( gapDFT * conj(errDft(iiFreq)) );
          ALocal = ALocal +  2 * real( gapDFT * gapDFT' );
        end
        B = B + BLocal * powAvgInv(iiFreqAvg);
        A = A + ALocal * powAvgInv(iiFreqAvg);
      end
    end
  end
  M = (-pinv(A)*B) .'; % solving least-square problem A*M+B=0
  hessian = A; % this is also the hessian of my criterion
end

%% Direct solver for "FTest" quadratic criterion with no windowing on each gap
function [M, hessian] = solveProblemFTestNoHFWin( gapsPos, powAvgInv, nFreqsAvg)
  global optData
  computeDuration = 1.3e-8 * numel(gapsPos)^2 * sum(nFreqsAvg);
  display(['expected time for linear solver: ' num2str(computeDuration) 's'])
  gapsPhase = exp( -1i*2*pi * (gapsPos-1)/numel(optData.y) ); % FFT value of a gap sample at base frequency
  nGaps = numel(gapsPos); % number of gaps
  nAvgs = numel(nFreqsAvg); % number of frequency bins
  B = zeros(nGaps,1);
  A = zeros(nGaps,nGaps);
  %% frequency weighted criterion
  if strcmpi(optData.criterion, 'FTest-NoHfWin') % retrieving corresponding window
    W = optData.lfWin;
  else
    W = optData.winsShift(:, 2*iiWin-1+iiDirection);
  end
  errDft = fft( optData.y .* W, optData.nData); % FFT algirthm gets DFT
  errDft = errDft(optData.keepFreqs); % keeping positive frequencies
  gapsAmplitude = W(gapsPos); % amplitude of gaps once windowed
  gapsPhaseAtFreq = gapsPhase.^0; % FTF at fundamental : it is only the mean value
  iiFreq = 0; % frequency (before averaging with binning)
  for iiFreqAvg = 1:nAvgs % loop on frequency bins
    BLocal = zeros(nGaps,1);
    ALocal = zeros(nGaps,nGaps);
    for iiFreqInAvg = 1:nFreqsAvg(iiFreqAvg) % loop on frequencies inside frequency bin
      iiFreq = iiFreq + 1; % current frequency index (starting with 1!)
      gapDFT = reshape( gapsAmplitude .* gapsPhaseAtFreq , [nGaps,1]); % DFT of each windowed gap data at the frequency number iiFreq-1
      %           gapDFT = reshape( gapsAmplitude .* gapsPhase.^(iiFreq-1) , [nGaps,1]); % DFT of each windowed gap data at the frequency number iiFreq-1
      gapsPhaseAtFreq = gapsPhaseAtFreq .* gapsPhase; % updating phase for future DFT samples at next frequency
      BLocal = BLocal +  2 * real( gapDFT * conj(errDft(iiFreq)) );
      ALocal = ALocal +  2 * real( gapDFT * gapDFT' );
    end
    B = B + BLocal * powAvgInv(iiFreqAvg);
    A = A + ALocal * powAvgInv(iiFreqAvg);
  end
  M = (-pinv(A)*B) .'; % solving least-square problem A*M+B=0
  hessian = A; % this is also the hessian of my criterion
end

%% function computing the high-frequency window and all its shifted components
function [shiftVals, shiftCounts, winHF, winsHfShift] = makeHFWindows(ndata, gapsPos)
  gapsPos = [1; gapsPos; ndata];
  diffGapsPos = diff(gapsPos); % distance between consecutive gaps
  %% detecting segments and corresponding lengths
  beginSegments  = gapsPos([diffGapsPos>1; false])+1;
  endSegments    = gapsPos([false; diffGapsPos>1])-1;
  segmentsLength = endSegments-beginSegments+1;
  %% statitstics on segment (half) length
  timeShifts = floor(segmentsLength/2); % windows will be shifted by +/- half a segment
  [shiftCounts, shiftVals] = hist(timeShifts, 1:ndata);
  shiftVals = shiftVals(shiftCounts>0);
  shiftCounts = shiftCounts(shiftCounts>0);
  %% making main window
  winHF = zeros(ndata,1);
  for iiSegment=1:numel(segmentsLength) % a window for each segment
    phaseLocal = linspace(0, 2*pi, segmentsLength(iiSegment)+2).'; % building phase vector
    winLocal = 0.5 * (1 - cos(phaseLocal)); % making window
    winHF(beginSegments(iiSegment):endSegments(iiSegment)) = winLocal( 2:end-1 ); % assigning window to corresponding segment
  end
  %% making all time-shifted windows
  winsHfShift = zeros( ndata, 2*numel(shiftVals) );
  for iiShift=1:numel(shiftVals)
    winsHfShift(:, 2*iiShift-1) = circshift(winHF, shiftVals(iiShift)).';
    winsHfShift(:, 2*iiShift) = circshift(winHF, -shiftVals(iiShift)).';
  end
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
  
  pl = plist();
  
  % isgap
  p = param({'isgap', ['Logical ao giving position of gaps. If not<br>'...
    'specified, gaps are positionned where there are zeros.']}, {1, {'zeros', ao}, paramValue.SINGLE});
  pl.append(p);
  
  % large scale or small scale algorithm?
  p = param({'scale', 'large scale or small scale algorithm'}, {1, {'large scale', 'small scale'}, paramValue.SINGLE});
  pl.append(p);
  
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
  
  p = param({ 'lincoef' , 'linear coefficient for scaling frequencies in chi2'}, 20 );
  pl.append(p);
  
  p = param({ 'logcoef' , 'logarithmic coefficient for scaling frequencies in chi2'},  0.0 );
  pl.append(p);
  
  p = param({'fitCriterion' , 'criterion to fit the amplitude spectra (increasing quality, increasing time)'}, {2, {'FTest-NoHfWin' 'FTest' 'chi2'}, paramValue.SINGLE});
  pl.append(p);
  
  % iterations convergence stop criterion  
  p = param({ 'iterMax' , 'max number of Mex/Exp iterations (only makes sense for "FTest-NoHfWin" fitting criteiron)'},  1 );
  pl.append(p);
  
  p = param({ 'normCoefs' , 'tolerance on inf norm of coefficient update '},  1e-12 );
  pl.append(p);
  
  p = param({ 'normCriterion' , 'tolerance on norm of criterion variation'},  1e-5 );
  pl.append(p);
  
  % windowing options
  p = param({ 'win' , 'window to operate FFT, may be a plist/ao'},  plist('win', 'levelledHanning', 'PSLL', 200, 'levelOrder', 2 ) );
  pl.append(p);
  
  % display
  p = param({ 'display' , 'choose how much to display of the optimizer output'},  {1, {'off', 'iter', 'final'}, paramValue.SINGLE} );
  pl.append(p);
  
  % optimizer options
  p = param({ 'maxcall' , 'maximum number of calls to the criterion function'},  50000 );
  pl.append(p);
  
end
