% TDFIT fit a set of smodels to a set of input and output signals..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TDFIT fit a set of smodels to a set of input and output signals. 
% 
%
% CALL:        b = tdfit(outputs, pl)
%
% INPUTS:      outputs  - the AOs representing the outputs of a system.
%              pl       - parameter list (see below)
%
% OUTPUTs:     b  - a pest object containing the best-fit parameters,
%                   goodness-of-fit reduced chi-squared, fit degree-of-freedom
%                   covariance matrix and uncertainties. Additional
%                   quantities, like the Information Matrix, are contained 
%                   within the procinfo. The best-fit model can be evaluated
%                   from pest\eval.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'tdfit')">Parameters Description</a>
%
% EXAMPLES:
%
% % 1) Sine-wave stimulus of a simple system
% 
%   % Sine-wave data
%   data = ao(plist('tsfcn', 'sin(2*pi*3*t) + 0.01*randn(size(t))', 'fs', 100, 'nsecs', 10));
%   data.setName;
% 
%   % System filter
%   pzm = pzmodel(1, 1, 10);
%   f = miir(pzm);
% 
%   % Make output signal
%   dataf = filter(data, f);
%   dataf.setName;
% 
%   % fit model to output
%   mdl = smodel('(a.*(b + 2*pi*i*f)) ./ (b*(a + 2*pi*i*f))');
%   mdl.setParams({'a', 'b'}, {2*pi 10*2*pi});
%   mdl.setXvar('f');
%   params = tdfit(dataf, plist('inputs', data, 'models', mdl, 'P0', [1 1]));
% 
%   % Evaluate fit
%   mdl.setValues(params);
%   BestModel = fftfilt(data, mdl);
%   BestModel.setName;
%   iplot(data, dataf, BestModel, plist('linestyles', {'-', '-', '--'}))
% 
%   % recovered parameters (in Hz)
%   params.y/2/pi
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     'WhiteningFilters'  - Use filter banks for whitening the outputs. 
%                           Note: you must fit the two channels at the same time 
%                           and supply four filter banks.  


function varargout = tdfit(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pl, pl_invars, rest] = utils.helper.collect_objects(rest, 'plist', in_names);
    
  if nargout == 0
    error('### tdfit cannot be used as a modifier. Please give an output variable.');
  end
    
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  outputs = copy(as,1);
  
  % Extract necessary parameters
  inputs    = pl.find_core('inputs');
  TFmodels  = pl.find_core('models');
  WhFlts    = pl.find_core('WhFlts');
  Ncut      = pl.find_core('Ncut');
  P0        = pl.find_core('P0');
  pnames    = pl.find_core('pnames');
  inNames   = pl.find_core('innames');
  outNames  = pl.find_core('outnames');
%   ADDP      = find_core(pl, 'ADDP');
  userOpts  = pl.find_core('OPTSET');
  weights   = find_core(pl, 'WEIGHTS');
  FitUnc    = pl.find_core('FitUnc');
  UncMtd    = pl.find_core('UncMtd');
  linUnc    = pl.find_core('linUnc');
  FastHess  = pl.find_core('FastHess');
  SymDiff   = pl.find_core('SymDiff');
  DiffOrder = pl.find_core('DiffOrder');
  lb        = pl.find_core('LB');
  ub        = pl.find_core('UB');
  MCsearch  = pl.find_core('MonteCarlo');
  Npoints   = pl.find_core('Npoints');
  Noptims   = pl.find_core('Noptims');
  Algorithm = pl.find_core('Algorithm');
  padRatio  = pl.find_core('PadRatio');
  SISO      = pl.find_core('SingleInputSingleOutput');
  GradSearch= pl.find_core('GradSearch');
  estimator = pl.find_core('estimator');
  diffStep  = pl.find_core('diffStep');
  resample_filter = pl.find_core('Resample filter');
  modelFS     = find_core(pl, 'Model FS');
  
  % Convert yes/no, true/false, etc. to booleans
  FitUnc      = utils.prog.yes2true(FitUnc);
  linUnc      = utils.prog.yes2true(linUnc);
  MCsearch    = utils.prog.yes2true(MCsearch);
  SymDiff     = utils.prog.yes2true(SymDiff);
  SISO        = utils.prog.yes2true(SISO);
  GradSearch  = utils.prog.yes2true(GradSearch);
  
  % priority for fit uncertainties
  if FitUnc==0
    linUnc=0;
    SymDiff=0;
  end
   
  % consistency check on inputs
  if isempty(TFmodels)
    error('### please specify at least a transfer function or a SSM model')
  end
  if isempty(inputs)
    error('### please give the inputs of the system')
  end
  if isempty(outputs)
    error('### please give the outputs of the system')
  end
%   if isempty(pnames) || ~iscellstr(pnames)
%     error('### please give the parameter names in a cell-array of strings')
%   end

  % look for aliases within the models
  if ~isa(TFmodels,'ssm')
    aliasNames = TFmodels(1).aliasNames;
    aliasValues = TFmodels(1).aliasValues;
    for ii=2:numel(TFmodels)
      if ~isempty(TFmodels(ii).aliasNames)
        aliasNames = union(aliasNames,TFmodels(ii).aliasNames);
      end
    end
    if ~isempty(aliasNames)
      for kk=1:numel(aliasNames)
        for ii=1:numel(TFmodels)
          ix = strcmp(TFmodels(ii).aliasNames,aliasNames{kk});
          if sum(ix)==0
            continue;
          else
            aliasValues{kk} = TFmodels(ii).aliasValues{ix};
          end
        end
      end
    end
  end

  % common params set
  if isa(TFmodels, 'smodel')
    [TFmodels,pnames,P0] = cat_mdls(TFmodels,pnames,P0);
  elseif isa(TFmodels, 'matrix')
    [TFmodels,pnames,P0] = cat_mdls(TFmodels.objs,pnames,P0);
  end
  
