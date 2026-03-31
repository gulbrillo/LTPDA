% CSD2TF Input cross spectral density matrix and output stable transfer function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:
%
%     Input cross spectral density (csd) and output corresponding
%     stable functions. Identification can be performed for a simple system
%     (one psd) or for a N dimensional system. Discrete transfer functions are
%     output in partial fraction expansion:
%
%                r1                  rN
%     f(z) = ----------- + ... + ----------- + d
%            1-p1*z^{-1}         1-pN*z^{-1}
%
%     System identification is performed in frequency domain, the order of
%     the model function is automatically chosen by the algorithm on the
%     base of the input tolerance condition.
%     In the case of simple systems the square root of the psd is fitted
%     and then the model is stabilized by the application of an all-pass
%     function.
%     In the case of two dimensional systems, transfer functions frequency
%     response is calculated by the eigendecomposition of the
%     cross-spectral matrix. Then models are identified by fitting
%     in frequency domain.
%
% CALL:
%           out = csd2tf(csd,f,params)
%
% INPUT:
%
%     - csd is the cross spectral density matrix. It is in general a
%     [n,n,m] dimensional matrix. Where n is the dimension of the system
%     and m is the number of frequencies
%     - f: is the corresponding frequencies vector in Hz (of length m)
%     - params: is a struct of identification options, the possible values
%     are:
%
%       params.TargetDomain = 'z' --> Perform z domain identification.
%       Function output are residues and poles of a discrete system.
%       params.TargetDomain = 's' --> Perform s domain identification.
%       Function output are residues and poles of a continuous system.
% 
%       params.fullauto = 0 --> Perform a fitting loop as far as the number
%       of iteration reach Nmaxiter. The order of the fitting function will
%       be that specified in params.minorder. If params.dterm is setted to
%       1 the function will fit only with direct term.
%       params.fullauto = 1 --> Parform a full automatic search for the
%       transfer function order. The fitting procedure will stop when the
%       stopping condition defined in params.ctp is satisfied. Default
%       value.
%
%       - params.Nmaxiter = # set the maximum number of fitting steps
%       performed for each trial function order. Default is 50
%
%       - params.minorder = # set the minimum possible function order.
%       Default is 2
%
%       - params.maxorder = # set the maximum possible function order.
%       Default is 25
%
%       params.spolesopt = 1 --> use real starting poles
%       params.spolesopt = 2 --> generates complex conjugates poles of the
%       type \alfa e^{j\pi\theta} with \theta = linspace(0,pi,N/2+1).
%       params.spolesopt = 3 --> generates complex conjugates poles of the
%       type \alfa e^{j\pi\theta} with \theta = linspace(0,pi,N/2+2).
%       Default option.
%
%       - params.weightparam = 0 --> use external weights
%       - params.weightparam = 1 equal weights (one) for each point
%       - params.weightparam = 2 weight with the inverse of absolute value
%       of fitting data
%       - params.weightparam = 3 weight with square root of the inverse of
%       absolute value of fitting data
%       - params.weightparam = 4 weight with the inverse of the square mean
%       spread
%
%       params.extweights = [] --> A vector of externally provided weights.
%       It has to be of the same size of input data.
%
%       - params.plot = 0 --> no plot during fit iteration
%       - params.plot = 1 --> plot results at each fitting steps. default
%       value.
%
%       - params.ctp = 'chival' --> check if the value of the Mean Squared
%       Error is lower than 10^(-1*lsrcond).
%       - params.ctp = 'chivar' --> check if the value of the Mean Squared
%       Error is lower than 10^(-1*lsrcond) and if the relative variation of mean
%       squared error is lower than 10^(-1*msevar).
%       - params.ctp = 'lrs' --> check if the log difference between data and
%       residuals is point by point larger than the value indicated in
%       lsrcond. This mean that residuals are lsrcond order of magnitudes
%       lower than data.
%       - params.ctp = 'lrsmse' --> check if the log difference between data
%       and residuals is larger than the value indicated in lsrcond and if
%       the relative variation of mean squared error is lower than
%       10^(-1*msevar).
%
%       - params.lrscond = # --> set conditioning value for point to point
%       log residuals difference (params.ctp = 'lsr') and mean log residual
%       difference (params.ctp = 'mlsrvar'). Default is 2. See help for
%       stopfit.m for further remarks.
%
%       - params.msevar = # --> set conditioning value for root mean squared
%       error variation. This allow to check that the relative variation of
%       mean squared error is lower than 10^(-1*msevar).Default is 7. See
%       help for stopfit.m for further remarks.
%
%       - params.fs set the sampling frequency (Hz). Default is 1 Hz
%
%       params.dterm = 0 --> Try to fit without direct term
%       params.dterm = 1 --> Try to fit with and without direct term
%
%       params.spy = 0 --> Do not display the iteration progression
%       params.spy = 1 --> Display the iteration progression
% 
%       params.usesym = 0 --> perform double-precision calculation for
%       poles stabilization
%       params.usesym = 1 --> perform symbolic math toolbox calculation for
%       poles stabilization
%
%
% OUTPUT:
% 
%     - ostruct is a struct with the fields:
%       - ostruct(n).res --> is the vector of residues.
%       - ostruct(n).poles --> is the vector of poles.
%       - ostruct(n).dterm --> is the vector of direct terms.
%       - ostruct(n).mresp --> is the vector of tfs models responses.
%       - ostruct(n).rdl --> is the vector of fit residuals.
%       - ostruct(n).mse --> is the vector of mean squared errors.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ostruct = csd2tf2(csd,f,params)
  
  utils.helper.msg(utils.const.msg.MNAME, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect inputs
  
  % Default input struct
  defaultparams = struct('TargetDomain','z','Nmaxiter',50, 'minorder',2,...
    'maxorder',25, 'spolesopt',2, 'weightparam',1, 'plot',0,...
    'ctp','chival','lrscond',2,'msevar',2,...
    'fs',1,'dterm',0, 'spy',0, 'fullauto',1,...
    'extweights', [],'usesym',1);
  
  names = {'TargetDomain','Nmaxiter','minorder','maxorder','spolesopt',...
    'weightparam','plot','stopfitcond',...
    'ctp','lrscond','msevar',...
    'fs','dterm','spy','fullauto','extweights',...
    'usesym'};
  
  % collecting input and default params
  if ~isempty(params)
    for jj=1:length(names)
      if isfield(params, names(jj)) && ~isempty(params.(names{1,jj}))
        defaultparams.(names{1,jj}) = params.(names{1,jj});
      end
    end
  end
  
  % default values for input variables
  target = defaultparams.TargetDomain; % target domain for system identification, can be 'z' or 's'
  Nmaxiter = defaultparams.Nmaxiter; % Number of max iteration in the fitting loop
  minorder = defaultparams.minorder; % Minimum model order
  maxorder = defaultparams.maxorder; % Maximum model order
  spolesopt = defaultparams.spolesopt; % 0, Fit with no complex starting poles (complex poles can be found as fit output). 1 fit with comples starting poles
  weightparam = defaultparams.weightparam; % Weight 1./abs(y). Admitted values are 0, 1, 2, 3
  checking = defaultparams.plot; % Never polt. Admitted values are 0 (No polt ever), 1 (plot at the end), 2 (plot at each step)
  ctp = defaultparams.ctp;
  lrscond = defaultparams.lrscond;
  msevar = defaultparams.msevar;
  fs = defaultparams.fs; % sampling frequency
  idt = defaultparams.dterm;
  spy = defaultparams.spy;
  autosearch = defaultparams.fullauto;
  extweights = defaultparams.extweights;
  usesym = defaultparams.usesym; % method of calculation for the all pass filter
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Checking inputs
  
  [a,b] = size(f);
  if a < b % shifting to column
    f = f.';
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % switching between inputs
  
  clear dim
  % cecking for dimensionality
  [nn,mm,kk] = size(csd);
  if kk == 1
    dim = '1dim';
    utils.helper.msg(utils.const.msg.PROC1, ' Performing one dimesional identification on psd ')
    if nn < mm % shift to column
      csd = csd.';
    end
  else
    dim ='ndim';
    utils.helper.msg(utils.const.msg.PROC1, ' Performing N dimesional identification on csd ')
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % system identification
  
  switch dim
    case '1dim'
      
      utils.helper.msg(utils.const.msg.PROC1, ' Performing z-domain identification ')
      itf = abs(sqrt(csd)); % input data
      
      switch target % switch between z-domain and s-domain
        case 'z'
          % Fitting params
          params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
            'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
            'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
            'stabfit',0,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',extweights);

          % Fitting
          utils.helper.msg(utils.const.msg.PROC1, ' Fitting absolute TF value with unstable model ')
          [res,poles,dterm,mresp,rdl,msei] = utils.math.autodfit(itf,f,fs,params);

          if usesym
            % all pass filtering for poles stabilization
            allpoles.poles = poles;
            ntf = utils.math.pfallpsymz2(allpoles,mresp,f,fs);
          else
            % all pass filtering for poles stabilization
            ntf = utils.math.pfallpz2(poles,mresp,f,fs);
          end

          % Fitting params
          params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
            'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
            'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
            'stabfit',1,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',extweights);

          utils.helper.msg(utils.const.msg.PROC1, ' Fitting TF with stable model ')
          [res,poles,dterm,mresp,rdl,msef] = utils.math.autodfit(ntf,f,fs,params);

          % Output data switching between output type
          utils.helper.msg(utils.const.msg.PROC1, ' Output z-domain model ')
          
        case 's'
           % Fitting params
          params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
            'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
            'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
            'stabfit',0,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',extweights);

          % Fitting
          utils.helper.msg(utils.const.msg.PROC1, ' Fitting absolute TF value with unstable model ')
          [res,poles,dterm,mresp,rdl,msei] = utils.math.autocfit(itf,f,params);

          if usesym
            % all pass filtering for poles stabilization
            allpoles.poles = poles;
            ntf = utils.math.pfallpsyms2(allpoles,mresp,f);
          else
            % all pass filtering for poles stabilization
            ntf = utils.math.pfallps2(poles,mresp,f);
          end

          % Fitting params
          params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
            'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
            'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
            'stabfit',1,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',extweights);

          utils.helper.msg(utils.const.msg.PROC1, ' Fitting TF with stable model ')
          [res,poles,dterm,mresp,rdl,msef] = utils.math.autocfit(ntf,f,params);

          % Output data switching between output type
          utils.helper.msg(utils.const.msg.PROC1, ' Output s-domain model ')

      end
      
      ostruct = struct();
      
      ostruct.res = res;
      ostruct.poles = poles;
      ostruct.dterm = dterm;
      ostruct.mresp = mresp;
      ostruct.rdl = rdl;
      ostruct.mse = msei;
      
    case 'ndim'
      % switching between continuous and discrete type identification
      
%       utils.helper.msg(utils.const.msg.PROC1, ' Performing z-domain identification on 2dim system, z-domain output ')
      tf = utils.math.ndeigcsd(csd,'OTP','TF','MTD','PAP'); % input data
      
      [nn,mm,kk] = size(tf);
      
%       % Shifting to columns
%       [a,b] = size(tf11);
%       if a<b
%         tf11 = tf11.';
%       end
%       [a,b] = size(tf12);
%       if a<b
%         tf12 = tf12.';
%       end
%       [a,b] = size(tf21);
%       if a<b
%         tf21 = tf21.';
%       end
%       [a,b] = size(tf22);
%       if a<b
%         tf22 = tf22.';
%       end
%       
%       % Collecting tfs
%       f1 = [tf11 tf21];
%       f2 = [tf12 tf22];
      
      %%% System identification
      
      % init output
      ostruct = struct();
      idx = 1;
      
      for dd = 1:mm
        fun = squeeze(tf(1,dd,:));
        % willing to work with columns
        [a,b] = size(fun);
        if a<b
          fun = fun.';
        end
        for ff = 2:nn
          tfun = squeeze(tf(ff,dd,:));
          % willing to work with columns
          [a,b] = size(tfun);
          if a<b
            tfun = tfun.';
          end
          fun = [fun tfun];
        end
        
        switch target % switch between z-domain and s-domain
          case 'z'
            for pp = 1:size(fun,2)

              % Fitting with unstable poles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
                'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
                'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
                'stabfit',0,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',extweights);

              % Fitting
              utils.helper.msg(utils.const.msg.PROC1, ' Fitting with unstable common poles ')
              [res,poles,dterm,tmresp,trdl,tmsei] = utils.math.autodfit(fun(:,pp),f,fs,params);

              allpoles(pp).poles = poles;
              mresp(:,pp) = tmresp;
              rdl(:,pp) = trdl;
              msei(:,pp) = tmsei;

            end

            if usesym
              % Poles stabilization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              utils.helper.msg(utils.const.msg.PROC1, ' All pass filtering')
              nfun = utils.math.pfallpsymz2(allpoles,mresp,f,fs);
            else
              % Poles stabilization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              utils.helper.msg(utils.const.msg.PROC1, ' All pass filtering')
              nfun = utils.math.pfallpz2(allpoles,mresp,f,fs);
            end

            clear poles

            % Fitting with stable poles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            for zz = 1:size(fun,2)

              % Fitting params
              params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
                'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
                'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
                'stabfit',1,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',extweights);

              % Fitting
              utils.helper.msg(utils.const.msg.PROC1, ' Fitting with stable common poles ')
              [res,poles,dterm,tmresp,trdl,tmsef] = utils.math.autodfit(nfun(:,zz),f,fs,params);


              % Output stable model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

              ostruct(idx).res = res;
              ostruct(idx).poles = poles;
              ostruct(idx).dterm = dterm;
              ostruct(idx).mresp = mresp(:,zz);
              ostruct(idx).rdl = rdl(:,zz);
              ostruct(idx).mse = msei(:,zz);

              idx = idx + 1;

            end
            
          case 's'
            for pp = 1:size(fun,2)

              % Fitting with unstable poles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
                'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
                'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
                'stabfit',0,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',extweights);

              % Fitting
              utils.helper.msg(utils.const.msg.PROC1, ' Fitting with unstable common poles ')
              [res,poles,dterm,tmresp,trdl,tmsei] = utils.math.autocfit(fun(:,pp),f,params);

              allpoles(pp).poles = poles;
              mresp(:,pp) = tmresp;
              rdl(:,pp) = trdl;
              msei(:,pp) = tmsei;

            end

            if usesym
              % Poles stabilization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              utils.helper.msg(utils.const.msg.PROC1, ' All pass filtering')
              nfun = utils.math.pfallpsyms2(allpoles,mresp,f);
            else
              % Poles stabilization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              utils.helper.msg(utils.const.msg.PROC1, ' All pass filtering')
              nfun = utils.math.pfallps2(allpoles,mresp,f);
            end

            clear poles

            % Fitting with stable poles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            for zz = 1:size(fun,2)

              % Fitting params
              params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
                'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
                'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
                'stabfit',1,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',extweights);

              % Fitting
              utils.helper.msg(utils.const.msg.PROC1, ' Fitting with stable common poles ')
              [res,poles,dterm,tmresp,trdl,tmsef] = utils.math.autocfit(nfun(:,zz),f,params);


              % Output stable model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

              ostruct(idx).res = res;
              ostruct(idx).poles = poles;
              ostruct(idx).dterm = dterm;
              ostruct(idx).mresp = mresp(:,zz);
              ostruct(idx).rdl = rdl(:,zz);
              ostruct(idx).mse = msei(:,zz);

              idx = idx + 1;

            end
        
        end
        
      
        
        
      end
      
  end
end

% END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
