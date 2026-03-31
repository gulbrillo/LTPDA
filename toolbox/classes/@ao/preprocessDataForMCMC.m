% preprocessDataForMCMC Split, resample and apply FFT to time series for MCMC analysis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: preprocessDataForMCMC: Split, resample and apply FFT to 
%                                     time series for MCMC analysis.
%
% CALL:        >> procData = preprocessDataForMCMC(out ,pl)
%
% INPUTS:      pl       - a parameter list
%
%              out      - output data. 
%
% OUTPUTS:
%              procData - If the procData is a single object,
%                         then it packs all processed data to a collection 
%                         object. 
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'conv')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = preprocessDataForMCMC(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % use the caller is method to get the method calling
  [~, ~, methodName] = utils.helper.callerIsMethod;

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs and plists
  [aos, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl               = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  if nargout == 0
    error('### This function cannot be used as a modifier. Please give an output variable.');
  end

  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  flim       = find_core(pl,'frequencies');
  fsout      = find_core(pl,'fsout');
  aoin       = find_core(pl,'input');
  mdlin      = find_core(pl,'model');
  aonse      = find_core(pl,'noise');
  outModel   = find_core(pl,'outModel');
  inModel    = find_core(pl,'inModel');
  numericout = find_core(pl,'Numeric output');
  f1         = find_core(pl,'f1');
  f2         = find_core(pl,'f2');
  % Plist for PSD and CPSD
  psdplist   = pl.subset('Navs');
  
  out   = copy(aos,   nargout);
  if ~isempty(mdlin)
    model = copy(mdlin, nargout);
  else
    model = [];
  end
  noise = copy(aonse, nargout);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%   Perform Sanity Checks on inputs  %%%%%%%%%%%%%%%%%%%%%%%%
  
  if isempty(aoin)
    warning('LTPDA:preprocessDataForMCMC','### An input signal was not inserted...')
    in   = 1;
    Nin  = 0;
    input_flag = false;
  else
    utils.helper.msg(msg.IMPORTANT, ['Input signal was inserted. ' ...
                     'Assuming system identification experiment ...'], mfilename('class'), mfilename);
    in   = copy(aoin,  nargout);
    % Get # of inputs. The # of outputs is defined later.
    Nin  = numel(in(:,1));
    input_flag = true;
  end
  
  if isempty(out)
    error('### An output signal was not inserted...')
  end
  
  if isempty(model)
    warning('LTPDA:preprocessDataForMCMC',['### The ''model'' field of the plist is empty. ' ...
            'Checks considering the model will not be performed.'])
  end
  
  % Get # of experiments
  Nexp = numel(noise(1,:));
  
  % Get # of outputs
  Nout = numel(noise(:,1));
  
  %%%%%%%%%%%%%%%%%%%%% Check inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    
  if size(out) ~= size(noise)
    error('### Parameters ''out'' and ''noise'' must be the same dimension');
  end
  
  if Nexp ~= numel(out(1,:)) || Nexp ~= numel(noise(1,:))
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
  
  % Checks if model and injection signal is provided.
  if ~isempty(model) && Nin ~= 0
    
    % Lighten the model
    model.clearHistory;
    if isa(model, 'ssm')
      model.clearNumParams;
      model.clearAllUnits;
      model.params.simplify;
    end
  
    switch class(model)
      
      case 'matrix'
        
        % Check model sizes
        if (isempty(outModel) && isempty(inModel))
          
          if (~(Nin == model.ncols) || ~(numel(out(:,1)) == model.nrows))
            error('Check model or input/output sizes');
          end
          
        elseif isempty(inModel)
          
          if (~(Nin == model.ncols) || ~(size(outModel,2) == model.nrows) || ...
              ~(size(outModel,1) == numel(out(:,1))))
            error('Check model or input/output sizes');
          end
          
        elseif isempty(outModel)
          
          if (~(Nin == size(inModel,2)) || ~(size(inModel,1) == model.ncols) || ...
              ~(numel(out(:,1)) == model.nrows))
            error('Check model or input/output sizes');
          end
          
        else
          
          if (~(Nin == size(inModel,2)) || ~(size(inModel,1) == model.ncols) || ...
              ~(size(outModel,2) == model.nrows) || ~(numel(out(:,1)) == size(outModel,1)))
            error('Check model or input/output sizes');
          end
          
        end
        
      case 'ssm'
        
        inNames  = find_core(pl,'inNames');
        outNames = find_core(pl,'outNames');
        
        if isempty(inNames) || isempty(outNames)
          
          error('### The fields ''inNames'' and ''outNames'' are necessary for ssm models.')
        
        end
        
        % Do not perform this test if crb is calling this function.
        if ~strcmp(methodName, 'crb')
          
            if ((numel(inNames) ~= Nin) || numel(outNames) ~= numel(out(:,1)))
              error('### Check model inNames and outNames, they do not match with the input objects')
            end
            
        end
      otherwise
        
        error('### Model must be either from the ''matrix'' or the ''ssm'' class. Please check the inputs.')
        
    end
  
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%   Frequency domain pre-process  %%%%%%%%%%%%%%%%%%%%%%%%
  
  utils.helper.msg(msg.IMPORTANT, 'Computing frequency domain objects ... ', mfilename('class'), mfilename);
  
  % Resampling
  if ~isempty(fsout)
    if input_flag
      in.resample(plist('fsout',fsout));
    end
    out.resample(plist('fsout',fsout));
  end
  
  % Initialize
  iSm(1:Nexp) = matrix();
  
  % Loop over Number of Experiments
  for k = 1:Nexp

    % FFT and windowing
    if (pl.find_core('win')) && k == 1 && isempty(flim)

      utils.helper.msg(msg.IMPORTANT, 'Windowing the data ...', mfilename('class'), mfilename);

      win_plist   = plist('win', pl.find_core('win type'), 'length', out(1,k).len,...
                          'psll',pl.find_core('psll'),'levelOrder',pl.find_core('levelOrder'));

      if input_flag            
        win(1:Nin, 1:Nexp)  = ao(win_plist);
        fin                 = fft(in(:,k).*win);
      end

      win(1:Nout, 1:Nexp) = ao(win_plist);
      fout                = fft(out(:,k).*win);

    elseif k == 1 && isempty(flim)

      fin    = fft(in);
      fout   = fft(out);
      
    elseif k ==1 && ~isempty(flim)
      
      fin    = dft(in , plist('f',flim));
      fout   = dft(out, plist('f',flim));

    end

    % Splitting
    if ~isempty(f1) && ~isempty(f2)

      utils.helper.msg(msg.IMPORTANT, 'Splitting the data ...', mfilename('class'), mfilename);

      % If f2, f2 are numericals, assume the same split for both experiments  
      if (isnumeric(f1) && numel(f1) == 1) && (isnumeric(f2) && numel(f2) == 1) && k == 1

        if input_flag
          fin  = split(fin, plist('frequencies',[f1 f2]));
        end
        
        fout = split(fout, plist('frequencies',[f1 f2]));

      end

      if ~isempty(outModel)
        for lll=1:size(outModel,1)
          for kkk=1:size(outModel,2)
            outModel(lll,kkk) = split(outModel(lll,kkk),plist('frequencies',[f1 f2]));
          end
        end
      end
      if ~isempty(inModel)
        inModel = split(inModel,plist('frequencies',[f1 f2]));
      end
    end
    
    % Taking freqs, Nsamples and fs from 1st output
    freqs    = fout(1,1).x;
    Nsamples = length(fout(1,1).x);
    fs       = fout(1,1).fs;
      
    % use signal fft to get frequency vector. Take into account signal
    % could be empty or set to zero. 
    utils.helper.msg(msg.IMPORTANT, sprintf('Checking for empty injections for experiment # %d...', k), mfilename('class'), mfilename);

    for ch = 1:Nin
      if isempty(fin(ch,k).y)
        zeroIn = ao(plist('type','fsdata','xvals',freqs{k},'yvals',zeros(1,Nsamples{k})));
        % rebuild input with new zeroed signal
        fin(ch,k) = zeroIn;
      end
    end

    % Build noise model
    utils.helper.msg(msg.IMPORTANT, sprintf('Building noise model for experiment # %d...', k), mfilename('class'), mfilename);
    for ii = 1:Nout
      for jj = ii:Nout

        % Compute psd
        if (ii==jj)
          
          n(ii,jj)  = Nsamples*fs/2*psd(noise(ii,k), psdplist);
          S(ii,jj)  = interp(n(ii,jj),plist('vertices',freqs,'method','linear'));

          S(ii,jj).setX(freqs);

        else

          n(ii,jj) = Nsamples*fs/2*cpsd(noise(ii,k),noise(jj,k), psdplist);
          S(ii,jj) = interp(n(ii,jj),plist('vertices',freqs,'method','linear'));
          S(jj,ii) = conj(S(ii,jj));

          S(ii,jj).setX(freqs);
          S(jj,ii).setX(freqs);

        end

      end
    end
    
    % Build cross-spectrum matrix object
    Sm = matrix(S,plist('shape',[Nout Nout]));
    
    % Calculate the inverse cross-spectrum matrix object 
    iSm(k) = inv(Sm);
    
    % Transfer to AOs:
    for rr = 1:size(iSm(k).objs,1)
      for cc = 1:size(iSm(k).objs,2)
        Sn(rr, cc, k) = iSm(k).getObjectAtIndex(rr,cc);
      end
    end
    
  end    
  
  utils.helper.msg(msg.IMPORTANT, 'Checking if the output should be numeric ...', mfilename('class'), mfilename);
  
  % Transfer all AOs to pure Matlab matrices 
  if numericout

    mats = ao2numMatrices(fout,plist('in',fin,'S',Sn,'Nexp',Nexp));
    
    clear fin;
    clear fout;
    
    fin  = mats{1};
    fout = mats{2};
    Sn   = mats{3};
    
  end
    
  %%%%%%%%%%%%%%%%%%%%%%%% Set output  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  outputs = {fin, fout, Sn, model, freqs, fs, inModel, outModel};
  
  names = { ...
          'Injections', ...
          'Measurements' , ...
          'Noise' , ...
          'Model' , ...
          'inModel' , ...
          'frequencies', ...
          'outModel'   ...
          };
  
  if nargout >= 2
    % List of outputs
    for ii = 1:numel(outputs)
      % name for the objects
      bs = outputs{ii};
      
      if ~isempty(bs) && isa(bs , 'ao')
        
        for jj = 1:numel(bs)
          bs(jj).name = names{ii};
          
          % set all descriptions
          bs(jj).description = 'Preprocessed object for MCMC analysis...';
        end

      end
      
      varargout{ii} = bs;
    end
    
  elseif nargout == 1 && ~numericout
    
    bs = collection(plist('objs',outputs));
    
    % add history
    bs.addHistory(getInfo('None'), getDefaultPlist, ao_invars, [aos(:).hist]);
  
    % Single collection output
    varargout{1} = bs;
    
  else
    
    error(['### When the ''numeric output'' key is set to true, this method ' ...
           'is not able to return a collection object.'])
    
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
  ii.setModifier(false);
  ii.setArgsmin(2);
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

function pl_default = buildplist()
  pl_default = plist();
  
  % inNames
  p = param({'inNames','Input names. Used for ssm models'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % outNames
  p = param({'outNames','Output names. Used for ssm models'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % Model
  p = param({'model','Model to fit.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % Param
  p = param({'FitParams','A cell array of evaluated parameters.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
  % Input
  p = param({'input','A matrix array of input signals.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % Noise
  p = param({'noise','A matrix array of noise spectrum (PSD) used to compute the likelihood.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % Range
  p = param({'range','Range where the parameteters are sampled.'},  paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
  % Frequencies
  p = param({'frequencies','Array of frequencies where the analysis is performed.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
  % f1
  p = plist({'f1', 'Initial frequency for the analysis.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
  % f2
  p = plist({'f2', 'Final frequency for the analysis.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
  % Resample
  p = param({'fsout','Desired sampling frequency to resample the input time series'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);

  % jumps
  p = param({'Numeric output','Set to true to produce pure Matlab matrices as outputs'}, paramValue.FALSE_TRUE);
  pl_default.append(p);
  
  % inModel
  p = param({'inModel','Input model. Still under test'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % Navs
  p = param({'Navs','The number of averages to use when calculating PSD and CPSD.'}, paramValue.DOUBLE_VALUE(5));
  pl_default.append(p);
  
  % outModel
  p = param({'outModel','Output model. Still under test'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
 
  % Win 
  p = param({'win','Windowing the data.'},  paramValue.FALSE_TRUE);
  pl_default.append(p);
  
  % Win name
  p = param({'win type','Choose the type of the spectral window.'},  paramValue.WINDOW);
  pl_default.append(p);

  % psll
  p = param({'psll','Only if ''win'' is set to ''true''. If you choose a ''kaiser'' window, you can also specify the peak-sidelobe-level.'},  paramValue.DOUBLE_VALUE(150));
  pl_default.append(p);

  % level order
  p = param({'levelOrder','Only if ''win'' is set to ''true''. If you choose a ''levelledHanning'' window, you can also specify the order of the contraction.'},  paramValue.DOUBLE_VALUE(2));
  pl_default.append(p);
  
  
end

