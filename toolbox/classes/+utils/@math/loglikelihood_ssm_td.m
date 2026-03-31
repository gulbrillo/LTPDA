%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute log-likelihood in time domain for SSM objects
% 
% INPUT
% 
% - in, a vector of input signals aos
% - out, a vector of output data aos
% - parvals, a vector with parameters values
% - parnames, a cell array with parameters names
% - model, an ssm model
% - inNames, A cell-array of input port names corresponding to the
% different input AOs
% - outNames, A cell-array of output ports to return
% - Noise, a vector of noise aos
% - cutbefore, followed by the data samples to cut at the starting of the
% data series
% - cutafter, followed by the data samples to cut at the ending of the
% data series
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loglk = loglikelihood_ssm_td(xp,in,out,parnames,model,inNames,outNames,Noise,varargin)
% xn,in,out,noise,model,params,inNames,outNames
  cutbefore = [];
  cutafter = [];
  if ~isempty(varargin)
    for j=1:length(varargin)
      if strcmp(varargin{j},'cutbefore')
        cutbefore = varargin{j+1};
      end
      if strcmp(varargin{j},'cutafter')
        cutafter = varargin{j+1};
      end
    end
  end
  
  xp = double(xp);
  fs = out(1).fs;
  
  % set parameters in the model
  evalm = model.setParameters(plist('names',parnames,'values',xp));
  evalm.keepParameters();
  evalm.modifyTimeStep(plist('newtimestep',1/fs));
  
  %%% get expected outputs
  plsym = plist('AOS VARIABLE NAMES',inNames,...
    'RETURN OUTPUTS',outNames,...
    'AOS',in);
  eo = simulate(evalm,plsym);
  
%   %%% get expected noise
%     plsym = plist('AOS VARIABLE NAMES',inNoiseNames,...
%     'RETURN OUTPUTS',outNames,...
%     'AOS',inNoise);
%   eon = simulate(evalm,plsym);
  
  %%% get measurement noise
  res = out-eo;
  
  loglk = utils.math.loglikehood_td(res,Noise,'cutbefore',cutbefore,'cutafter',cutafter);
  
  

end