%   if isempty(P0) || ~isnumeric(P0) && ~MCsearch
%     if isa(TFmodels, 'smodel')
%       if ~isempty(TFmodels(1).values)
%         P0 = TFmodels.values;
%         P0 = cell2mat(P0);
%         if numel(P0)~=numel(TFmodels(1).params)
%           error('### numbers of parameter values and names do not match')
%         end
%       else
%         error('### please give the initial guess in a numeric array')
%       end
%     end
%     if isa(TFmodels, 'matrix')
%       if ~isempty(TFmodels.objs(1).values)
%         P0 = TFmodels.objs(1).values;
%         P0 = cell2mat(P0);
%         if numel(P0)~=numel(TFmodels.objs(1).params)
%           error('### numbers of parameter values and names do not match')
%         end
%       else
%         error('### please give the initial guess in a numeric array')
%       end
%     end
%   end
  if ~isnumeric(lb) || ~isnumeric(ub)
    error('### please give lower and upper bounds in a numeric array')
  end
  if numel(lb)~=numel(ub)
    error('### please give lower and upper bounds of the same length')
  end
  if isa(TFmodels, 'smodel')
    pnames = TFmodels(1).params;
    Np = numel(pnames);
%     for kk=2:numel(TFmodels)
%       if numel(TFmodels(kk).params)~=Np
%         error('### number of parameters must be the same for all transfer function models')
%       end
%       if ~strcmp(TFmodels(kk).params,pnames)
%         error('### all transfer function models must have the same parameters')
%       end
%     end
  end
  if isa(TFmodels, 'matrix')
    pnames = TFmodels.objs(1).params;
    Np = numel(pnames);
    for kk=2:(TFmodels.nrows*TFmodels.ncols)
      if numel(TFmodels.objs(kk).params)~=Np
        error('### number of parameters must be the same for all transfer function models')
      end
      if ~strcmp(TFmodels.objs(kk).params,pnames)
        error('### all transfer function models must have the same parameters')
      end
    end
  end
  if isa(TFmodels, 'ssm') && isempty(pnames)
    pnames = getKeys(TFmodels.params);
    Np = numel(pnames);
  end
  
  % check TFmodels, inputs and outputs
  Nin = numel(inputs);
  Nout = numel(outputs);
  NTFmodels = numel(TFmodels);
  if isa(TFmodels, 'smodel') & size(TFmodels)~=[Nout,Nin]
    error('### the size of the transfer function does not match with the number of inputs and outputs')
  end
  if size(inputs)~=[Nin,1]
    inputs = inputs';
  end
  if size(outputs)~=[Nout,1]
    outputs = outputs';
  end
  
  % checks on inputs and outputs consistency
  inLen = inputs(1).len;
  inXdata = inputs(1).x;
  inFs = inputs(1).fs;
  for kk=2:Nin
    if inputs(kk).len~=inLen
      error('### all inputs must have the same length')
    end
    if length(inputs(kk).x)~=length(inXdata)
      error('### x-fields of all inputs must be the same')
    end
    if inputs(kk).fs~=inFs
      error('### fs-fields of all inputs must be the same')
    end
  end
  outLen = outputs(1).len;
  outXdata = outputs(1).x;
  outFs = outputs(1).fs;
  for kk=2:Nout
    if outputs(kk).len~=outLen
      error('### all outputs must have the same length')
    end
    if length(outputs(kk).x)~=length(outXdata)
      error('### x-fields of all outputs must be the same')
    end
    if outputs(kk).fs~=outFs
      error('### fs-fields of all outputs must be the same')
    end
  end
  if inLen~=outLen
    error('### inputs and outputs must have the same length')
  end
  if inXdata~=outXdata
    error('### x-fields of inputs and outputs must be the same')
  end
  if inFs~=outFs
    error('### fs-fields of inputs and outputs must be the same')
  end
  
  % check Whitening Filters
  Wf = ~isempty(WhFlts);
  Nwf = numel(WhFlts);
  if Wf
    if isempty(Ncut)
      Ncut = 100;
    end
    for ii=1:numel(WhFlts)
      if ~(isa(WhFlts(ii),'matrix')||isa(WhFlts(ii),'filterbank'))
        error('### whitening filters must be array of matrix or filterbank class')
      end
    end
    if Nwf~=Nout % size(WhFlts)~=[Nout,Nout]
      error('### the size of the whitening filter array does not match with the number of outputs to be filtered')
    end
    % extract poles and residues
    B = cell(Nout,1); % cell(Nout,Nin);
    A = B;
    for ii=1:Nwf
      if isa(WhFlts(ii),'matrix')
        Nflt = max(WhFlts(ii).osize);
      elseif isa(WhFlts(ii),'filterbank')
        Nflt = numel(WhFlts(ii).filters);
      end
      B{ii} = zeros(Nflt,1);
      A{ii} = B{ii};
      for jj=1:Nflt
        if isa(WhFlts(ii),'matrix')
          B{ii}(jj) = WhFlts(ii).objs(jj).b(2);
          A{ii}(jj) = WhFlts(ii).objs(jj).a(1);
        elseif isa(WhFlts(ii),'filterbank')
          B{ii}(jj) = WhFlts(ii).filters(jj).b(2);
          A{ii}(jj) = WhFlts(ii).filters(jj).a(1);
        end
      end
    end
  end

 
  % Number of data before padding
  Ndata = inLen;
  fs = inFs;
