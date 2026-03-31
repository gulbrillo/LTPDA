%
% buildLoglikelihood
%
% A utility method to construct the loglikelihood of the given data-set.
%
% CALL: algorithm.buildLoglikelihood()
%
% 2013
%
function algo = buildLogLikelihood(algo, varargin)
  
  import utils.const.*
  
  % Handle the case of SSM and MFH data types
  if ~isempty(varargin) && ~isempty(varargin{:})
    % Collect system output data
    aoHist = algo.collectOutputAOs(varargin);
  else
    aoHist = [];
  end
  
  switch class(algo.model)
    case 'mfh'
      
      % Get the version
      llhver = algo.params.find('llh version');
      
      % Combine with the model likelihood  
      llh_pl = subset(algo.params, getKeys(remove(mfh_model_loglikelihood('plist',llhver), 'version', 'data', 'Time Series MFH', 'frequencies')));
      
      % Add mode elements
      llh_pl.pset('built-in',         'loglikelihood', ...
                  'version',          llhver,...
                  'Time Series MFH',  algo.model,...                        
                  'frequencies',      [algo.params.find('F1'), algo.params.find('F2')]);            
      
      % Add the noise model if the likelihood version is not 'LOG'          
      if ~any(strcmpi(llhver, {'log', 'td ao', 'td core'}))
        llh_pl.pset('noise model', algo.noise);
      elseif strcmpi(llhver, 'td core') || strcmpi(llhver, 'td ao') 
        llh_pl = remove(llh_pl.pset('data', algo.outputs, 'dy', algo.params.find('dy')), 'frequencies');
      end
                
      L = mfh(llh_pl);    
       
    otherwise
      
      %  Preprocess the data
      [fin, fout, S] = algo.preprocess();
      
      % Prepare model for fitting
      algo.preprocessModel(algo.freqs, algo.params.find('MODELFREQDEPENDENT'));
      
      % Store the data into structure arrays
      if ~isempty(fout) && ~isempty(fin) &&  ~isempty(S)
        
        data = MCMC.ao2strucArrays(plist('in',fin,'out',fout,'S',S,'Nexp',size(S,3)));
        % Get # of experiments
        Nexp  = numel(data);
        dof   = zeros(1, Nexp);
        spl   = plist.initObjectWithSize(1, Nexp);
  
        for kk = 1:Nexp
          dof(kk) = 2*numel(algo.freqs{kk}) - numel(algo.params.find('FITPARAMS'));
          spl(kk) = plist('reorganize', false, 'f', algo.freqs{kk},...
                           'inputs',    algo.params.find('INNAMES'),...
                           'outputs',   algo.params.find('OUTNAMES'));
        end
        
      else
        data = 1;
      end
      
      L = mfh(plist('func',         'loglikelihood_core(model, x, data, param, lp, spl)',...
                    'inputs',       {'x'},...
                    'constants',    {'model', 'data', 'param', 'lp', 'spl'},...
                    'constObjects', {algo.processedModel, data, algo.params.find('FITPARAMS'), getLogParams(algo), spl}));
      
      L.setProcinfo(plist('S',           S,...
                          'fft_signals', fin,...
                          'data',        data));
      
  end
  
  % Set the likelihood function
  algo.loglikelihood = L;
  
  % Add history step
  algo.addHistory(getInfo, plist.EMPTY_PLIST(), {}, [algo.hist aoHist]);
  
end

%
% GetInfo function
%
function ii = getInfo(varargin)
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', {}, plist.EMPTY_PLIST);
end

%
% Function to handle the logarithm of certain parameters
%
function lp = getLogParams(algo)
  param     = algo.params.find('FITPARAMS');
  logparams = algo.params.find('LOG PARAMETERS');
  lp = zeros(1,numel(param));
  if ~isempty(logparams)
    for i = 1:numel(param)
      if any(strcmp(param{i},logparams))
        lp(i) = 1;
      end
    end
  end
end

% End of buildLoglikelihood