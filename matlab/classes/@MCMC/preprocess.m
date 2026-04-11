% MCMC.preprocess.
%
%
% DESCRIPTION: preprocessDataForMCMC: Split, resample and apply FFT to
%                                     time series for MCMC analysis.
%
% CALL:        >> [finputs, foutputs, fnoise] = preprocess(algo, outputs)
%
% INPUTS:         The algorithm and the output data.
%
% OUTPUTS:        The processed inputs, outputs, noise spectrum and the
%                 set of frequencies of the analysis.
%
function [fin, fout, Sn] = preprocess(algo)
  
  import utils.const.*
  
  flim    = algo.params.find('frequencies');
  fsout   = algo.params.find('fsout');
  if ~isempty(algo.inputs)
    inputs  = copy(algo.inputs, 1);
  else
    inputs = algo.inputs;
  end
  noise   = copy(algo.noise, 1);
  f1      = algo.params.find('f1');
  f2      = algo.params.find('f2');
  outputs = algo.outputs;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%   Perform Sanity Checks on inputs  %%%%%%%%%%%%%%%%%%%%%%%%
  
  if isempty(inputs)
    warning('LTPDA:preprocessDataForMCMC','### An input signal was not inserted...')
    inputs     = 1;
    Nin        = 0;
    input_flag = false;
  else
    utils.helper.msg(msg.PROC1, ['Input signal was inserted. ' ...
      'Assuming system identification experiment ...'], mfilename('class'), mfilename);
    % Get # of inputs. The # of outputs is defined later.
    Nin  = numel(inputs(:,1));
    input_flag = true;
  end
  
  if isempty(outputs)
    error('### An output signal was not provided.')
  end
  
  % Get # of experiments
  Nexp = numel(noise(1,:));
  
  % Get # of outputs
  Nout = numel(noise(:,1));
  
  %%%%%%%%%%%%%%%%%%%%% Check inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  if size(outputs) ~= size(noise)
    error('### Parameters ''out'' and ''noise'' must be the same dimension');
  end
  
  if Nexp ~= numel(outputs(1,:)) || Nexp ~= numel(noise(1,:))
    error('### Number of input and output experiments must be the same');
  end
  
  if ~isempty(f1) && ~(isnumeric(f1) && numel(f1) == 1 || iscell(f1) && numel(f1) == Nexp) ...
      && ~isempty(f2) && ~(isnumeric(f2) && numel(f2) == 1 || iscell(f2) && numel(f2) == Nexp)
    error(['### The inputs ''f1'' and ''f2'' must be a number if you want to apply ' ...
      'the same for all experiments, or cell arrays with specific ' ...
      'frequencies for each experiment.'])
  end
  
  if ~isempty(flim) && (~isempty(f1) || ~isempty(f2))
    
    error(['### An array of frequencies to perform the enalysis OR a range of '...
      'frequencies is required. ''f1'' & ''f2'' should be empty if ''frequencies'' is provided.'])
    
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%   Frequency domain pre-process  %%%%%%%%%%%%%%%%%%%%%%%%
  
  utils.helper.msg(msg.PROC1, 'Computing frequency domain objects ... ', mfilename('class'), mfilename);
  
  % Resampling
  if ~isempty(fsout)
    if input_flag
      inputs.resample(plist('fsout',fsout));
    end
    outputs.resample(plist('fsout',fsout));
  end
  
  % Initialize
  iSm(1:Nexp) = matrix();
  fin       = ao.initObjectWithSize(Nin,Nexp);
  fout      = ao.initObjectWithSize(Nout,Nexp);
  freqs     = cell(1,Nexp);
  fs        = cell(1,Nexp);
  Sn        = ao.initObjectWithSize(Nout,Nout);
  win_keys  = getKeys(plist.WELCH_PLIST);
  win_plist = algo.params.subset(win_keys);

  % Loop over Number of Experiments
  for kk = 1:Nexp
    
    % Check if there are null injections
    for ch = 1:Nin
      if isempty(inputs(ch,kk).y)
        zeroIn = ao(plist('type','tsdata','xvals',inputs(ch,kk).x,'yvals',zeros(1,numel(inputs(ch,kk).x))));
        % Re-build input with new zeroed signal
        inputs(ch,kk) = zeroIn;
      end
    end
    
    % Scale the FFT to the window power
    winname = win_plist.find('win');
    switch lower(winname)
      case 'kaiser'
        w = specwin(winname, 0, psll);
      otherwise
        w = specwin(winname, 0);
    end
    w.len = inputs(1, kk).len;
    w     = w.win;
    % Normalisation factor
    K = w*w';
    w = w./sqrt(K);
    
    % FFT and windowing
    if isempty(flim)
      
      utils.helper.msg(msg.IMPORTANT, 'Windowing the data ...', mfilename('class'), mfilename);      
    
      if input_flag
        fin(:, kk)  = fft(inputs(:,kk).*w);
      end
      
      fout(:, kk) = fft(outputs(:,kk).*w);
      
    elseif ~isempty(flim)
      
      if input_flag
        fin(:, kk)    = dft(inputs(:, kk).*w , plist('f',flim));
      end
      fout(:, kk)   = dft(outputs(:, kk).*w, plist('f',flim));
      
    end
    
    % Nsamples and fs for each experiment
    fs{kk}       = fout(1,kk).fs;
    
    % Splitting
    if ~isempty(f1) && ~isempty(f2)
      
      utils.helper.msg(msg.PROC1, 'Splitting the data ...', mfilename('class'), mfilename);
      
      % If f2, f2 are numericals, assume the same split for both experiments
      if isnumeric(f1) && numel(f1) == 1 && isnumeric(f2) && numel(f2) == 1
        
        if input_flag
          fin(:, kk)  = split(fin(:, kk), plist('frequencies',[f1 f2]));
        end
        
        fout(:, kk) = split(fout(:, kk), plist('frequencies',[f1 f2]));
        
      else
        
        if input_flag
          fin(:, kk)  = split(fin(:, kk), plist('frequencies',[f1{kk} f2{kk}]));
        end
        
        fout(:, kk) = split(fout(:, kk), plist('frequencies',[f1{kk} f2{kk}]));
        
      end
      
    end
    
    % Store the frequencies
    freqs{kk} = fout(1,kk).x;
    
    % Build noise model
    utils.helper.msg(msg.PROC1, sprintf('Building noise model for experiment # %d...', kk), mfilename('class'), mfilename);
    
    % compute inverse cross-spectrum matrix
    scpl = plist('NOISE SCALE',          algo.params.find('NOISE SCALE'),...
                 'WIN',                  algo.params.find('WIN'),...
                 'NOUT',                 Nout,...
                 'FREQS',                freqs{kk},...
                 'ISDIAG',               algo.params.find('ISDIAG'),...
                 'INTERPOLATION METHOD', algo.params.find('INTERPOLATION METHOD'),...
                 'NAVS',                 algo.params.find('NAVS'),...
                 'BIN DATA',             algo.params.find('BIN DATA'),...
                 'OLAP',                 algo.params.find('OLAP'),...
                 'ORDER',                algo.params.find('ORDER'),...
                 'FIT NOISE MODEL',      algo.params.find('FIT NOISE MODEL'),...
                 'PLOT FITS',            algo.params.find('DOPLOT'),...
                 'POLYNOMIAL ORDER',     algo.params.find('POLYNOMIAL ORDER'));
    
    iSm(kk) = MCMC.computeICSMatrix(noise(:,kk), scpl);
    
    % Transfer to AOs:
    for rr = 1:size(iSm(kk).objs,1)
      for cc = 1:size(iSm(kk).objs,2)
        Sn(rr, cc, kk) = iSm(kk).objs(rr,cc);
      end
    end
    
  end % End loop over experiments
  
  algo.freqs = freqs;
end

% END