%   nsecs = Ndata/fs;
  
  % Extract inputs
  inYdata = inputs.y;
  if size(inYdata)~=[inLen,Nin]
    inYdata = inYdata';
  end
  outYdata = outputs.y;
  if size(outYdata)~=[outLen,Nout]
    outYdata = outYdata';
  end
  
  
  if isa(TFmodels, 'smodel') || isa(TFmodels, 'matrix')
    
    % Zero-pad inputs before parameter estimation.
    % Pad-ratio is defined as the ratio between the number of zero-padding
    % points and the data length

    if ~isempty(padRatio)
      if ~isnumeric(padRatio)
        error('### please give a numeric pad ratio')
      else
        if padRatio~=0
          Npad = round(padRatio * inLen);
        else
          Npad = 0;
        end
      end
    else
      Npad = 0;
    end

    NdataPad = Ndata + Npad;
    Nfft = NdataPad; % 2^nextpow2(NdataPad);
    Npad = Nfft - Ndata;

    zeroPad = zeros(Npad,Nin);
    inYdataPad = [inYdata;zeroPad];

    % Fft inputs
    inFfts = fft(inYdataPad,Nfft);
    % zero through fs/2
  %   inFfts = inFfts(1:Nfft/2+1,:);

    % Sample TFmodels on fft-frequencies
    % zero through fs
    ff = (0:(Nfft-1))'.*fs./Nfft;
    % zero through fs/2
  %   ff = [0:(Nfft/2)]'.*fs/(Nfft/2+1);
  %   ff = fs/2*linspace(0,1,Nfft/2+1)';
    for kk=1:NTFmodels
      TFmodels(kk).setXvar('f');
      TFmodels(kk).setXvals(ff);
    end
    
    % set values for aliases
    if ~isempty(aliasNames)
      for kk=1:numel(aliasNames)
        aliasValues{kk}.setXvar('f');
        aliasValues{kk}.setXvals(ff);
      end
    end
    % assign aliases to variables
    aliasTrue = 0;
    if ~isempty(aliasNames)
      alias = cell(numel(aliasNames),1);
      for kk=1:numel(aliasNames)
        alias{kk} = aliasValues{kk}.double;
%         assignin('caller',aliasNames{kk},aliasValues{kk}.double);
      end
      aliasTrue = 1;
    end

    % Extract function_handles from TFmodels
    TFmodelFuncs = cell(size(TFmodels));
    for ii=1:NTFmodels
  %     TFmodelFuncs{ii} = TFmodels(ii).fitfunc;
  %     TFmodelFuncs{ii} =
  %     @(x)eval_mdl(TFmodels(ii).expr.s,TFmodels(ii).xvar,TFmodels(ii).xvals,TFmodels(ii).params,x);
      fcnstr = doSubsPnames(TFmodels(ii).expr.s,TFmodels(ii).params);
      if aliasTrue
        fcnstr = doSubsAlias(fcnstr,aliasNames);
        TFmodelFuncs{ii} = ...
          eval_mdl_alias(fcnstr,TFmodels(ii).xvar{1},TFmodels(ii).xvals{1},alias);
      else
        TFmodelFuncs{ii} = ...
          eval_mdl(fcnstr,TFmodels(ii).xvar{1},TFmodels(ii).xvals{1});
      end
    end
  
  end
  
  % If requested, compute the analytical gradient
  if SymDiff || linUnc && (isa(TFmodels, 'smodel') || isa(TFmodels, 'matrix'))
    % compute symbolic 1st-order differentiation
    TFmodelDFuncsSmodel = cell(numel(pnames),1);
    for ll=1:numel(pnames)
      for ss=1:size(TFmodels,1)
        for tt=1:size(TFmodels,2)
          TFmodelDFuncsSmodel{ll}(ss,tt) = diff(TFmodels(ss,tt),pnames{ll});
        end
      end
    end
    % extract anonymous function
    TFmodelDFuncs = cell(numel(pnames),1);
    for ll=1:numel(pnames)
      TFmodelDFuncs{ll} = cell(size(TFmodels));
      for ii=1:NTFmodels
        if ~isempty(TFmodelDFuncsSmodel{ll})
          fcnstr = doSubsPnames(TFmodelDFuncsSmodel{ll}(ii).expr.s,TFmodelDFuncsSmodel{ll}(ii).params);
          if aliasTrue
            fcnstr = doSubsAlias(fcnstr,aliasNames);
            TFmodelDFuncs{ll}{ii} = ...
              eval_mdl_alias(fcnstr,TFmodelDFuncsSmodel{ll}(ii).xvar{1},TFmodelDFuncsSmodel{ll}(ii).xvals{1},alias);
          else
            TFmodelDFuncs{ll}{ii} = ...
              eval_mdl(fcnstr,TFmodelDFuncsSmodel{ll}(ii).xvar{1},TFmodelDFuncsSmodel{ll}(ii).xvals{1});
          end
        else
          TFmodelDFuncs{ll}{ii} = @(x)0;
        end
      end
    end
    if DiffOrder==2
      % compute symbolic 2nd-order differentiation
      TFmodelHFuncsSmodel = cell(numel(pnames));
%       for ii=1:NTFmodels
%         p = TFmodels(ii).params;
        for mm=1:numel(pnames)
          for ll=1:mm
            for ss=1:size(TFmodels,1)
              for tt=1:size(TFmodels,2)
                TFmodelHFuncsSmodel{ll,mm}(ss,tt) = diff(TFmodelDFuncsSmodel{ll}(ss,tt),pnames{mm});
              end
            end
          end
        end
%       end
      % extract anonymous function
      TFmodelHFuncs = cell(numel(pnames));
      for mm=1:numel(pnames)
        for ll=1:mm
          TFmodelHFuncs{ll,mm} = cell(size(TFmodels));
          for ii=1:NTFmodels
            if ~isempty(TFmodelHFuncsSmodel{ll,mm})
