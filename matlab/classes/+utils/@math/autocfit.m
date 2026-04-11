% AUTOCFIT performs a fitting loop to identify model order and parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
%
%     Perform a fitting loop to automatically identify model order and
%     parameters in s-domain. Model identification is performed by 'vcfit'
%     function. Output is a s-domain model expanded in partial fractions:
%
%              r1              rN
%     f(s) = ------- + ... + ------- + d
%            s - p1          s - pN
%
%     The function attempt to perform first the identification of a model
%     with d = 0, then if the operation do not succeed, it try the
%     identification with d different from zero.
%     Identification loop stop when the stop condition is reached. Six
%     stop criteria are available:
% 
%     Mean Squared Error
%     Check if the normalized mean squared error is lower than the value
%     specified in lrscond:
%     mse < 10^(-1*lrsvarcond)
%
%     Mean Squared Error and variation
%     Check if the normalized mean squared error is lower than the value specified in
%     lrscond and that the relative variation of the mean squared error is lower
%     than the value provided.
%     Checking algorithm is:
%     mse < 10^(-1*lrsvarcond)
%     Dmse < 10^(-1*msevar)
%
%     Log Residuals difference
%     Check if the minimum of the logarithmic difference between data and
%     residuals is larger than a specified value. ie. if the conditioning
%     value is 2, the function ensures that the difference between data and
%     residuals is at lest 2 order of magnitude lower than data itsleves.
%     Checking algorithm is:
%     lsr = log10(abs(y))-log10(abs(rdl));
%     min(lsr) > lrscond;
%
%     Log Residuals difference and Root Mean Squared Error
%     Check if the log difference between data and residuals is in
%     larger than the value indicated in lsrcond and that the variation of
%     the root mean squared error is lower than 10^(-1*msevar).
%     Checking algorithm is:
%     lsr = log10(abs(y))-log10(abs(rdl));
%     (lsr > lrscond) && (mse < 10^(-1*lrsvarcond));
% 
%     Residuals Spectral Flatness
%     In case of a fit on noisy data, the residuals from a good fit are
%     expected to be as much as possible similar to a white noise. This
%     property can be used to test the accuracy of a fit procedure. In
%     particular it can be tested that the spectral flatness coefficient of
%     the residuals is larger than a certain qiantity sf such that 0<sf<1.
% 
%     Residuals Spectral Flatness and root mean squared error
%     Check that the spectral flatness coefficient of the residuals is
%     larger than a certain qiantity sf such that 0<sf<1 and that the
%     variation of the root mean squared error is lower than
%     10^(-1*msevar).
% 
%     Once the loop iteration stops the parameters giving best Mean Square
%     Error are output.
% 
% CALL:
%
%     [res,poles,dterm,mresp,rdl,mse] = autocfit(y,f,params)
%
% INPUT:
%
%     - y are the data to be fitted. They represent the frequency response
%     of a certain process.
%     - f is the frequency vector in Hz
%     - params is a struct containing identification parameters
%
%       params.spolesopt = 0 --> use external starting poles
%       params.spolesopt = 1 --> use real starting poles
%       params.spolesopt = 2 --> use logspaced complex starting poles.
%       Default option
%       params.spolesopt = 3 --> use linspaced complex starting poles.
% 
%       params.extpoles = [] --> a vector with the starting poles.
%       Providing a fixed set of starting poles fixes the function order so
%       params.minorder and params.maxorder will be internally set to the
%       poles vector length.
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
%       params.Nmaxiter = # --> Number of maximum iteration per model order
%       parformed. Default is 50.
%
%       params.minorder = # --> Minimum model trial order. Default is 2.
%
%       params.maxorder = # --> Maximum model trial order. Default is 25.
%
%       params.weightparam = 0 --> use external weights
%       params.weightparam = 1 --> fit with equal weights (one) for each
%       data point.
%       params.weightparam = 2 --> weight fit with the inverse of absolute
%       value of data. Default value.
%       params.weightparam = 3 --> weight fit with the square root of the
%       inverse of absolute value of data.
%       params.weightparam = 4 --> weight fit with inverse of the square
%       mean spread
% 
%       params.extweights = [] --> A vector of externally provided weights.
%       It has to be of the same size of input data.
%
%       params.plot = 0 --> no plot during fit iteration
%       params.plot = 1 --> plot results at each fitting steps. default
%       value.
%
%       params.ctp = 'lrs' --> check if the log difference between data and
%       residuals is point by point larger than the value indicated in
%       lsrcond. This mean that residuals are lsrcond order of magnitudes
%       lower than data.
%       params.ctp = 'lrsmse' --> check if the log difference between data
%       and residuals is larger than the value indicated in lsrcond and if
%       the variation of root mean squared error is lower than
%       10^(-1*msevar).
%       params.ctp = 'rft' --> check that the residuals spectral flatness
%       coefficient is lerger than the value provided in lsrcond. In this
%       case lsrcond must be such that 0<lsrcond<1.
%       params.ctp = 'rftmse' --> check that the residuals spectral flatness
%       coefficient is lerger than the value provided in lsrcond and if
%       the variation of root mean squared error is lower than
%       10^(-1*msevar). In this case lsrcond must be such that
%       0<lsrcond<1.
%
%       params.lrscond = # --> set conditioning value for point to point
%       log residuals difference (params.ctp = 'lsr' and params.ctp =
%       'lrsmse') or set conditioning value for residuals spectral
%       flateness (params.ctp = 'rft' and params.ctp = 'rftmse'). In the
%       last case params.lrscond must be set to 0<lrscond<1.
%       Default is 2. See help for stopfit.m for further remarks.
%
%       params.msevar = # --> set conditioning value for root mean squared
%       error variation. This allow to check that the variation of root
%       mean squared error is lower than 10^(-1*msevar).Default is 7. See
%       help for stopfit.m for further remarks.
%
%       params.stabfit = 0 --> Fit without forcing poles stability. Default
%       value.
%       params.stabfit = 1 --> Fit forcing poles stability
%
%       params.dterm = 0 --> Try to fit without direct term
%       params.dterm = 1 --> Try to fit with and without direct term
%
%       params.spy = 0 --> Do not display the iteration progression
%       params.spy = 1 --> Display the iteration progression
%
% OUTPUT:
%
%     - res is the vector with model residues r
%     - poles is the vector with model poles p
%     - dterm is the model direct term d
%     - mresp is the model frequency response calculated at the input
%     frequencies
%     - rdl are the residuals between data and model, at the input
%     frequencies
%     - mse magnitude squared error progression
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [res,poles,dterm,mresp,rdl,mse] = autocfit(y,f,params)

  utils.helper.msg(utils.const.msg.MNAME, 'running %s/%s', mfilename('class'), mfilename);

  % Default input struct
  defaultparams = struct('spolesopt',1, 'Nmaxiter',30, 'minorder',2,...
    'maxorder',25, 'weightparam',1, 'plot',1,...
    'ctp','chival','lrscond',2,'msevar',2,...
    'stabfit',0,'dterm',0,'spy',0,'fullauto',1,'extweights', [],...
    'extpoles', []);

  names = {'spolesopt','Nmaxiter','minorder',...
    'maxorder','weightparam','plot',...
    'ctp','lrscond','msevar',...
    'stabfit','dterm','spy','fullauto','extweights','extpoles'};

  % collecting input and default params
  if ~isempty(params)
    for jj=1:length(names)
      if isfield(params, names(jj)) && ~isempty(params.(names{1,jj}))
        defaultparams.(names{1,jj}) = params.(names{1,jj});
      end
    end
  end

  % collecting input params
  spolesopt = defaultparams.spolesopt;
  Nmaxiter = defaultparams.Nmaxiter;
  minorder = defaultparams.minorder;
  maxorder = defaultparams.maxorder;
  weightparam = defaultparams.weightparam;
  check = defaultparams.plot;
  stabfit = defaultparams.stabfit;
  ctp = defaultparams.ctp;
  lrscond = defaultparams.lrscond;
  msevar = defaultparams.msevar;
  idt = defaultparams.dterm;
  spy = defaultparams.spy;
  autosearch = defaultparams.fullauto;
  extweights = defaultparams.extweights;
  extpoles = defaultparams.extpoles;

  if check == 1
    fitin.plot = 1;
    fitin.ploth = figure; % opening new figure window
  else
    fitin.plot = 0;
  end

  if stabfit % fit with stable poles only
    fitin.stable = 1;
  else % fit without restrictions
    fitin.stable = 0;
  end

  % Colum vector are preferred
  [a,b] = size(y);
  if a < b % shifting to column
    y = y.';
  end
  [Nx,Ny] = size(y);

  [a,b] = size(f);
  if a < b % shifting to column
    f = f.';
  end
  
  % in case of externally provided poles
  if ~isempty(extpoles)
    spolesopt = 0;
  end
  if spolesopt == 0 % in case of external poles
    % Colum vector are preferred
    [a,b] = size(extpoles);
    if a < b % shifting to column
      extpoles = extpoles.';
    end
    [Npls,b] = size(extpoles);
    minorder = Npls;
    maxorder = Npls;
  end
  
  if weightparam == 0 % in case of external weights
    % Colum vector are preferred
    [a,b] = size(extweights);
    if a < b % shifting to column
      extweights = extweights.';
    end
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Importing package
  import utils.math.*

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Fitting

  % decide to fit with or without direct term according to the input
  % options
  if autosearch
    if idt % full auto identification
      dterm_off = 1;
      dterm_on = 1;
    else % auto ident without dterm
      dterm_off = 1;
      dterm_on = 0;
    end
  else
    if idt % fit only with dterm
      dterm_off = 0;
      dterm_on = 1;
    else % fit without dterm
      dterm_off = 1;
      dterm_on = 0;
    end
  end

  ext = zeros(Ny,1);
  
  % starting banana mse
  bmse = inf;
  cmse = inf;

  if dterm_off
    utils.helper.msg(utils.const.msg.PROC1, ' Try fitting without direct term ')
    fitin.dterm = 0;

    % Weighting coefficients
    if weightparam == 0
      % using external weigths
      utils.helper.msg(utils.const.msg.PROC1, ' Using external weights... ')
      weight = extweights;
      fitin.weightmse = true;
    else
      weight = utils.math.wfun(y,weightparam);
      fitin.weightmse = false;
    end
    
    % Do not perform the loop if autosearch is setted to false
    if autosearch
      order_vect = minorder:maxorder;
    else
      order_vect = minorder:minorder;
    end

    for N = order_vect

      if spy
        utils.helper.msg(utils.const.msg.PROC1, ['Actual_Order' num2str(N)])
      end

      % Starting poles
      if spolesopt == 0 % in case of external poles
        utils.helper.msg(utils.const.msg.PROC1, ' Using external poles... ')
        spoles = extpoles;
      else % internally calculated starting poles
        pparams = struct('spolesopt',spolesopt, 'type','CONT', 'pamp', 0.01);
        spoles = utils.math.startpoles(N,f,pparams);
      end

      % Fitting
      M = 2*N;
      if M > Nmaxiter
        M = Nmaxiter;
      elseif not(autosearch)
        M = Nmaxiter;
      end
      
      clear mlr

      for hh = 1:M
        [res,spoles,dterm,mresp,rdl,mse] = utils.math.vcfit(y,f,spoles,weight,fitin); % Fitting
        
        % decide to store the best result based on mse
        %fprintf('iteration = %d, order = %d \n',hh,N)
        if norm(mse)<cmse
          %fprintf('nice job \n')
          bres = res;
          bpoles = spoles;
          bdterm = dterm;
          bmresp = mresp;
          brdl = rdl;
          bmse = mse;
          cmse = norm(mse);
        end
        
        if spy
          utils.helper.msg(utils.const.msg.PROC1, ['Iter' num2str(hh)])
        end

        %        ext = zeros(Ny,1);
        if autosearch
          for kk = 1:Ny
            % Stop condition checking
            mlr(hh,kk) = mse(:,kk);
            % decide between stop conditioning
            if strcmpi(ctp,'lrs')
              yd = y(:,kk); % input data
            elseif strcmpi(ctp,'lrsmse')
              yd = y(:,kk); % input data
            elseif strcmpi(ctp,'rft')
              yd = mresp(:,kk); % model response
            elseif strcmpi(ctp,'rftmse')
              yd = mresp(:,kk); % model response
            elseif strcmpi(ctp,'chival')
              yd = y(:,kk); % model response
            elseif strcmpi(ctp,'chivar')
              yd = y(:,kk); % model response
            else
              error('!!! Unable to identify appropiate stop condition. See function help for admitted values');
            end
            [next,msg] = utils.math.stopfit(yd,rdl(:,kk),mlr(:,kk),ctp,lrscond,msevar);
            ext(kk,1) = next;
          end
        else
          for kk = 1:Ny
            % storing mse progression
            mlr(hh,kk) = mse(:,kk);
          end
        end

        if all(ext)
          utils.helper.msg(utils.const.msg.PROC1, msg)
          break
        end

      end
      if all(ext)
        break
      end

    end
  end

  if dterm_on
    if ~all(ext) % fit with direct term only if the fit without does not give acceptable results (in full auto mode)
      utils.helper.msg(utils.const.msg.PROC1, ' Try fitting with direct term ')
      fitin.dterm = 1;

      if autosearch
        order_vect = minorder:maxorder;
      else
        order_vect = minorder:minorder;
      end

      for N = order_vect

        if spy
          utils.helper.msg(utils.const.msg.PROC1, ['Actual_Order' num2str(N)])
        end

        % Starting poles
        if spolesopt == 0 % in case of external poles
          utils.helper.msg(utils.const.msg.PROC1, ' Using external poles... ')
          spoles = extpoles;
        else % internally calculated starting poles
          pparams = struct('spolesopt',spolesopt, 'type','CONT', 'pamp', 0.01);
          spoles = utils.math.startpoles(N,f,pparams);
        end

        % Fitting
        M = 2*N;
        if M > Nmaxiter
          M = Nmaxiter;
        elseif not(autosearch)
          M = Nmaxiter;
        end
        
        clear mlr
        
        for hh = 1:M
          [res,spoles,dterm,mresp,rdl,mse] = utils.math.vcfit(y,f,spoles,weight,fitin); % Fitting
          
          % decide to store the best result based on mse
          if norm(mse)<cmse
            bres = res;
            bpoles = spoles;
            bdterm = dterm;
            bmresp = mresp;
            brdl = rdl;
            bmse = mse;
            cmse = norm(mse);
          end
          
          if spy
            utils.helper.msg(utils.const.msg.PROC1, ['Iter' num2str(hh)])
          end

          ext = zeros(Ny,1);
          if autosearch
            for kk = 1:Ny
              % Stop condition checking
              mlr(hh,kk) = mse(:,kk);
              % decide between stop conditioning
              if strcmpi(ctp,'lrs')
                yd = y(:,kk); % input data
              elseif strcmpi(ctp,'lrsmse')
                yd = y(:,kk); % input data
              elseif strcmpi(ctp,'rft')
                yd = mresp(:,kk); % model response
              elseif strcmpi(ctp,'rftmse')
                yd = mresp(:,kk); % model response
              elseif strcmpi(ctp,'chival')
                yd = y(:,kk); % model response
              elseif strcmpi(ctp,'chivar')
                yd = y(:,kk); % model response
              else
                error('!!! Unable to identify appropiate stop condition. See function help for admitted values');
              end
              [next,msg] = utils.math.stopfit(yd,rdl(:,kk),mlr(:,kk),ctp,lrscond,msevar);
              ext(kk,1) = next;
            end
          else
            for kk = 1:Ny
              % storing mse progression
              mlr(hh,kk) = mse(:,kk);
            end
          end

          if all(ext)
            utils.helper.msg(utils.const.msg.PROC1, msg)
            break
          end

        end
        if all(ext)
          break
        end

      end

    end
  end

  poles = bpoles;
  clear mse
  mse = mlr(:,:);
  
  res = bres;
  dterm = bdterm;
  mresp = bmresp;
  rdl = brdl;
  mse = bmse;

  if all(ext) == 0
    utils.helper.msg(utils.const.msg.PROC1, ' Fitting iteration completed without reaching the prescribed accuracy. Try changing Nmaxiter or maxorder or accuracy requirements ')
  else
    utils.helper.msg(utils.const.msg.PROC1, ' Fitting iteration completed successfully ')
  end
