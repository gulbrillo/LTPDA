%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Metropolis algorithm
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function smpl = mhsample_td(model,in,out,cov,number,limit,parnames,Tc,xi,xo,search,jumps,parplot,dbg_info,inNames,outNames,Noise,cutbefore,cutafter)
  
  import utils.const.*
  
  % compute mean and range
  mn = mean(limit);
  range = diff(limit);
  % initialize
  acc = [];
  nacc = 1;
  nrej = 1;
  loop = 0;
  oldacc = 0;
  oldrej = 0;
  chgsc = 0;
  nparnames = length(parnames);
  
  
  % switch depending on model class (initial likelihood)
  switch class(model)
    case 'matrix'
%       loglk1 = utils.math.loglikehood_matrix(xo,in,out,nse,model,parnames);
%       loglk1 = utils.math.loglikehood_matrix(xo,in,out,nse,model,parnames,inModel,outModel);
    case 'smodel'
%       loglk1 = utils.math.loglikehood(xo,in,out,nse,model,parnames);
    case 'ssm'
      loglk1 = utils.math.loglikehood_ssm_td(xo,in,out,parnames,model,inNames,outNames,Noise,'cutbefore',cutbefore,'cutafter',cutafter);
    otherwise
      error('### Model must be either from the ''smodel'' or the ''ssm'' class. Please check the inputs')
  end
  
  % accept the first sample if no search active
  if ~search
    smpl(1,:) = xo;
    nacc = 1;
  else
    smpl = [];
    nacc = 0;
  end
  nrej = 0;
  
  utils.helper.msg(msg.IMPORTANT, 'Starting Monte Carlo sampling', mfilename('class'), mfilename);
  
  
  hjump = 0;
  % main loop
  while(nacc<number)
    %    jumping criterion during search phase
    %    - 2-sigma  by default
    %    - 10-sigma  jumps at mod(10) samples
    %    - 100-sigma jumps at mod(25) samples
    %    - 1000-sigma jumps at mod(100) samples
    if search
      if nacc <= Tc(1)
        if(mod(nacc,10) == 0 && mod(nacc,25) ~= 0 && mod(nacc,100) ~= 0 && hjump  ~= 1)
          hjump = 1;
          xn = mvnrnd(xo,jumps(2)^2*cov);
        elseif(mod(nacc,25) == 0 && mod(nacc,100) ~= 0 && hjump  ~= 1)
          hjump = 1;
          xn = mvnrnd(xo,jumps(3)^2*cov);
        elseif(mod(nacc,100) == 0 && hjump  ~= 1)
          hjump = 1;
          xn = mvnrnd(xo,jumps(4)^2*cov);
          %           xn = xo + range/2+rand(size(xo));
        else
          hjump = 0;
          xn = mvnrnd(xo,jumps(1)^2*cov);
        end
      else
        xn = mvnrnd(xo,cov);
      end
    else
      xn = mvnrnd(xo,cov);
    end
    
    % check if out of limits
    if( any(xn < limit(1,:)) || any(xn > limit(2,:)))
      logprior =  inf;
      loglk2 = inf;
      betta = inf;
    else
      % compute annealing
      if ~isempty(Tc)
        if nacc <= Tc(1)
          betta = 1/2 * 10^(-xi*(1-Tc(1)/Tc(2)));
        elseif Tc(1) < nacc  && nacc <= Tc(2)
          betta = 1/2 * 10^(-xi*(1-nacc/Tc(2)));
        else
          betta = 1/2;
        end
      else
        betta = 1/2;
      end
      % switch depending on model class (new likelihood)
      switch class(model)
        case 'matrix'
%           loglk2 = utils.math.loglikehood_matrix(xn,in,out,nse,model,parnames,inModel,outModel);
        case 'smodel'
%           loglk2 = utils.math.loglikehood(xn,in,out,nse,model,parnames);
        case 'ssm'
          loglk2 = utils.math.loglikehood_ssm_td(xn,in,out,parnames,model,inNames,outNames,Noise,'cutbefore',cutbefore,'cutafter',cutafter);
        otherwise
          error('### Model must be either from the ''smodel'' or the ''ssm'' class. Please check the inputs')
      end
    end
    
    % likelihood ratio
    logr = betta*(loglk2 - loglk1) ;
    % decide if sample is accepted or not
    if logr < 0
      xo = xn;
      nacc = nacc+1;
      smpl(nacc,:) = xn;
      loglk1 =loglk2;
      if dbg_info
        utils.helper.msg(msg.IMPORTANT, sprintf('acc.\t loglik: %d -> %d  betta: %d  ratio: %d',loglk1,loglk2,betta,logr), mfilename('class'), mfilename);
      end
    elseif rand(1) > (1 - exp(-logr))
      xo = xn;
      nacc = nacc+1;
      smpl(nacc,:) = xn;
      loglk1 =loglk2;
      if dbg_info
        utils.helper.msg(msg.IMPORTANT, sprintf('acc.\t loglik: %d -> %d  betta: %d  ratio: %d',loglk1,loglk2,betta,logr), mfilename('class'), mfilename);
      end
    else
      nrej = nrej+1;
      if dbg_info
        utils.helper.msg(msg.IMPORTANT, sprintf('rej.\t loglik: %d -> %d  betta: %d  ratio: %d',loglk1,loglk2,betta,logr), mfilename('class'), mfilename);
      end
    end
    
    % display and save
    if(mod(nacc,100) == 0 && nacc ~= oldacc)
      updacc = nacc-oldacc;
      updrej = nrej-oldrej;
      ratio(nacc/10,:) = updacc/(updacc+updrej);
      utils.helper.msg(msg.IMPORTANT, sprintf('accepted: %d   rejected : %d   acc. rate: %4.2f',nacc,updrej,ratio(end)), mfilename('class'), mfilename);
      for i = 1:numel(parnames)
        fprintf('###  Parameters: %s = %d \n',parnames{i},xn(i))
      end
      oldacc = nacc;
      oldrej = nrej;
      save('chain.txt','smpl','-ASCII')
      save('acceptance.txt','ratio','-ASCII')
    end
    
    % plot 
    if ((mod(nacc,100) == 0) && (nacc ~= 0) && ~isempty(parplot))
      for i = 1:numel(parplot)
        figure(parplot(i))
        plot(smpl(:,parplot(i)))
      end
    end
    
  end
end