%               TFmodelHFuncs{ll,mm}{ii} = TFmodelHFuncsSmodel{ii}(ll,mm).fitfunc; % inverted indexes are for practicalities
              fcnstr = doSubsPnames(TFmodelHFuncsSmodel{ll,mm}(ii).expr.s,TFmodelHFuncsSmodel{ll,mm}(ii).params);
              if aliasTrue
                fcnstr = doSubsAlias(fcnstr,aliasNames);
                TFmodelHFuncs{ll,mm}{ii} = ...
                  eval_mdl_alias(fcnstr,TFmodelHFuncsSmodel{ll,mm}(ii).xvar{1},TFmodelHFuncsSmodel{ll,mm}(ii).xvals{1},alias);
              else
                TFmodelHFuncs{ll,mm}{ii} = ...
                  eval_mdl(fcnstr,TFmodelHFuncsSmodel{ll,mm}(ii).xvar{1},TFmodelHFuncsSmodel{ll,mm}(ii).xvals{1});
              end
            else
              TFmodelHFuncs{ll,mm}{ii} = @(x)0;
            end
          end
        end
      end
    end
  end
  
  % Build index for faster computation
  
  if isa(TFmodels,'smodel')
    TFidx = compIdx(inYdata, Nout, TFmodels);
  end
  if exist('TFmodelDFuncsSmodel','var')
    TFDidx = cell(numel(pnames),1);
    for ll=1:numel(pnames)
      TFDidx{ll} = compIdx(inYdata, Nout, TFmodelDFuncsSmodel{ll});
    end
  end
  if exist('TFmodelHFuncsSmodel','var')
    TFHidx = cell(numel(pnames));
    for mm=1:numel(pnames)
      for ll=1:mm
        TFHidx{ll,mm} = compIdx(inYdata, Nout, TFmodelHFuncsSmodel{ll,mm});
      end
    end
  end
 
    
  % Construct the output function handles from TFmodels as funtion of
  % parameters
%   if ~Wf
    outModelFuncs = cell(Nout,1);
%     if Nout>1
    if isa(TFmodels, 'smodel') || isa(TFmodels, 'matrix')
      for ii=1:Nout
        if SISO
          outModelFuncs{ii} = @(x)mdl_fftfilt_SISO(x, inFfts(:,ii), TFmodelFuncs{ii}, Npad);
        else
%           outModelFuncs{ii} = @(x)mdl_fftfilt(x, ii, inFfts, TFmodelFuncs, Npad);
          outModelFuncs{ii} = @(x)mdl_fftfilt2(x, ii, inFfts, size(inFfts), TFmodelFuncs, TFidx, Npad);
        end
      end
    elseif isa(TFmodels, 'ssm')        
      for ii=1:Nout
        if ~isempty(modelFS) && modelFS~=fs
          inputs(ii) = resample(inputs(ii),plist('fsout',modelFS,'filter',resample_filter));
        else
          modelFS = fs;
        end
        plsym = plist('return outputs', outNames{ii}, ...
                    'AOS VARIABLE NAMES', inNames{ii}, ...
                    'AOS', inputs(ii));
        outModelFuncs{ii} = @(x)mdl_ssm(x, pnames, TFmodels, plsym, modelFS, fs, resample_filter);
      end
      
      % build ssm derivatives
      if FitUnc
        outModelDFuncs = cell(numel(pnames),1);
        for ll=1:numel(pnames)
          outModelDFuncs{ll} = cell(Nout,1);
          for ii=1:Nout
            plsym = plist('return outputs', outNames{ii}, ...
                    'AOS VARIABLE NAMES', inNames{ii}, ...
                    'AOS', inputs(ii));
            outModelDFuncs{ll}{ii} = @(x)mdl_ssm_der(x, pnames, TFmodels, plsym, modelFS, fs, resample_filter, pnames{ll}, diffStep(ll));
          end
        end
      end
        
      
    end
%     else
%       outModelFuncs{1} = @(x)mdl_fftfilt(x, ii, inFfts, TFmodelFuncs, Npad);
%     end
%   end
  
  % In case of symbolic differentiation, construct the output derivatives
  if SymDiff || linUnc && (isa(TFmodels, 'smodel') || isa(TFmodels, 'matrix'))
    outModelDFuncs = cell(numel(pnames),1);
    for ll=1:numel(pnames)
      outModelDFuncs{ll} = cell(Nout,1);
      for ii=1:Nout
        if SISO
          outModelDFuncs{ll}{ii} = @(x)mdl_fftfilt_SISO(x, inFfts(:,ii), TFmodelDFuncs{ll}{ii}, Npad);
        else
%           outModelDFuncs{ll}{ii} = @(x)mdl_fftfilt(x, ii, inFfts, TFmodelDFuncs{ll}, Npad);
          outModelDFuncs{ll}{ii} = @(x)mdl_fftfilt2(x, ii, inFfts, size(inFfts), TFmodelDFuncs{ll}, TFDidx{ll}, Npad);
        end
      end
    end
    if DiffOrder==2
      outModelHFuncs = cell(numel(pnames));
      for mm=1:numel(pnames)
        for ll=1:mm
          outModelHFuncs{ll,mm} = cell(Nout,1);
          for ii=1:Nout
            if SISO
              outModelHFuncs{ll,mm}{ii} = @(x)mdl_fftfilt_SISO(x, inFfts(:,ii), TFmodelFuncs{ll,mm}{ii}, Npad);
            else
