%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reverse Jump MCMC for the computation of Bayes Factor
%
% N. Karnesis 27/09/2011
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [Bxy LogL chains] = rjsample(model,in,out,nse,cov,number,limit,param,Tc,xi,xo,search,jumps,parplot,dbg_info,inNames,outNames,inModel,outModel)
        
  import utils.const.*
  
  % initialize
  summ = 0;
  rejected = 0;
  nummodels = numel(model(1,:));
  legen = [];
  Amats = cell(1,nummodels);
  Bmats = cell(1,nummodels);
  Cmats = cell(1,nummodels);
  Dmats = cell(1,nummodels);
  logp = cell(1,nummodels);
  Bxy = cell(nummodels);
  spl(1:nummodels) = plist();
  smpl = zeros(number,nummodels);
  chains = cell(1,nummodels);
  mnacc = zeros(number,nummodels);
  mnacc(1,:) = ones(1,nummodels);
  nacc = 1;
  sumsamples = 1;
  
  % assigning random colors to curves
  for gg = 1:(nummodels)
   coloor(gg,:) = rand(1,3);   
   for dd = gg+1:(nummodels)
     colour{gg,dd} = rand(1,3);        
   end 
  end
  
 for k = 1:nummodels 
   if strcmp(class(model),'ssm') 
    % plist to pass in to the sampler for use in bode
    spl(k) = plist('outputs', outNames{k}, ...
    'inputs', inNames{k}, ...
    'reorganize', false,...
    'numeric output',true);
   end
 
   % compute loglikelihood for starting model and values
   switch class(model)
    case 'matrix'
      smpl(k) = utils.math.loglikelihood_matrix(xo{k},in,out,nse,model(:,k),param{k},inModel,outModel);
    case 'smodel'
      smpl(k) = utils.math.loglikelihood(xo{k},in,out,nse,model(:,k),param{k});
    case 'ssm'        
      Amats{k} = model(:,k).amats;
      Bmats{k} = model(:,k).bmats;
      Cmats{k} = model(:,k).cmats;
      Dmats{k} = model(:,k).dmats;      
      smpl(k) = ssm.loglikelihood(xo{k},in,out,nse,model(:,k),param{k}, spl(k), Amats{k}, Bmats{k}, Cmats{k}, Dmats{k});
     otherwise
      error('### Model must be either from the ''smodel'' or the ''ssm'' class. Please check the inputs')
   end
   chains{k} = xo{k};
  
   % calculate prior densities (assumed uniform priors)
   logp{k} = logpriors(limit{k});
 end
  
  utils.helper.msg(msg.IMPORTANT, 'Starting Reversible Jump MCMC      ', mfilename('class'), mfilename);
  
  hjump = 0;

  % initialize (choose starting model == 1)
  k = 1;
  % compute loglikelihood for starting model and values
  switch class(model)
    case 'matrix'
      loglk1mdl1 = utils.math.loglikelihood_matrix(xo{k},in,out,nse,model(:,k),param{k},inModel,outModel);
    case 'smodel'
      loglk1mdl1 = utils.math.loglikelihood(xo{k},in,out,nse,model(:,k),param{k});
    case 'ssm'        
      loglk1mdl1 = ssm.loglikelihood(xo{k},in,out,nse,model(:,k),param{k}, spl(k), Amats{k}, Bmats{k}, Cmats{k}, Dmats{k});
  otherwise
      error('### Model must be either from the ''smodel'' or the ''ssm'' class. Please check the inputs')
  end
  
  % main loop
  while(nacc<number)
     
    % propose new point in the parameter space for model k  
    [xn hjump] = propose(xo{k},cov{k},search,Tc,jumps,hjump,nacc,sumsamples);
    
    % check if out of limits
    if( any(xn < limit{k}(1,:)) || any(xn > limit{k}(2,:)))
      
        loglk2mdl1 = inf;
        
    else
      % switch depending on model class (new likelihood)
      switch class(model)
        case 'ssm'
          [loglk2mdl1 SNR] = ssm.loglikelihood(xn,in,out,nse,model(:,k),param{k}, spl(k), Amats{k}, Bmats{k}, Cmats{k}, Dmats{k});
        case 'smodel'
          loglk2mdl1 = utils.math.loglikelihood(xn,in,out,nse,model(:,k),param{k});
        case 'matrix'
          [loglk2mdl1 SNR] = utils.math.loglikelihood_matrix(xn,in,out,nse,model(:,k),param{k},inModel,outModel);
        otherwise
          error('### Model must be from the ''ssm'' class. Please check the inputs')
      end
    end
    
    % compute betta
    betta = computeBetta(nacc,Tc,xi);
    
    % metropolis sampler
    [xo x0 loglk1mdl1 loglk2mdl1 rj] = mhsmpl(k,betta,xn,xo,loglk1mdl1,loglk2mdl1);
    
    % update parameters (dimension matching)
    if ~rj
     for gg = 1:nummodels
      xo{gg} = updateparams(param,xo,k,gg);
     end
    end
    
    % draw random integer to jump into model
    % (supposed equal probability to jump to any model including the present one)
    k_new = randi(nummodels,1);
        
    % propose new point in new model k'
    xn_new = propose(xo{k_new},cov{k_new},search,Tc,jumps,hjump,nacc,sumsamples);

    % check if out of limits for new model
    if( any(xn_new < limit{k_new}(1,:)) || any(xn_new > limit{k_new}(2,:)))

        loglk2mdl2 = inf;
        
    else
    % switch depending on model class (new likelihood for proposed model k')
      switch class(model(k_new))
        case 'ssm'
          [loglk2mdl2 SNR] = ssm.loglikelihood(xn_new,in,out,nse,model(:,k_new),param{k_new}, spl(k_new), Amats{k_new}, Bmats{k_new}, Cmats{k_new}, Dmats{k_new});
        case 'smodel'
          loglk2mdl2 = utils.math.loglikelihood(xn_new,in,out,nse,model(:,k_new),param{k_new});
        case 'matrix'
          [loglk2mdl2 SNR] = utils.math.loglikelihood_matrix(xn_new,in,out,nse,model(:,k_new),param{k_new},inModel,outModel);
        otherwise
          error('### Model must be from the ''ssm'' class. Please check the inputs')
      end
    end
    
    % calculate proposal densities
    logq1 = logprpsl(xo{k},x0,cov{k});
    logq2 = logprpsl(xn_new,xo{k_new},cov{k_new});
    
    % get prior densities
    logp1 = logp{k};
    logp2 = logp{k_new};
    
    % ratio (independent proposals => Jacobian = 1)
    logr = (loglk2mdl2 - loglk2mdl1 + logq2 - logq1 + logp2 - logp1);    
    % decide if sample in new model is accepted or not
    if logr < 0
      xo{k_new} = xn_new;  
      nacc = nacc+1;
      sumsamples = nacc + rejected;
      mnacc(nacc,:) = mnacc(nacc-1,:);
      mnacc(nacc,k_new) = mnacc(nacc-1,k_new) + 1;
      smpl(nacc-1,k_new) = loglk2mdl2; 
      chains{k_new}(mnacc(nacc,k_new) -1,:) = xn_new;
      if (k ~= k_new); smpl(nacc,k) = loglk2mdl1; end
      k = k_new;
      % update parameters again
      for gg = 1:nummodels
       xo{gg} = updateparams(param,xo,k,gg);
      end
      if dbg_info
       utils.helper.msg(msg.IMPORTANT, sprintf('acc new k: %d   loglik: %d   SNR: %d  betta: %d  ratio: %d    ',k_new,loglk2mdl2,SNR,betta,logr));
      end
    elseif rand(1) > (1 - exp(-logr))
      xo{k_new} = xn_new;  
      nacc = nacc+1;
      sumsamples = nacc + rejected;
      mnacc(nacc,:) = mnacc(nacc-1,:);
      mnacc(nacc,k_new) = mnacc(nacc-1,k_new) + 1;
      smpl(nacc,k_new) = loglk2mdl2; 
      chains{k_new}(mnacc(nacc,k_new) -1,:) = xn_new;
      if (k ~= k_new); smpl(nacc,k) = loglk2mdl1; end
      k = k_new;
      % update parameters again
      for gg = 1:nummodels
       xo{gg} = updateparams(param,xo,k,gg);
      end
      if dbg_info
       utils.helper.msg(msg.IMPORTANT, sprintf('acc new k: %d   loglik: %d   SNR: %d  betta: %d  ratio: %d    ',k_new,loglk2mdl2,SNR,betta,logr));      
      end
    elseif isnan(logr)
        rejected = rejected + 1;
        sumsamples = nacc + rejected;
        if dbg_info
        utils.helper.msg(msg.IMPORTANT, sprintf('rejected: %d out of bounds    ',rejected));      
        end
    else   
      nacc = nacc+1;
      sumsamples = nacc + rejected;
      mnacc(nacc,:) = mnacc(nacc-1,:);
      mnacc(nacc,k) = mnacc(nacc-1,k) + 1;
      chains{k}(mnacc(nacc,k) -1,:) = xo{k};
      if (k ~= k_new); smpl(nacc,k_new) = loglk2mdl2; end
      % printing on screen the correct things
      if rj
       smpl(nacc,k) = loglk1mdl1;
        if dbg_info
          utils.helper.msg(msg.IMPORTANT, sprintf('acc old k: %d   loglik: %d   SNR: %d  betta: %d  ratio: %d    ',k,loglk1mdl1,SNR,betta,logr));
        end
      else
       smpl(nacc,k) = loglk2mdl1;
       if (k ~= k_new); smpl(nacc,k_new) = loglk2mdl2; end
       xo{k} = xn;
        if dbg_info
          utils.helper.msg(msg.IMPORTANT, sprintf('acc old k: %d   loglik: %d   SNR: %d  betta: %d  ratio: %d    ',k,loglk2mdl1,SNR,betta,logr));
        end
      end          
    end 
    
    str = [];
    % printing to screen the following: "acc(#_of_model): # of points in
    % model #_of_model" for ii = 1:nummodels
    if dbg_info
      for ii = 1:nummodels
        str = [str sprintf('acc%d: %d   ',ii,mnacc(nacc,ii))];
      end
      utils.helper.msg(msg.IMPORTANT, str);
    end
    
    % the handshake problem 
    for gg = 1:(nummodels)
      for dd = gg+1:(nummodels)
        %calculate Bayes Factor 
        Bxy{gg,dd}(nacc,1) = mnacc(nacc,gg)/mnacc(nacc,dd);               
      end
    end
    
    % plot Bayes factor
    if (parplot && (mod(summ,500) == 0) && (nacc ~= 0))
     figure(1)
     for gg = 1:(nummodels)
       for dd = gg+1:(nummodels)
          legen = [legen ; sprintf('B%d%d',gg,dd)]; % legend
          plot(Bxy{gg,dd}(:,1),'color',colour{gg,dd}) 
          legend(legen)
          hold on
        end 
     end
    hold off
    legen = [];
    end
    
   % plot LogLikelihood for each model 
   if (parplot && (mod(summ,100) == 0) && (nacc ~= 0)) 
    figure (2)
     for jj = 3:(nummodels+2)
       %if  (mnacc(nacc,jj-2) ~= 0)
       smpl(smpl==0) = nan;
       plot(smpl(1:nacc,jj-2),'color',coloor(jj-2,:))
       ylabel('Log-Likelihoods')
       legen = [legen ; sprintf('model%d',jj-2)]; % legend
       legend(legen)
       hold on
       %end
     end
   hold off
   legen = [];
   end
   
   % display and save
   if (~dbg_info && (mod(summ,1000) == 0) && (nacc ~= 2))
     str = [];
     utils.helper.msg(msg.IMPORTANT, sprintf('#### Number of samples collected so far: %d,   Stop at: %d samples.',nacc,number), mfilename('class'), mfilename);
     for ii = 1:nummodels
        str = [str sprintf('acc%d: %d   ',ii,mnacc(nacc,ii))];
     end
     utils.helper.msg(msg.IMPORTANT, ['#### ' str]);
   end
   
   % sum of points (used for plotting mainly -> avoid repeated ploting). 
   summ = summ+1; 
  end
  LogL = smpl;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      metropolis algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xo x0 loglk1 loglk2 rejected] = mhsmpl(k,betta,xn,xo,loglk1,loglk2)

