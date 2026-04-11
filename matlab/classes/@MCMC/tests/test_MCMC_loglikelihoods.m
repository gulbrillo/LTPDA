%
% Tests the loglikelihood functions.
%
function test_MCMC_loglikelihoods(~)
  
  result  = true;
  message = 'Pass';
  
  % Simulate the responce
  params = {'DAMP','K'}; % mass set to default = 1
  values = [0.1, 0.1];
  
  
  mod = ssm(plist('built-in','HARMONIC_OSC_1D',...
    'Version','Fitting',...
    'Continuous',1,...
    'SYMBOLIC PARAMS',params));
  
  mod.setParameters(plist('names',params,'values',values));
  
  % input matrix
  in = ao(plist('waveform','sine wave','fs',10,'nsecs',300,'f',0.2));
  in.zeropad(plist('N',1000,'position','pre'));
  in.zeropad(plist('N',300,'position','post'));
  
  % noise
  noise = ao(plist('waveform','noise','fs',10,'nsecs',in.nsecs,'sigma',0.1));
  
  sim = mod.keepParameters;
  sim.modifyTimeStep(0.1);
  
  mout = sim.simulate(plist('AOS', [in noise], ...
                            'AOS VARIABLE NAMES', {'COMMAND.force' 'NOISE.readout'}, ...
                            'return outputs',  {'HARMONIC_OSC_1D.position'}));
  
  t0 = time('2012-01-17 17:04:11.529 UTC');
  
  in.setT0(t0);
  noise.setT0(t0);
  mout.objs(1).setT0(t0);
  
  out    = mout.getObjectAtIndex(1,1);
  fin    = fft(in);
  fout   = fft(out);
  fnoise = psd(noise);
  freqs  = fin.x;
  
  % Try the SSM
  try
    
    inNames = {'COMMAND.force'};
    outNames = {'HARMONIC_OSC_1D.position'};
    
    llpl = plist(...
                'x',        values,...
                'in',       fin,...
                'out',      fout,...
                'noise',    fnoise,...
                'inNames',  inNames,...
                'outNames', outNames,...
                'params',   params,...
                'f',        freqs...
                );
    
    l_ssm = loglikelihood(mod,llpl);

  catch err
    result  = false;
    message = sprintf(['Failed to calculate the loglikelihood for the SSM case... ' ...
                       'Error: %s'], err.message);
  end
  
  % Try the MATRIX
  try
    
    m = smodel(plist('built-in', 'oscillator_fd_tf', 'var', 'f'));
    m.setParams({'m', 'k', 'tau'},{1 0.1 0.1});
    m.setXvals(freqs);
    m.setXvar('f');
    
    model = matrix(m);
    
    llpl = plist(...
                'x',        values,...
                'in',       fin,...
                'out',      fout,...
                'noise',    fnoise,...
                'params',   {'k', 'tau'},...
                'f',        freqs...
                );
    
    l_matrix = loglikelihood(model,llpl);

  catch err
    result  = false;
    message = sprintf(['Failed to calculate the loglikelihood for the MATRIX case... ' ...
                       'Error: %s'], err.message);
  end
  
  % Try the MFH
  try
    
    func = mfh(plist('name',         'buffoon', ...
                     'func',         'x(1).*i.y + x(2).*o.y', ...
                     'inputs',       {'x'},...
                     'constants',    {'i', 'o'}, ...
                     'constObjects', {fin fout fnoise}));
    
    llpl = plist(...
                'x',        values,...
                'noise',    fnoise,...
                'params',   params,...
                'f',        freqs...
                );
    
    l_mfh = loglikelihood(func, llpl);

  catch err
    result  = false;
    message = sprintf(['Failed to calculate the loglikelihood for the MFH case... ' ...
                       'Error: %s'], err.message);
  end
  
%   if result
%     % Try if callerIsMethod == true
%     try
%       
%       l_ssm    = loglikelihood(mod, values, data, params, lp, spl);
%       l_matrix = loglikelihood(model, values, data, params, lp, freqs);
%       l_mfh    = loglikelihood(func, values, data);
%       
%     catch err
%       result  = false;
%       message = sprintf(['Failed to calculate the loglikelihoods if callerIsMethod == true... ' ...
%         'Error: %s'], err.message);
%     end
%   end
    
  if result
    % Try the core functions
    try
      
      data = MCMC.ao2strucArrays(plist('in',fin, 'out', fout, 'S',fnoise,'Nexp',1));
      lp   = [0 0];
      spl  = plist('reorganize', false, 'f', freqs,...
                   'inputs',inNames,'outputs',outNames);
      
      % Preproccess model -- NEEDED IF THE CORE FUNCTION IS USED --
      processedModel = copy(mod, 1);
      processedModel.clearNumParams;
      lpl = plist('set',     'for bode',...
                  'outputs', outNames, ...
                  'inputs',  inNames);
      % first optimise our model for the case in hand
      processedModel.reorganize(lpl);
      % make it lighter
      processedModel.optimiseForFitting();
      
      l_ssm    = loglikelihood_core(processedModel, values, data, params, lp, spl);
      l_matrix = loglikelihood_core(model, values, data, params, lp, freqs);
      l_mfh    = loglikelihood_core(func, values, data);
      
    catch err
      result  = false;
      message = sprintf(['Failed to calculate the core loglikelihood functions... ' ...
        'Error: %s'], err.message);
    end
  end
  
  % Assert
  assert(result, message)

end