%               outModelHFuncs{ll,mm}{ii} = @(x)mdl_fftfilt(x, ii, inFfts, TFmodelHFuncs{ll,mm}, Npad);
              outModelHFuncs{ll,mm}{ii} = @(x)mdl_fftfilt2(x, ii, inFfts, size(inFfts), TFmodelHFuncs{ll,mm}, TFHidx{ll,mm}, Npad);
            end
          end
        end
      end
    end
  end
  
  % In case the whitening filters are provided do a filtering both on
  % models and data
  if Wf
    % filter models
    outModelFuncs_w = cell(Nout,1);
    for ii=1:Nout
%       outModelFuncs_w{ii} = @(x)filter_mdl(x, B, A, outModelFuncs{ii}, Ncut);
%       outModelFuncs_w{ii} = @(x)mdl_fftfilt_wf(x, ii, inFfts, TFmodelFuncs, Npad, B, A, Ncut);
      % off-diagonal
%       outModelFuncs_w{ii} = @(x)mdl_fftfilt_wf(x, ii, outModelFuncs, B, A, Ncut);
      % diagonal
      outModelFuncs_w{ii} = @(x)filter_mdl2(x, B{ii}, A{ii}, outModelFuncs{ii}, Ncut);
    end
    % filter model derivatives
    if SymDiff || linUnc % || (isa(TFmodels, 'ssm') && FitUnc)
      % whitening 1st derivatives
      outModelDFuncs_w = cell(numel(pnames),1);
      for ll=1:numel(pnames)
        outModelDFuncs_w{ll} = cell(Nout,1);
        for ii=1:Nout
          % off-diagonal
%           outModelDFuncs_w{ll}{ii} = @(x)mdl_fftfilt_wf(x, ii, outModelDFuncs{ll}, B, A, Ncut);
          % diagonal
          outModelDFuncs_w{ll}{ii} = @(x)filter_mdl2(x, B{ii}, A{ii}, outModelDFuncs{ll}{ii}, Ncut);
        end
      end
      if DiffOrder==2
        % whitening 2nd derivatives
        outModelHFuncs_w = cell(numel(pnames));
        for mm=1:numel(pnames)
          for ll=1:mm
            outModelHFuncs_w{ll,mm} = cell(Nout,1);
            for ii=1:Nout
              % off-diagonal
    %           outModelDFuncs_w{ll}{ii} = @(x)mdl_fftfilt_wf(x, ii, outModelDFuncs{ll}, B, A, Ncut);
              % diagonal
              outModelHFuncs_w{ll,mm}{ii} = @(x)filter_mdl2(x, B{ii}, A{ii}, outModelHFuncs{ll,mm}{ii}, Ncut);
            end
          end
        end
      end
    end
    % filter data
    outYdata_w = zeros(size(outYdata));
    outYdata_w(1:Ncut,:) = [];
    % off-diagonal
%     for ii=1:Nout
%       for jj=1:Nout
%         outYdata_w(:,ii) = outYdata_w(:,ii) + filter_data(B{ii,jj}, A{ii,jj}, outYdata(:,jj), Ncut);
%       end
%     end
    % diagonal
    for ii=1:Nout
      outYdata_w(:,ii) = filter_data(B{ii}, A{ii}, outYdata(:,ii), Ncut);
    end
    % set filtered values to pass to xfit
    for ii=1:Nout
%       outputs(ii).setY(outYdata_w(:,ii));
      outputs(ii) = ao(plist('yvals',outYdata_w(:,ii)));
    end
  end
  
  % set the proper function to pass to xfit
  if Wf
    outModelFuncs_4xfit = outModelFuncs_w;
  else
    outModelFuncs_4xfit = outModelFuncs;
  end
  if SymDiff || linUnc
      % 1st derivatives
      outModelDFuncs_4xfit = cell(Nout,1);
      for ii=1:Nout
        outModelDFuncs_4xfit{ii} = cell(numel(pnames),1);
        for ll=1:numel(pnames)
          if Wf
            outModelDFuncs_4xfit{ii}{ll} = outModelDFuncs_w{ll}{ii};
          else
            outModelDFuncs_4xfit{ii}{ll} = outModelDFuncs{ll}{ii};
          end
        end
      end
      if DiffOrder==2
        % 2nd derivatives
        outModelHFuncs_4xfit = cell(Nout,1);
        for ii=1:Nout
          outModelHFuncs_4xfit{ii} = cell(numel(pnames));
          for mm=1:numel(pnames)
            for ll=1:mm
              if Wf
                outModelHFuncs_4xfit{ii}{ll,mm} = outModelHFuncs_w{ll,mm}{ii};
              else
                outModelHFuncs_4xfit{ii}{ll,mm} = outModelHFuncs{ll,mm}{ii};
              end
            end
          end
        end
      else
        outModelHFuncs_4xfit = {};
      end
  else
    outModelDFuncs_4xfit = {};
    outModelHFuncs_4xfit = {};
  end
  
  % replicate pnames, P0, LB, UB for xfit
  if Nout>1
    % pnames
    pnames_4xfit = cell(1,Nout);
    for ii=1:Nout
      pnames_4xfit{ii} = pnames;
    end
    % P0
    P0_4xfit = cell(1,Nout);
    for ii=1:Nout
      P0_4xfit{ii} = P0;
    end
    % LB
    if ~isempty(lb)
      lb_4xfit = cell(1,Nout);
      for ii=1:Nout
        lb_4xfit{ii} = lb;
      end
    else
      lb_4xfit = [];
    end
    % UB
    if ~isempty(ub)
      ub_4xfit = cell(1,Nout);
      for ii=1:Nout
        ub_4xfit{ii} = ub;
      end
    else
      ub_4xfit = [];
    end
    
  else
    pnames_4xfit = pnames;
    P0_4xfit = P0;
    lb_4xfit = lb;
    ub_4xfit = ub;
  end
  
  
  % do fit with xfit
  fitpl = plist('Function', outModelFuncs_4xfit, ...
    'pnames', pnames_4xfit, 'P0', P0_4xfit, 'LB', lb_4xfit, 'UB', ub_4xfit, ...
    'Algorithm', Algorithm, 'FitUnc', FitUnc, 'UncMtd', UncMtd, 'linUnc', linUnc, 'FastHess', FastHess,...
    'SymGrad', outModelDFuncs_4xfit, 'SymHess', outModelHFuncs_4xfit,...
    'MonteCarlo', MCsearch, 'Npoints', Npoints, 'Noptims', Noptims, ...
    'OPTSET', userOpts, 'estimator', estimator, 'weights', weights);

  % Preliminary Gradient search
  if GradSearch && exist('TFmodelDFuncs','var')
    
    % set new optimization options
    userOpts1 = optimset(userOpts,'GradObj','on','LargeScale','on','FinDiffType','central');
