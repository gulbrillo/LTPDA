% PSD2TF Input power spectral density (psd) and output a stable and minimum
% phase transfer function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% DESCRIPTION:
% 
%     Input power spectral density (psd) and output a corresponding
%     stable function. Identification can be performed for a simple system
%     (one psd) or for a two dimensional system (the four elements of the
%     cross-spectral matrix). Continuous or discrete transfer functions are
%     output in partial fraction expansion: 
% 
%     Continuous case:
%              r1              rN
%     f(s) = ------- + ... + ------- + d
%            s - p1          s - pN
% 
%     Discrete case:
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
%     cross-spectral matrix. Then four models are identified with fitting
%     in frequency domain. If we call these new functions as tf11, tf12,
%     tf21 and tf22, it can be verified they are connected with the input
%     spectra by the relation:
% 
%     csd11(f) = tf11(f)*conj(tf11(f))+tf12(f)*conj(tf12(f))
%     csd12(f) = tf11(f)*conj(tf21(f))+tf12(f)*conj(tf22(f))
%     csd21(f) = conj(tf11(f))*tf21(f)+conj(tf12(f))*tf22(f)
%     csd22(f) = tf21(f)*conj(tf21(f))+tf22(f)*conj(tf22(f))
% 
% CALL:
% 
%     One dimensional system:
%     [res, poles, dterm] = psd2tf(psd,[],[],[],f,params)
%     [res, poles, dterm, mresp] = psd2tf(psd,[],[],[],f,params)
%     [res, poles, dterm, mresp, rdl] = psd2tf(psd,[],[],[],f,params)
% 
%     Two dimensional systems:
%     ostruct = psd2tf(csd11,csd12,csd21,csd22,f,params)
%     ostruct = psd2tf(csd11,csd12,[],csd22,f,params)
%     ostruct = psd2tf(csd11,[],csd21,csd22,f,params)
% 
% INPUT:
% 
%     - psd is the power spectral density (1dim case)
%     - csd11, csd12, csd21 and csd22 are the elements of the cross
%     spectral matrix. If csd12 is left empty, it is calculated as
%     conj(csd21). If csd21 is left empty, it is calculated as conj(csd12).
%     (2dim case)
%     - f: is the corresponding frequencies vector in Hz
%     - params: is a struct of identification options, the possible values
%     are:
%       - params.idtp = 0 s-domain identification --> s-domain output
%       - params.idtp = 1 z-domain identification --> z-domain output
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
%       z-domain
%       params.spolesopt = 1 --> use real starting poles
%       params.spolesopt = 2 --> generates complex conjugates poles of the
%       type \alfa e^{j\pi\theta} with \theta = linspace(0,pi,N/2+1).
%       params.spolesopt = 3 --> generates complex conjugates poles of the
%       type \alfa e^{j\pi\theta} with \theta = linspace(0,pi,N/2+2).
%       Default option.
%       
%       s-domain
%       params.spolesopt = 1 --> use real starting poles
%       params.spolesopt = 2 --> use logspaced complex starting poles.
%       Default option
%       params.spolesopt = 3 --> use linspaced complex starting poles
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
%       It has to be of the same size of input data. E.g.
%       w11,w12,w21,w22 they are assumed to be in spectral units therefore
%       they are normalized to the values of the input spectrum
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
%       - params.fs set the sampling frequency (Hz) useful for z-domain
%       identification. Default is 1 Hz
% 
%       - params.usesym = 0 perform double-precision calculation in the
%       eigendecomposition procedure to identify 2dim systems and for poles
%       stabilization
%       - params.usesym = 1 uses symbolic math toolbox variable precision
%       arithmetic in the eigendecomposition for 2dim system identification
%       double-precison for poles stabilization
%       - params.usesym = 2 uses symbolic math toolbox variable precision
%       arithmetic in the eigendecomposition for 2dim system identification
%       and for poles stabilization
% 
%       - params.dig = # set the digit precision required for variable
%       precision arithmetic calculations. Default is 50
% 
%       params.dterm = 0 --> Try to fit without direct term
%       params.dterm = 1 --> Try to fit with and without direct term
% 
%       params.spy = 0 --> Do not display the iteration progression
%       params.spy = 1 --> Display the iteration progression
% 
% 
% OUTPUT:
% 
%     One Dimensional System
%     - res is the vector of residues.
%     - poles is the vector of poles.
%     - dterm is the direct term (if present).
%     - mresp is the model frequency response.
%     - rdl is the vector of residuals calculated as y - mresp.
% 
%     Two Dimensional System
%     - ostruct is a structure array with five fields and four elements.
%     Element 1 correspond to tf11 data, element 2 to tf12 data, element 3
%     to tf21 data and elemnt 4 to tf22 data.
%       - ostruct(n).res --> is the vector of residues.
%       - ostruct(n).poles --> is the vector of poles.
%       - ostruct(n).dterm --> are the tfs direct terms.
%       - ostruct(n).mresp --> are the tfs models freq. responses.
%       - ostruct(n).rdl --> are the residuals vectors.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = psd2tf(csd11,csd12,csd21,csd22,f,params)

  utils.helper.msg(utils.const.msg.MNAME, 'running %s/%s', mfilename('class'), mfilename);

  % Collect inputs

  % Default input struct
  defaultparams = struct('idtp',1, 'Nmaxiter',50, 'minorder',2,...
    'maxorder',25, 'spolesopt',2, 'weightparam',1, 'plot',0,...
    'ctp','chival','lrscond',2,'msevar',2,...
    'fs',1, 'usesym',0, 'dig',50, 'dterm',0, 'spy',0, 'fullauto',1,...
    'extweights', []);

  names = {'idtp','Nmaxiter','minorder','maxorder','spolesopt',...
    'weightparam','plot','stopfitcond',...
    'ctp','lrscond','msevar',...
    'fs','usesym','dig','dterm','spy','fullauto','extweights'};

  % collecting input and default params
  if ~isempty(params)
    for jj=1:length(names)
      if isfield(params, names(jj)) && ~isempty(params.(names{1,jj}))
       defaultparams.(names{1,jj}) = params.(names{1,jj});
      end
    end
  end

  % default values for input variables
  idtp = defaultparams.idtp; % identification type
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
  usesym = defaultparams.usesym; % method of calculation for the 2dim tfs calculation from psd
  dig = defaultparams.dig; % number of digits if VPA calculation is required
  idt = defaultparams.dterm;
  spy = defaultparams.spy;
  autosearch = defaultparams.fullauto;
  extweights = defaultparams.extweights;
  
  % rescaling input models to get correct results
  csd11 = csd11.*(fs/2);
  csd12 = csd12.*(fs/2);
  csd21 = csd21.*(fs/2);
  csd22 = csd22.*(fs/2);

  % Assign proper values to the control variables for symbolic calculations
  switch usesym
    case 0
      eigsym = 0;
      allsym = 0;
    case 1
      eigsym = 1;
      allsym = 0;
    case 2
      eigsym = 1;
      allsym = 1;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Checking inputs

  [a,b] = size(csd11);
  if a < b % shifting to column
    csd11 = csd11.';
  end
  
  if isempty(csd12)
    csd12 = [];
  else
    [a,b] = size(csd12);
    if a < b % shifting to column
      csd12 = csd12.';
    end
  end

  if isempty(csd21)
    csd21 = [];
  else
    [a,b] = size(csd21);
    if a < b % shifting to column
      csd21 = csd21.';
    end
  end
  
  [a,b] = size(csd22);
  if a < b % shifting to column
    csd22 = csd22.';
  end

  [a,b] = size(f);
  if a < b % shifting to column
    f = f.';
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Importing package
  import utils.math.*

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % switching between inputs

  clear dim
  % cecking for empty csd or psd2
  if all([isempty(csd12) isempty(csd21) isempty(csd22)])
    dim = '1dim';
    utils.helper.msg(utils.const.msg.PROC1, ' Empty csd12, csd21 and csd22; Performing one dimesional identification on psd ')
  else
    dim ='2dim';
    utils.helper.msg(utils.const.msg.PROC1, ' Performing two dimesional identification on csd11, csd12, csd21 and csd22 ')
  end

  switch dim
    case '1dim'
      % switching between continuous and discrete type identification
      switch idtp
        case 0
          utils.helper.msg(utils.const.msg.PROC1, ' Performing s-domain identification, s-domain output ')
          itf = abs(sqrt(csd11)); % input data
          
          % in case of externally provided weights
          if ~isempty(extweights)
            extweights = abs(extweights.*csd11./itf);
          end

          % Fitting params
          params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
          'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
          'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
          'stabfit',0,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',extweights);

          % Fitting
          utils.helper.msg(utils.const.msg.PROC1, ' Fitting absolute TF value with unstable model ')
          [res,poles,dterm,mresp,rdl,mse] = utils.math.autocfit(itf,f,params);

          % all pass filtering for poles stabilization
          if allsym
            [nr,np,nd,ntf] = utils.math.pfallpsyms(res,poles,dterm,mresp,f);
          else
            [ntf,np] = utils.math.pfallps(res,poles,dterm,mresp,f,false);
          end
          
          % Fitting params
          params = struct('spolesopt',0,'extpoles', np,...
          'Nmaxiter',Nmaxiter,'minorder',minorder,'maxorder',maxorder,...
          'weightparam',weightparam,'plot',checking,...
          'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
          'stabfit',1,...
          'dterm',idt,'spy',spy,'fullauto',autosearch,...
          'extweights',extweights);
        
          % Fitting
          utils.helper.msg(utils.const.msg.PROC1, ' Fitting TF with stable model ')
          [res,poles,dterm,mresp,rdl,mse] = utils.math.autocfit(ntf,f,params);

          % Output data switching between output type
          utils.helper.msg(utils.const.msg.PROC1, ' Output continuous model ')
          if nargout == 3
            varargout{1} = res;
            varargout{2} = poles;
            varargout{3} = dterm;
          elseif nargout == 4
            varargout{1} = res;
            varargout{2} = poles;
            varargout{3} = dterm;
            varargout{4} = mresp;
          elseif nargout == 5
            rdl = itf - abs(mresp); % residual respect to original function

            varargout{1} = res;
            varargout{2} = poles;
            varargout{3} = dterm;
            varargout{4} = mresp;
            varargout{5} = rdl;

          else
            error(' Unespected number of output. Set 3, 4 or 5! ')
          end
          
        case 1
          utils.helper.msg(utils.const.msg.PROC1, ' Performing z-domain identification ')
          itf = abs(sqrt(csd11)); % input data
          
          % in case of externally provided weights
          if ~isempty(extweights)
            extweights = abs(extweights.*csd11./itf);
          end

          % Fitting params
          params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
          'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
          'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
          'stabfit',0,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',extweights);

          % Fitting
          utils.helper.msg(utils.const.msg.PROC1, ' Fitting absolute TF value with unstable model ')
          [res,poles,dterm,mresp,rdl,mse] = utils.math.autodfit(itf,f,fs,params);

          % all pass filtering for poles stabilization
          if allsym
            [nr,np,nd,ntf] = utils.math.pfallpsymz(res,poles,dterm,mresp,f,fs);
          else
            [ntf,np] = utils.math.pfallpz(res,poles,dterm,mresp,f,fs,false);
          end
          
          % Fitting params
          params = struct('spolesopt',0,'extpoles', np,...
          'Nmaxiter',Nmaxiter,'minorder',minorder,'maxorder',maxorder,...
          'weightparam',weightparam,'plot',checking,...
          'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
          'stabfit',1,...
          'dterm',idt,'spy',spy,'fullauto',autosearch,...
          'extweights',extweights);
          
          utils.helper.msg(utils.const.msg.PROC1, ' Fitting TF with stable model ')
          [res,poles,dterm,mresp,rdl,mse] = utils.math.autodfit(ntf,f,fs,params);

          % Output data switching between output type
          utils.helper.msg(utils.const.msg.PROC1, ' Output z-domain model ')
          if nargout == 3
            varargout{1} = res;
            varargout{2} = poles;
            varargout{3} = dterm;
          elseif nargout == 4
            varargout{1} = res;
            varargout{2} = poles;
            varargout{3} = dterm;
            varargout{4} = mresp;
          elseif nargout == 5

            rdl = itf - abs(mresp); % residual respect to original function

            varargout{1} = res;
            varargout{2} = poles;
            varargout{3} = dterm;
            varargout{4} = mresp;
            varargout{5} = rdl;

          else
            error(' Unespected number of output. Set 3, 4 or 5! ')
          end

      end

    case '2dim'
      % switching between continuous and discrete type identification
      switch idtp
        case 0
          utils.helper.msg(utils.const.msg.PROC1, ' Performing s-domain identification on 2dim system, s-domain output ')
          [tf11,tf12,tf21,tf22] = utils.math.eigcsd(csd11,csd12,csd21,csd22,'USESYM',eigsym,'DIG',dig,'OTP','TF'); % input data

          % Shifting to columns
          [a,b] = size(tf11);
          if a<b
            tf11 = tf11.';
          end
          [a,b] = size(tf12);
          if a<b
            tf12 = tf12.';
          end
          [a,b] = size(tf21);
          if a<b
            tf21 = tf21.';
          end
          [a,b] = size(tf22);
          if a<b
            tf22 = tf22.';
          end

          % Collecting tfs
          f1 = [tf11 tf21];
          f2 = [tf12 tf22];
          
          % get external weights
          if ~isempty(extweights)
            % willing to work with columns
            [a,b] = size(extweights);
            if a<b
              extweights = extweights.';
            end
            wobj1 = [extweights(:,1).*abs(csd11./tf11) extweights(:,3).*abs(csd21./tf21)];
            wobj2 = [extweights(:,2).*abs(csd12./tf12) extweights(:,4).*abs(csd22./tf22)];
          else
            wobj1 = [];
            wobj2 = [];
          end

          % Fitting with unstable poles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

          % Fitting params
          params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
          'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
          'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
          'stabfit',0,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',wobj1);

          % Fitting
          utils.helper.msg(utils.const.msg.PROC1, ' Fitting TF11 and TF21 with unstable common poles ')
          [res1,poles1,dterm1,mresp1,rdl1,mse1] = utils.math.autocfit(f1,f,params);
          
          params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
          'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
          'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
          'stabfit',0,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',wobj2);

          utils.helper.msg(utils.const.msg.PROC1, ' Fitting TF12 and TF22 with unstable common poles ')
          [res2,poles2,dterm2,mresp2,rdl2,mse2] = utils.math.autocfit(f2,f,params);

          % Poles stabilization
          if allsym
            utils.helper.msg(utils.const.msg.PROC1, ' All pass filtering of TF11 and TF21, symbolic calc... ')
            [nr1,np1,nd1,nf1] = utils.math.pfallpsyms(res1,poles1,dterm1,mresp1,f);
            np1 = np1(:,1);
            utils.helper.msg(utils.const.msg.PROC1, ' All pass filtering of TF12 and TF22, symbolic calc... ')
            [nr2,np2,nd2,nf2] = utils.math.pfallpsyms(res2,poles2,dterm2,mresp2,f);
            np2 = np2(:,1);
          else
            utils.helper.msg(utils.const.msg.PROC1, ' All pass filtering of TF11 and TF21 ')
            [nf1,np1] = utils.math.pfallps(res1,poles1,dterm1,mresp1,f,false);
            np1 = np1(:,1);
            utils.helper.msg(utils.const.msg.PROC1, ' All pass filtering of TF12 and TF22 ')
            [nf2,np2] = utils.math.pfallps(res2,poles2,dterm2,mresp2,f,false);
            np2 = np2(:,1);
          end
          
          % Fitting with stable poles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

          % Fitting stable TF11 and TF21 with stable poles in s-domain
          % Fitting params
          params = struct('spolesopt',0,'Nmaxiter',Nmaxiter,...
          'minorder',minorder,'maxorder',maxorder,...
          'weightparam',weightparam,'plot',checking,...
          'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
          'stabfit',1,...
          'dterm',idt,'spy',spy,'fullauto',autosearch,...
          'extweights',wobj1,'extpoles', np1);

          % Fitting
          utils.helper.msg(utils.const.msg.PROC1, ' Fitting TF11 and TF21 with stable common poles ')
          [res1,poles1,dterm1,mresp1,rdl1,mse1] = utils.math.autocfit(nf1,f,params);
          
          % Fitting stable TF12 and TF22 with stable poles in s-domain
          % Fitting params
          params = struct('spolesopt',0,'Nmaxiter',Nmaxiter,...
          'minorder',minorder,'maxorder',maxorder,...
          'weightparam',weightparam,'plot',checking,...
          'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
          'stabfit',1,...
          'dterm',idt,'spy',spy,'fullauto',autosearch,...
          'extweights',wobj2,'extpoles', np2);
          
          % Fitting
          utils.helper.msg(utils.const.msg.PROC1, ' Fitting TF12 and TF22 with stable common poles ')
          [res2,poles2,dterm2,mresp2,rdl2,mse2] = utils.math.autocfit(nf2,f,params);

          % Output stable model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          ostruct = struct();

          % Data for tf11
          ostruct(1).res = res1(:,1);
          ostruct(1).poles = poles1;
          ostruct(1).dterm = dterm1(:,1);
          ostruct(1).mresp = mresp1(:,1);
          ostruct(1).rdl = rdl1(:,1);

          % Data for tf12
          ostruct(2).res = res2(:,1);
          ostruct(2).poles = poles2;
          ostruct(2).dterm = dterm2(:,1);
          ostruct(2).mresp = mresp2(:,1);
          ostruct(2).rdl = rdl2(:,1);

          % Data for tf21
          ostruct(3).res = res1(:,2);
          ostruct(3).poles = poles1;
          ostruct(3).dterm = dterm1(:,2);
          ostruct(3).mresp = mresp1(:,2);
          ostruct(3).rdl = rdl1(:,2);

          % Data for tf22
          ostruct(4).res = res2(:,2);
          ostruct(4).poles = poles2;
          ostruct(4).dterm = dterm2(:,2);
          ostruct(4).mresp = mresp2(:,2);
          ostruct(4).rdl = rdl2(:,2);

          % Output data
          utils.helper.msg(utils.const.msg.PROC1, ' Output continuous models ')
          if nargout == 1
            varargout{1} = ostruct;
          else
            error(' Unespected number of output. Set 1! ')
          end

        case 1
          utils.helper.msg(utils.const.msg.PROC1, ' Performing z-domain identification on 2dim system, z-domain output ')
          [tf11,tf12,tf21,tf22] = utils.math.eigcsd(csd11,csd12,csd21,csd22,'USESYM',eigsym,'DIG',dig,'OTP','TF'); % input data

          % Shifting to columns
          [a,b] = size(tf11);
          if a<b
            tf11 = tf11.';
          end
          [a,b] = size(tf12);
          if a<b
            tf12 = tf12.';
          end
          [a,b] = size(tf21);
          if a<b
            tf21 = tf21.';
          end
          [a,b] = size(tf22);
          if a<b
            tf22 = tf22.';
          end

          % Collecting tfs
          f1 = [tf11 tf21];
          f2 = [tf12 tf22];
          
          % get external weights
          if ~isempty(extweights)
            % willing to work with columns
            [a,b] = size(extweights);
            if a<b
              extweights = extweights.';
            end
            wobj1 = [extweights(:,1).*abs(csd11./tf11) extweights(:,3).*abs(csd21./tf21)];
            wobj2 = [extweights(:,2).*abs(csd12./tf12) extweights(:,4).*abs(csd22./tf22)];
          else
            wobj1 = [];
            wobj2 = [];
          end

          % Fitting with unstable poles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
          'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
          'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
          'stabfit',0,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',wobj1);

          % Fitting
          utils.helper.msg(utils.const.msg.PROC1, ' Fitting TF11 and TF21 with unstable common poles ')
          [res1,poles1,dterm1,mresp1,rdl1,mse1] = utils.math.autodfit(f1,f,fs,params);
          
          params = struct('spolesopt',spolesopt, 'Nmaxiter',Nmaxiter, 'minorder',minorder,...
          'maxorder',maxorder, 'weightparam',weightparam, 'plot',checking,...
          'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
          'stabfit',0,'dterm',idt,'spy',spy,'fullauto',autosearch,'extweights',wobj2);

          utils.helper.msg(utils.const.msg.PROC1, ' Fitting TF12 and TF22 with unstable common poles ')
          [res2,poles2,dterm2,mresp2,rdl2,mse2] = utils.math.autodfit(f2,f,fs,params);

          % Poles stabilization
          if allsym
            utils.helper.msg(utils.const.msg.PROC1, ' All pass filtering of TF11 and TF21, symbolic calc... ')
            [nr1,np1,nd1,nf1] = utils.math.pfallpsymz(res1,poles1,dterm1,mresp1,f,fs);
            np1 = np1(:,1);
            utils.helper.msg(utils.const.msg.PROC1, ' All pass filtering of TF12 and TF22, symbolic calc... ')
            [nr2,np2,nd2,nf2] = utils.math.pfallpsymz(res2,poles2,dterm2,mresp2,f,fs);
            np2 = np2(:,1);
          else
            utils.helper.msg(utils.const.msg.PROC1, ' All pass filtering of TF11 and TF21 ')
            [nf1,np1] = utils.math.pfallpz(res1,poles1,dterm1,mresp1,f,fs,false);
            np1 = np1(:,1);
            utils.helper.msg(utils.const.msg.PROC1, ' All pass filtering of TF12 and TF22 ')
            [nf2,np2] = utils.math.pfallpz(res2,poles2,dterm2,mresp2,f,fs,false);
            np2 = np2(:,1);
          end
          
          % Fitting with stable poles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          % Fitting stable TF11 and TF21 with stable poles in z-domain
          % Fitting params
          params = struct('spolesopt',0,'Nmaxiter',Nmaxiter,...
          'minorder',minorder,'maxorder',maxorder,...
          'weightparam',weightparam,'plot',checking,...
          'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
          'stabfit',1,...
          'dterm',idt,'spy',spy,'fullauto',autosearch,...
          'extweights',wobj1,'extpoles', np1);

          % Fitting
          utils.helper.msg(utils.const.msg.PROC1, ' Fitting TF11 and TF21 with stable common poles ')
          [res1,poles1,dterm1,mresp1,rdl1,mse1] = utils.math.autodfit(nf1,f,fs,params);
          
          % Fitting stable TF12 and TF22 with stable poles in z-domain
          % Fitting params
          params = struct('spolesopt',0,'Nmaxiter',Nmaxiter,...
          'minorder',minorder,'maxorder',maxorder,...
          'weightparam',weightparam,'plot',checking,...
          'ctp',ctp,'lrscond',lrscond,'msevar',msevar,...
          'stabfit',1,...
          'dterm',idt,'spy',spy,'fullauto',autosearch,...
          'extweights',wobj2,'extpoles', np2);
          
          % Fitting
          utils.helper.msg(utils.const.msg.PROC1, ' Fitting TF12 and TF22 with stable common poles ')
          [res2,poles2,dterm2,mresp2,rdl2,mse2] = utils.math.autodfit(nf2,f,fs,params);

          % Output stable model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          ostruct = struct();

          % Data for tf11
          ostruct(1).res = res1(:,1);
          ostruct(1).poles = poles1;
          ostruct(1).dterm = dterm1(:,1);
          ostruct(1).mresp = mresp1(:,1);
          ostruct(1).rdl = rdl1(:,1);

          % Data for tf12
          ostruct(2).res = res2(:,1);
          ostruct(2).poles = poles2;
          ostruct(2).dterm = dterm2(:,1);
          ostruct(2).mresp = mresp2(:,1);
          ostruct(2).rdl = rdl2(:,1);

          % Data for tf21
          ostruct(3).res = res1(:,2);
          ostruct(3).poles = poles1;
          ostruct(3).dterm = dterm1(:,2);
          ostruct(3).mresp = mresp1(:,2);
          ostruct(3).rdl = rdl1(:,2);

          % Data for tf22
          ostruct(4).res = res2(:,2);
          ostruct(4).poles = poles2;
          ostruct(4).dterm = dterm2(:,2);
          ostruct(4).mresp = mresp2(:,2);
          ostruct(4).rdl = rdl2(:,2);

          % Output data
          utils.helper.msg(utils.const.msg.PROC1, ' Output discrete models ')
          if nargout == 1
            varargout{1} = ostruct;
          else
            error(' Unespected number of output. Set 1! ')
          end

      end
  end

  % END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