x0 = xo{k};
logalpha = betta*(loglk2 - loglk1);
        
if logalpha < 0
  xo{k} = xn;
  loglk1 = loglk2;
  rejected = 0;
elseif rand(1) > (1 - exp(-logalpha))
  xo{k} = xn;
  loglk1 = loglk2;
  rejected = 0;
else
  rejected = 1;
  loglk2 = loglk1;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      propose a new jump function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xn hjump]= propose(xo,cov,search,Tc,jumps,hjump,nacc,sumsamples)

  if search
    if nacc <= Tc(1)          
      if(mod(sumsamples,5) == 0 && mod(sumsamples,25) ~= 0 && mod(sumsamples,40) ~= 0 && hjump  ~= 1)
        hjump = 1;
        xn = utils.math.drawSample(xo,jumps(2)^2*cov);       
      elseif(mod(sumsamples,20) == 0 && mod(sumsamples,50) ~= 0 && hjump  ~= 1)
        hjump = 1;
        xn = utils.math.drawSample(xo,jumps(3)^2*cov);
      elseif(mod(sumsamples,10) == 0 && hjump  ~= 1)
        hjump = 1;
        xn = utils.math.drawSample(xo,jumps(4)^2*cov);
      else
        hjump = 0;
        xn = utils.math.drawSample(xo,jumps(1)^2*cov);
      end
    elseif nacc <= Tc(2) && nacc > Tc(1)
      if(mod(sumsamples,5) == 0 && mod(sumsamples,25) ~= 0 && mod(sumsamples,40) ~= 0 && hjump  ~= 1)
        hjump = 1;
        xn = utils.math.drawSample(xo,jumps(2)^2*cov);       
      elseif(mod(sumsamples,20) == 0 && mod(sumsamples,50) ~= 0 && hjump  ~= 1)
        hjump = 1;
        xn = utils.math.drawSample(xo,jumps(3)^2*cov);
      elseif(mod(sumsamples,10) == 0 && hjump  ~= 1)
        hjump = 1;
        xn = utils.math.drawSample(xo,jumps(4)^2*cov);
      else
        hjump = 0;
        xn = utils.math.drawSample(xo,jumps(1)^2*cov);
      end
    else
      xn = utils.math.drawSample(xo,jumps(1)*cov);
    end
  else
    xn = utils.math.drawSample(xo,jumps(1)*cov);
  end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      compute heat factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function betta = computeBetta(nacc,Tc,xi)

  if ~isempty(Tc)
    if nacc <= Tc(1)  
      betta = 1/2 * 10^(-xi*(1-Tc(1)/Tc(2)));
    elseif Tc(1) < nacc  && nacc <= Tc(2)
      betta = 1/2 * 10^(-xi*(1-nacc/Tc(2)));
    else
      betta = 1/2;
    end
  end  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      update parameters function (dimension matching)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xn = updateparams(param,xo,k,kn)

    % dimension difference of models
    dimdif = abs(size(param{kn},2) - size(param{k},2));  
    % mark the different parameters
    difparams = setxor(param{kn},param{k});
    % total number of different parameters
    totalnumdifpar = numel(difparams);
    kk = 0;
    
    % case: dimension difference equals the # of different parameters
    % and dim(model(k')) > dim(model(k))
    if (dimdif == totalnumdifpar && size(param{kn},2) > size(param{k},2))
        
       xn = zeros(size(xo{kn}));
       for ii = 1:min(size(difparams,2)) 
         compvec{ii} = strcmp(difparams{ii},param{kn});   
         position(ii) = find(compvec{ii});               % mark the positions of the different parameters
         xn(position(ii)) = xo{kn}(position(ii));
       end     
       for jj = 1:size(param{kn},2)
        if (jj ~= position)
           kk = kk+1;
           xn(jj) = xo{k}(kk);
        end
       end
    
    % case: dimension difference equals the # of different parameters
    % and dim(model(k')) < dim(model(k))   
    elseif (dimdif == totalnumdifpar && size(param{kn},2) < size(param{k},2))
        
       xn = zeros(size(xo{kn}));
       for ii = 1:min(size(difparams,2)) 
         compvec{ii} = strcmp(difparams{ii},param{k});   
         position(ii) = find(compvec{ii});                
       end     
       for jj = 1:size(param{k},2)
        if (jj ~= position)
           kk = kk+1;
           xn(kk) = xo{k}(jj);
        end
       end
    
    % case: dimension difference is smaller than the # of different parameters
    % and dim(model(k')) > dim(model(k))
    elseif (dimdif < totalnumdifpar && size(param{kn},2) > size(param{k},2))
        
       xn = zeros(size(xo{kn}));
       for ii = 1:min(size(difparams,2)) 
         compvec{ii} = strcmp(difparams{ii},param{kn}); 
           if any(compvec{ii})
           position(ii) = find(compvec{ii});                
           xn(position(ii)) = xo{kn}(position(ii));
           end
       end     
       for jj = 1:size(param{kn},2)
        if (jj ~= position)
           kk = kk+1;
           xn(jj) = xo{k}(kk);
        end
       end
    
    % case: dimension difference is smaller than the # of different parameters
    % and dim(model(k')) < dim(model(k))   
    elseif (dimdif < totalnumdifpar && size(param{kn},2) < size(param{k},2))
        
       xn = zeros(size(xo{kn}));
       for ii = 1:size(param{kn},2) 
         compvec{ii} = strcmp(param{kn}{ii},param{k});
         if any(compvec{ii})
         position(ii) = find(compvec{ii});                
         %xn(position(ii)) = xo{k}(position(ii)); 
         else
         kk = kk+1;
         compvec{ii} = strcmp(param{kn}{ii},param{kn});
         position2(kk) = find(compvec{ii});
         xn(position2(kk)) = xo{kn}(position2(kk));  
         position(ii) = 0;
         end
       end
       kk = 0;
       for jj = 1:size(param{kn},2)
        if (position(jj) ~= 0)
           xn(jj) = xo{k}(position(jj));
        end
       end   
       
    % case: dimension difference is smaller than the # of different parameters
    % and dim(model(k')) = dim(model(k))   
    elseif (dimdif < totalnumdifpar && size(param{kn},2) == size(param{k},2))
        
       xn = zeros(size(xo{kn}));
       for ii = 1:min(size(difparams,2)) 
         compvec{ii} = strcmp(difparams{ii},param{kn}); 
           if any(compvec{ii})
           position(ii) = find(compvec{ii});                
           xn(position(ii)) = xo{kn}(position(ii));
           else 
           position = 0;  
           end
       end     
       for jj = 1:size(param{kn},2)
        if (jj ~= position)
           kk = kk+1;
           xn(jj) = xo{k}(kk);
        end
       end
     
    % case: new model proposed is the same as the previous one (k' == k).
    % That means we perform again the metropolis algorithm.
    elseif (totalnumdifpar == 0 && size(param{kn},2) == size(param{k},2))
       
       xn = xo{k};
        
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      compute proposal density
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function logq = logprpsl(X,mean,cov)

logq = log(mvnpdf(X,mean,cov));

if (logq == -Inf || logq == Inf) 
  logq = 0; 
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      logpriors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function logp = logpriors(r)

  logp = sum(log(1 ./ (r(2,:) - r(1,:))));

end