%                          'PrecondBandWidth',0,'TolPCG',1e-4);
    fitpl1 = fitpl.pset('Algorithm','fminunc','OPTSET',userOpts1);
    
    % fit
    params = xfit(outputs, fitpl1);
    
    % update initial guess
    if Nout>1
      P0_4xfit = cell(1,Nout);
      for ii=1:Nout
        P0_4xfit{ii} = params.y;
      end
    else
      P0_4xfit = params.y;
    end
    
    % restore old optimization options
    fitpl = fitpl.pset('Algorithm',Algorithm,'OPTSET',userOpts,'P0',P0_4xfit);
    
    % extract preliminary chain
    chain = params.chain;
  end
  
  % Final search
  params = xfit(outputs, fitpl);

  % Make output pest
  out = copy(params,1);
  
  % Concatenate chains and set it
  if exist('chain','var')
    chain = [chain;params.chain];
    out.setChain(chain);
  end
  
  % Set Name and History
  mdlname = char(TFmodels(1).name);
  for kk=2:NTFmodels
    mdlname = strcat(mdlname,[',' char(TFmodels(kk).name)]);
  end
  out.name = sprintf('tdfit(%s)', mdlname);
  out.setNames(pnames);
  out.addHistory(getInfo('None'), pl, ao_invars(:), [as(:).hist]);
   
  % Set outputs
  if nargout > 0
    varargout{1} = out;
  end
end

%--------------------------------------------------------------------------
% Included Functions
%--------------------------------------------------------------------------

function outYdata = mdl_fftfilt(P, outIdx, inFfts, TFmdl, Npad)
  
  sz = size(inFfts);
  outFfts = zeros(sz);
  for ii=1:sz(2)
    outFfts(:,ii) = inFfts(:,ii).*TFmdl{outIdx,ii}(P);
  end
  outFfts = sum(outFfts,2);
  outYdata = ifft(outFfts(:,1), 'symmetric');
  outYdata(end-Npad+1:end,:) = [];
    
end

%--------------------------------------------------------------------------

function outYdata = mdl_fftfilt2(P, outIdx, inFfts, sz, TFmdl, TFidx, Npad)
  
  TFeval = zeros(sz);
  for ii=1:sz(2)
    if TFidx(outIdx,ii)
      TFeval(:,ii) = TFmdl{outIdx,ii}(P);
    end
  end
  outFfts = inFfts.*TFeval;
  outFfts = sum(outFfts,2);
  outYdata = ifft(outFfts(:,1), 'symmetric');
  outYdata(end-Npad+1:end,:) = [];
    
end

%--------------------------------------------------------------------------

function idx = compIdx(inYdata, Nout, mdl)

  % what inputs are actually different from zero
  b = any(inYdata);
  b = repmat(b,Nout,1);
  % what transfer functions are actually different from zero
  sz = size(mdl);
  a = zeros(sz);
  for ii=1:numel(mdl)
    a(ii) = ~(strcmp(mdl(ii).expr.s,'[]') || strcmp(mdl(ii).expr.s,'0') || strcmp(mdl(ii).expr.s,'0.0'));
  end
  % index for computation
  idx = logical(a.*b);
  
end

%--------------------------------------------------------------------------

function outYdata = mdl_fftfilt_SISO(P, inFfts, TFmdl, Npad)
  
%   sz = size(inFfts);
%   outFfts = zeros(sz);
%   parfor ii=1:sz(2)
  outFfts = inFfts.*TFmdl(P);
%   outFfts = sum(outFfts,2);
  outYdata = ifft(outFfts(:,1), 'symmetric');
  outYdata(end-Npad+1:end,:) = [];
    
end

%--------------------------------------------------------------------------

function  outYdata = mdl_ssm(P, pnames, model, plsym, fs, resample_fs, resample_flt)
  
  % substitute parameters
  modelSim = model.doSetParameters(pnames,P);
  modelSim.subsParameters;
  
  % go to numerical
  modelSim.modifyTimeStep(plist('NEWTIMESTEP',1/fs));
    
  % get output
  outYdata = simulate(modelSim,plsym);
  
  % resample if necessary and extract values
  if isempty(resample_fs)
    outYdata = outYdata.objs(1).y;
  elseif resample_fs~=fs
    outYdata = resample(outYdata.objs(1),plist('fsout',resample_fs,'filter',resample_flt));
    outYdata = outYdata.y;
  end
  
end

