%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Metropolis algorithm
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [smpl smplr] = mhsample(fimmdl,in,out,nse,cov,number,limit,param,Tc,xi,xo,search,jumps,pl,parplot,dbg_info,inNames,outNames,fpars,anneal,SNR0,DeltaL,inModel,outModel)
  
  import utils.const.*
 
  % initialize
  oldacc = 0;
  oldrej = 0;
  oldsamples = 0;
  SNR = 0;
  all_param_names = cell(1,numel(param)+1);
  smpl = zeros(number,numel(param)+1);
  smplr = zeros(2*number,numel(param)+2);
  
  % handle for figures. Do not plot over existing figures.
  if ~isempty(parplot)
    for i = 1:numel(parplot)
      figure
      plotvec(i) = get(0,'CurrentFigure');
    end
    all_param_names{1} = 'LogLikelihood';
    for ii = 1:numel(param)
      all_param_names{ii+1} = param{ii};
    end
  end
  
  % plist to pass in to the sampler for use in bode
  spl = plist('outputs', outNames, ...
    'inputs', inNames, ...
    'reorganize', false,...
    'numeric output',true);
  
  % Preprocess the model to make it lighter. This step was moved inside
  % mhsample.m from the main mcmc.m, as a consequence of the update of the 
  % FIM during the metropolis run. The object 'model' is used in the main
  % loop for the computation of the likelihood, while 'fimmdl' is used for
  % the calculation of the FIM.
  model = preprocessModel(fimmdl,find(pl,'freqs'),find(pl,'mdlFreqDependent'),inNames,outNames);
  
  % switch depending on model class (likelihood at x0).
  switch class(model)
    case 'matrix'
      [loglk1 SNR] = utils.math.loglikelihood_matrix(xo,in,out,nse,model,param,inModel,outModel);
    case 'smodel'
      loglk1 = utils.math.loglikelihood(xo,in,out,nse,model,param);
    case 'ssm'
      Amats = model.amats;
      Bmats = model.bmats;
      Cmats = model.cmats;
      Dmats = model.dmats;
      
      loglk1 = ssm.loglikelihood(xo,in,out,nse,model,param, spl, Amats, Bmats, Cmats, Dmats);
    otherwise
      error('### Model must be either from the ''smodel'' or the ''ssm'' class. Please check the inputs')
  end
  
  % accept the first sample if no search active
  if ~search
    smpl(1,:) = [loglk1 xo];
    smplr(1,:) = [loglk1 1 xo];
    nacc = 1;
    samples = 1;
  else
    nacc = 0;
    samples = 0;
  end
  nrej = 0;
  samples = 0;
   
  % compute prior for the initial sample of the chain 
  if isempty(fpars)
    logprior1 = 0;
    logprior2 = 0;
  else
    logprior1 = logPriors(xo,fpars);
    % if initial guess is far away, this contidion sets our logprior
    % to zero and takes account only the loglikelihood for the 
    % computation of logratio. 
    if logprior1 == -Inf; logprior1 = 0; end
  end 
  
  % check if the covariance matrix and the differentiation steps are provided. 
  % If not it calculates the covariance of the parameters at x0. The  differentiation 
  % step -if calculated- is used for the update of the covariance matrix during
  % the main MCMC loop. 
  if (isempty(cov) && isempty(find(pl,'diffstep')))
    [cov step]= updateFIM(pl,in,out,nse,param,xo,fimmdl,inNames,outNames);
    pl = pset(pl,'diffstep',step);
  elseif isempty(cov)
    cov = updateFIM(pl,in,out,nse,param,xo,fimmdl,inNames,outNames);
  end
  
  proposalsamp = find(pl,'proposal sampler');
  if isempty(proposalsamp)
    proposalsamp = @utils.math.drawSample;
  end
  
  proposalpdf = find(pl,'proposal pdf');
  if ~isempty(proposalpdf) 
    issymmetric = false;
  else
    issymmetric = true;
  end

  
  T = Tc(1);
  hjump = 0;
  fu = find(pl,'updatefim');
  
  utils.helper.msg(msg.IMPORTANT, 'Starting Monte Carlo sampling', mfilename('class'), mfilename);
 
  %% main loop
  
  while(samples<number)
    %    jumping criterion during search phase
    %    - 2-sigma  by default
    %    - 10-sigma  jumps at mod(10) samples
    %    - 100-sigma jumps at mod(25) samples
    %    - 1000-sigma jumps at mod(100) samples

    % Update the Covariance matrix
    if (~isempty(find(pl,'updatefim')) && mod(samples,fu) == 0 && samples ~= 0)
      cov = updateFIM(pl,in,out,nse,param,xo,fimmdl,inNames,outNames); 
    end
    
    % sample new point
    [xn hjump] = jump(xo,cov,hjump,jumps,samples,search,Tc,proposalsamp);   
    
    % compute prior probability 
    if ~isempty(fpars)
      logprior2 = logPriors(xn,fpars);
    end
    
    % check if out of limits
    if( any(xn < limit(1,:)) || any(xn > limit(2,:)) || logprior2 == -Inf)
      loglk2 = inf;
      betta = inf;  
    else
      % switch depending on model class (new likelihood)
      switch class(model)
        case 'matrix'
          [loglk2 SNR] = utils.math.loglikelihood_matrix(xn,in,out,nse,model,param,inModel,outModel); 
        case 'smodel'
          loglk2 = utils.math.loglikelihood(xn,in,out,nse,model,param); 
        case 'ssm'
          [loglk2 SNR] = ssm.loglikelihood(xn,in,out,nse,model,param, spl, Amats, Bmats, Cmats, Dmats); 
        otherwise
          error('### Model must be either from the ''smodel'' or the ''ssm'' class. Please check the inputs')
      end 
      % compute annealing
      betta = computeBetta(samples,Tc,anneal,SNR,DeltaL,xi,SNR0,T);
    end % here we are 
    
    % likelihood ratio
    if issymmetric
      logr = betta*(logprior2 + loglk2 - loglk1 - logprior1);
    else
      q1 = logq(xn,xo,cov,proposalpdf);
      q2 = logq(xo,xn,cov,proposalpdf);
      logr = betta*(logprior2 + loglk2 - loglk1 - logprior1 + q2 - q1);
    end
    
    % decide if sample is accepted or not
    if logr < 0
      xo = xn; 
      nacc = nacc+1;
      samples = samples + 1;
      smpl(samples,:) = [loglk2 xn];
      smplr(samples,:) = [loglk2 1 xn];
      loglk1 =loglk2;
      logprior1=logprior2;
      if dbg_info
       utils.helper.msg(msg.IMPORTANT, sprintf('acc.\t loglik: %d -> %d priors: %d -> %d betta: %d  ratio: %d',loglk1,loglk2,logprior1,logprior2,betta,logr), mfilename('class'), mfilename);
      end
    elseif rand(1) > (1 - exp(-logr))
      xo = xn; 
      nacc = nacc+1;
      samples = samples + 1;
      smpl(samples,:) = [loglk2 xn];
      smplr(samples,:) = [loglk2 1 xn];
      loglk1 =loglk2;
      logprior1=logprior2;
      if dbg_info
        utils.helper.msg(msg.IMPORTANT, sprintf('acc.\t loglik: %d -> %d priors: %d -> %d betta: %d  ratio: %d',loglk1,loglk2,logprior1,logprior2,betta,logr), mfilename('class'), mfilename);
      end
    else
      nrej = nrej+1;
      samples = samples + 1;
      smpl(samples,:) = [loglk1 xo];
      smplr(samples,:) = [loglk2 0 xn];
      if dbg_info
        utils.helper.msg(msg.IMPORTANT, sprintf('rej.\t loglik: %d -> %d priors: %d -> %d betta: %d  ratio: %d',loglk1,loglk2,logprior1,logprior2,betta,logr), mfilename('class'), mfilename);
      end    
    end
    
    % display and save
    if(mod(samples,100) == 0 && (samples) ~= (oldsamples))
      updacc = nacc-oldacc;
      updrej = nrej-oldrej;
      ratio(samples/100,:) = updacc/(updacc+updrej);
      utils.helper.msg(msg.IMPORTANT, sprintf('samples: %d   accepted: %d   rejected : %d   acc. rate: %4.2f',samples,updacc,updrej,ratio(end)), mfilename('class'), mfilename);
      for i = 1:numel(param)
        fprintf('###  Parameters: %s = %d \n',param{i},xn(i))        
      end
      oldacc = nacc;
      oldrej = nrej;
      oldsamples = samples;
      save('acceptance.txt','ratio','-ASCII')
      % plot 
      if  ~isempty(parplot)
        for i = 1:numel(parplot)
          figure(plotvec(i))
          plot(smpl(1:samples,parplot(i)),'k')
          ylabel(all_param_names{parplot(i)},'Interpreter', 'none')
          xlabel('Samples')
        end
      end
    end
    
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      propose new point on the parameter space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xn hjump] = jump(xo,cov,hjump,jumps,samples,search,Tc,proposalSampler)
  
  if search
    if samples <= Tc(1)
      if(mod(samples,10) == 0 && mod(samples,25) ~= 0 && mod(samples,100) ~= 0 && hjump  ~= 1)
        hjump = 1;
        modcov = jumps(2)^2*cov;
      elseif(mod(samples,20) == 0 && mod(samples,100) ~= 0 && hjump  ~= 1)
        hjump = 1;
        modcov = jumps(3)^2*cov;
      elseif(mod(samples,50) == 0 && hjump  ~= 1)
        hjump = 1;
        modcov = jumps(4)^2*cov;
      else
        hjump = 0;
        modcov = jumps(1)^2*cov;
      end
    else
      modcov = 2*cov;
    end
    xn = proposalSampler(xo,modcov);
  else
    xn = proposalSampler(xo,cov);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      compute proposal density
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function q = logq(X,mean,cov,proposal)

  q = log(proposal(X,mean,cov));
  if (q == -Inf || q == Inf); q = 0; end