function  outYdata = mdl_ssm_der(P, pnames, model, plsym, fs, resample_fs, resample_flt, diffParam, diffStep)

  % this is the derivative version
  
  % substitute parameters
  modelSim = model.doSetParameters(pnames,P);
  modelSim.subsParameters;

  % differentiate
  modelSim = parameterDiff(modelSim,plist('names',diffParam,'values',diffStep));
  
  % go to numerical
  modelSim.modifyTimeStep(plist('NEWTIMESTEP',1/fs));
    
  % get output
  outYdata = simulate(modelSim,plsym);
  
  % resample if necessary
  if isempty(resample_fs)
    outYdata = outYdata.objs(1).y;
  elseif resample_fs~=fs
    outYdata = resample(outYdata.objs(1),plist('fsout',resample_fs,'filter',resample_flt));
    outYdata = outYdata.y;
  end
  
end

%--------------------------------------------------------------------------

%--------------------------------------------------------------------------

% function outYdata = Dmdl_fftfilt(P, outIdx, Dix, inFfts, TFmdl, Npad)
%   
%   sz = size(inFfts);
%   outFfts = zeros(sz);
%   for ii=1:sz(2)
%     outFfts(:,ii) = inFfts(:,ii).*TFmdl{outIdx,ii}{Dix}(P);
%   end
%   outFfts = sum(outFfts,2);
%   outYdata = ifft(outFfts(:,1), 'symmetric');
%   outYdata(end-Npad+1:end,:) = [];
%     
% end

%--------------------------------------------------------------------------

% function outYdata = mdl_fftfilt_wf(P, outIdx, inFfts, TFmdl, Npad, B, A, Ncut)
%   
%   sz = size(inFfts);
%   outFfts = zeros(sz);
%   for ii=1:sz(2)
%     outFfts(:,ii) = inFfts(:,ii).*TFmdl{outIdx,ii}(P);
%   end
%   outYdata = ifft(outFfts, 'symmetric');
%   outYdata(end-Npad+1:end,:) = [];
%   for ii=1:sz(2)
%     outYdata_w(:,ii) = filter_data(B{outIdx,ii},A{outIdx,ii},outYdata(:,ii), Ncut);
%   end
%   outYdata = sum(outYdata_w,2);
% 
% %     outYdata_w = zeros(size(outYdata,1),1);
% %     outYdata_w(1:Ncut) = [];
% %     for jj=1:sz(2)
% %       outYdata_w = outYdata_w + filter_data(pol{outIdx,jj}, res{outIdx,jj}, outYdata(:,jj), Ncut);
% %     end
% %     outYdata = sum(outYdata_w,2);  
%     
% end

%--------------------------------------------------------------------------

% function outYdata = mdl_fftfilt_wf(P, outIdx, TFmdl, B, A, Ncut)
%   
%   os = filter_mdl(P, B, A, TFmdl, Ncut);
%   outYdata = os(:,outIdx);
%   
% end

%--------------------------------------------------------------------------

% function os = filter_mdl(P, B, A, oFuncs, Ncut)
%   
%   Nout = numel(oFuncs);
%   for ii=1:Nout
%     Y(:,ii) = oFuncs{ii}(P);
%   end
%   os = zeros(size(Y));
%   os(1:Ncut,:) = [];
%   for ii=1:Nout
%     for jj=1:Nout
%       os(:,ii) = os(:,ii) + filter_data(B{ii,jj}, A{ii,jj}, Y(:,jj), Ncut);
%     end
%   end
%   
% end

%--------------------------------------------------------------------------

% function outYdata = Dmdl_fftfilt_wf(P, outIdx, TFmdl, B, A, Ncut)
%   
%   os = filter_mdl(P, B, A, TFmdl, Ncut);
%   outYdata = os(:,outIdx);
%   
% end

%--------------------------------------------------------------------------

function o = filter_data(B, A, X, Ncut)
  
  N = numel(X);
  M = numel(B);
  Y = zeros(N,M);  
%   parfor ii=1:M
  for ii=1:M
    Y(:,ii) = filter(A(ii),[1 B(ii)],X);
  end    
  o = sum(Y,2);  
  o(1:Ncut) = [];
  
end

%--------------------------------------------------------------------------

function o = filter_mdl2(P, B, A, oFunc, Ncut)
  
  X = oFunc(P);
  N = numel(X);
  M = numel(B);
  Y = zeros(N,M);  
  for ii=1:M
    Y(:,ii) = filter(A(ii),[1 B(ii)],X);
  end    
  o = sum(Y,2);  
  o(1:Ncut) = [];
  
end

%--------------------------------------------------------------------------

function fcn = eval_mdl(str,xvar,xvals)

  fcn = eval(['@(P,',xvar,')(',str,')']);
  fcn = @(x)fcn(x,xvals);  
  
end

%--------------------------------------------------------------------------

function fcn = eval_mdl_alias(str,xvar,xvals,alias)

  fcn = eval(['@(P,',xvar,',alias',')(',str,')']);
  fcn = @(x)fcn(x,xvals,alias);  
  
end
%--------------------------------------------------------------------------

function str = doSubsPnames(str,params)
  
  lengths = zeros(1,numel(params));
  for ii=1:numel(params)
    lengths(ii) = length(params{ii});
  end
  [dummy,ix] = sort(lengths,'descend');
  repstr = cell(1,numel(params));
  for ii=1:numel(params)
    repstr{ii} = ['P(' int2str(ii) ')'];
  end
  str = regexprep(str,params(ix),repstr(ix));
  if isempty(str)
    str = '0';
  end
  
end

%--------------------------------------------------------------------------

function str = doSubsAlias(str,alias)
  
  lengths = zeros(1,numel(alias));
  for ii=1:numel(alias)
    lengths(ii) = length(alias{ii});
  end
  [dummy,ix] = sort(lengths,'descend');
  repstr = cell(1,numel(alias));
  for ii=1:numel(alias)
    repstr{ii} = ['alias{' int2str(ii) '}'];
  end
  str = regexprep(str,alias(ix),repstr(ix));
 
end

%--------------------------------------------------------------------------

function [newMdls,pnames,P0]=cat_mdls(mdls,usedParams,P0)

  pnames = mdls(1).params;

  % union of all parameters
  for ii=2:numel(mdls)
    pnames = union(pnames,mdls(ii).params);
  end
  
  pvalues = cell(1,numel(pnames));
  for kk=1:numel(pnames)
    for ii=1:numel(mdls)
      ix = strcmp(mdls(ii).params,pnames{kk});
      if sum(ix)==0
        continue;
      else
        pvalues{kk} = mdls(ii).values{ix};
      end
    end
  end
  
  % set the used one
  for ii=1:numel(mdls)
    mdls(ii).setParams(pnames,pvalues);
    if ~isempty(usedParams)
      mdls(ii).subs(setdiff(pnames,usedParams));
    else
      usedParams = pnames;
    end
  end
  
  % copy to new models
  for ii=1:size(mdls,1)
    for jj=1:size(mdls,2)
      newMdls(ii,jj) = smodel(plist('expression',mdls(ii,jj).expr,...
        'xvar',mdls(ii,jj).xvar,'xvals',mdls(ii,jj).xvals,...
        'name',mdls(ii,jj).name));
    end
  end
  
  % set the same parameters for all
  for ii=1:numel(newMdls)
    if ~isempty(P0)
      newMdls(ii).setParams(usedParams,P0);
    else
      for kk=1:numel(usedParams)
      ix = strcmp(usedParams(kk),pnames);
      P0(kk) = pvalues{ix};
      end
      newMdls(ii).setParams(usedParams,P0);
    end
  end
  
  pnames = usedParams;

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
  ii.setModifier(false);
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
  
  % Inputs
  p = param({'Inputs', 'An array of input AOs, one per each experiment.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
 
  % Models
  p = param({'Models', 'An array of transfer function SMODELs.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % PadRatio
  p = param({'PadRatio', ['PadRatio is defined as the ratio between the number of zero-pad points '...
    'and the data length.<br>'...
    'Define how much to zero-pad data after the signal.<br>'...
    'Being <tt>tdfit</tt> a fft-based algorithm, no zero-padding might bias the estimation, '...
    'therefore it is strongly suggested to do that.']}, 1);
  pl.append(p);
  
  % Whitening Filters
   p = param({'WhFlts', 'An array of FILTERBANKs containing the whitening filters per each output AO.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Parameters
  p = param({'Pnames', 'A cell-array of parameter names to fit.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
  % P0
  p = param({'P0', 'An array of starting guesses for the parameters.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % LB
  p = param({'LB', ['Lower bounds for the parameters.<br>'...
    'This improves convergency. Mandatory for Monte Carlo.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % UB
  p = param({'UB', ['Upper bounds for the parameters.<br>'...
    'This improves the convergency. Mandatory for Monte Carlo.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Algorithm
  p = param({'ALGORITHM', ['A string defining the fitting algorithm.<br>'...
    '<tt>fminunc</tt>, <tt>fmincon</tt> require ''Optimization Toolbox'' to be installed.<br>'...
    '<tt>patternsearch</tt>, <tt>ga</tt>, <tt>simulannealbnd</tt> require ''Genetic Algorithm and Direct Search'' to be installed.<br>']}, ...
    {1, {'fminsearch', 'fminunc', 'fmincon', 'patternsearch', 'ga', 'simulannealbnd'}, paramValue.SINGLE});
  pl.append(p);

  % OPTSET
  p = param({'OPTSET', ['An optimisation structure to pass to the fitting algorithm.<br>'...
    'See <tt>fminsearch</tt>, <tt>fminunc</tt>, <tt>fmincon</tt>, <tt>optimset</tt>, for details.<br>'...
    'See <tt>patternsearch</tt>, <tt>psoptimset</tt>, for details.<br>'... 
    'See <tt>ga</tt>, <tt>gaoptimset</tt>, for details.<br>'...
    'See <tt>simulannealbnd</tt>, <tt>saoptimset</tt>, for details.']}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % SymDiff
  p = param({'SymDiff', 'Use symbolic derivatives or not. Only for gradient-based algorithm or for LinUnc option.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % DiffOrder
  p = param({'DiffOrder', 'Symbolic derivative order. Only for SymDiff option.'}, {1, {1,2}, paramValue.SINGLE});
  pl.append(p);
  
  % FitUnc
  p = param({'FitUnc', 'Fit parameter uncertainties or not.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % UncMtd
  p = param({'UncMtd', ['Choose the uncertainties estimation method.<br>'...
    'For multi-channel fitting <tt>hessian</tt> is mandatory.']}, {1, {'hessian', 'jacobian'}, paramValue.SINGLE});
  pl.append(p);
  
  % LinUnc
  p = param({'LinUnc', 'Force linear symbolic uncertainties.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % GradSearch
  p = param({'GradSearch', 'Do a preliminary gradient-based search using the BFGS Quasi-Newton method.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % MonteCarlo
  p = param({'MonteCarlo', ['Do a Monte Carlo search in the parameter space.<br>'...
    'Useful when dealing with high multiplicity of local minima. May be computer-expensive.<br>'...
    'Note that, if used, P0 will be ignored. It also requires to define LB and UB.']}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % Npoints
  p = param({'Npoints', 'Set the number of points in the parameter space to be extracted.'}, 100000);
  pl.append(p);
  
  % Noptims
  p = param({'Noptims', 'Set the number of optimizations to be performed after the Monte Carlo.'}, 10);
  pl.append(p);
  
  % SISO
  p = param({'SingleInputSingleOutput', 'Specify whether the model should be considered as Single-Input/Single-Output model. This is for performance.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
end
% END