end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      update the Fisher Matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cov step] = updateFIM(pl,in,out,nse,param,xo,model,inNames,outNames)
   
% initialize
   N = find(pl,'N');
   FMall = zeros(numel(param),numel(param));
   a = 2/(N*in(1).getObjectAtIndex(1,1).fs);

   for k = 1:numel(in)
     % get FIM 
     if (((numel(out(k).objs)) == 2) && (numel(in(k).objs) == 2))
       
       % check injection for both channels
       if all(in(k).getObjectAtIndex(1,1).y == 0) || isempty(in(k).getObjectAtIndex(1,1).y)
         i1 = ao(plist('type','fsdata','xvals',0,'yvals',0));
       else
         i1 = in(k).getObjectAtIndex(1,1);
         freqs = i1.x;
         fs = i1.fs;
       end 
       if all(in(k).getObjectAtIndex(2,1).y == 0) || isempty(in(k).getObjectAtIndex(2,1).y)
        i2 = ao(plist('type','fsdata','xvals',0,'yvals',0));
      else
        i2 = in(k).getObjectAtIndex(2,1);
        freqs = i2.x;
        fs = i2.fs;
       end
      
       for ii = 1:4
        S(:,ii) = a*nse(k).objs(ii).y;
       end
       
       [FisMat step] = utils.math.fisher_2x2(i1.y,i2.y,S,model,param,xo,freqs,N,fs,pl,inNames,outNames);
       FMall = FMall + FisMat;

     elseif (((numel(out(1).objs)) == 1) && (numel(in(1).objs) == 1))
      
       [FisMat step] = utils.math.fisher_1x1(in(k).objs(1).y,a*nse(k).objs(1).y,model,param,xo,nse(k).objs(1).x,N,in(k).objs(1).fs,pl,inNames,outNames);
       FMall = FMall + FisMat;
      
     else
      error('### Sorry, for now only 2 inputs / 2 outputs, 1 input / 1 output...')
     end
   end
    
   pseudoinv = find(pl,'pinv');
   tol = find(pl,'tol');
   % inverse is the optimal covariance matrix
   if pseudoinv && isempty(tol)
     cov = pinv(FMall);
   elseif pseudoinv
     cov = pinv(FMall,tol);
   else
     cov = FMall\eye(size(FMall));
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      compute heat factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function betta = computeBetta(samples,Tc,anneal,SNR,DeltaL,xi,SNR0,T)

  if ~isempty(Tc)
    if samples <= Tc(1)
      % compute heat factor
      switch anneal
        case 'simul'
          heat = xi;
        case 'thermo'
          if (0 <= SNR(1) && SNR(1) <= SNR0)
            heat = xi;
          elseif (SNR(1) > SNR0)
            heat = xi*(SNR(1)/SNR0)^2;              
          end
        case 'simple'
          if (samples > 10 && mod(samples,10) == 0)
            deltalogp = std(smpl(samples-10:samples,1));          
              if deltalogp <= DeltaL(1) 
                T = T + DeltaL(3);
              elseif deltalogp >= DeltaL(2)
                T = T - DeltaL(4);
              end 
              heat = xi*Tc(1)/T;
          end
      end  
        betta = 1/2 * 10^(-heat*(1-Tc(1)/Tc(2)));
    elseif Tc(1) < samples  && samples <= Tc(2)
      betta = 1/2 * 10^(-xi*(1-samples/Tc(2)));
    else
      betta = 1/2;
    end
  else
    betta = 1/2;
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Reorganize the model. Used to create lighter versions of 
%      the models to be used in the main loop. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function modelout = preprocessModel(model,freqs,mdlFreqDependent,inNames,outNames)

  modelout = copy(model,1);

  % lighten the model
  modelout.clearHistory;
  if isa(modelout, 'ssm')
    modelout.clearAllUnits;
    modelout.params.simplify;
  end
  
  switch class(model)
    case 'matrix'
      for i = 1:numel(modelout.objs)
        if (mdlFreqDependent)
          % set Xvals
          modelout.objs(i).setXvals(freqs);
          % set alias
          modelout.objs(i).assignalias(modelout.objs(i),plist('xvals',freqs));
        else
          modelout.objs(i).setXvals(1);
        end
      end
    case 'ssm'
      modelout.clearNumParams;
      spl = plist('set', 'for bode', ...
      'outputs', outNames, ...
      'inputs', inNames);
      % first optimise our model for the case in hand
      modelout.reorganize(spl);
      % make it lighter
      modelout.optimiseForFitting();
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      compute logpriors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function logprior = logPriors(parVect,fitparams)

D = size(parVect);
prior = zeros(D);

for ii=1:D(2)
   prior(ii) = normalPDF(parVect(ii),fitparams(ii,1),fitparams(ii,2))/fitparams(ii,3);
   % checking if priors are used for this run 
   if isnan(prior(ii))
        prior(ii) = 1;
    end
end
prior = log(prior);
logprior = sum(prior);

% assuming that priors are independent, then
% p(x|8n)=p(x|81)p(x|82)p(x|83)...p(x|8n)=p1xp2xp3...xpn
% and log(p(x|8n)) = logp1+logp2+...+logpn
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      normal PDF function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pdf = normalPDF(x,m,sig)

pdf = exp(-0.5*((x-m)./sig).^2)./(sqrt(2*pi).*sig);

end


