% AUTOCFIT performs a fitting loop to identify model order and parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
%
%     Perform a fitting loop to automatically identify model order and
%     parameters in s-domain. Model identification is performed by 'vcfit'
%     function. Output is a s-domain model expanded in partial fractions:
%
%              r1              rN
%     f(s) = ------- + ... + -------
%            s - p1          s - pN
%
%     Identification loop stop when the fit tolerance condition is
%     satisfied. Fit tolerance thershold is set in the parameter
%     (maxspread). It checks the maximum spread between the whitened
%     spectrum (data/model) with respect to its expected value 1.
%
% CALL:
%
%     [res,poles,dterm,psdmod] = psdvectorfit(y,f,params)
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
%       params.maxspread = # --> Define the fit tolerance condition. It
%       checks the maximum spread of the whitened spectrum with respect to
%       its expected value (1). Default value is 2.
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
%       params.stabfit = 0 --> Fit without forcing poles stability. Default
%       value.
%       params.stabfit = 1 --> Fit forcing poles stability
%
%       params.spy = 0 --> Do not display the iteration progression
%       params.spy = 1 --> Display the iteration progression
%
% OUTPUT:
%
%     - res is the vector with model residues r
%     - poles is the vector with model poles p
%     - dterm is the model direct term d (always 0)
%     - psdmod is the model frequency response calculated at the input
%     frequencies
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [res,poles,dterm,psdmod] = psdvectorfit(y,f,params)

  utils.helper.msg(utils.const.msg.MNAME, 'running %s/%s', mfilename('class'), mfilename);

  % Default input struct
  defaultparams = struct(...
    'Nmaxiter',30, ... % maximum number of iterations
    'minorder',2,... % starting minimum order
    'maxorder',25, ... % starting maximum order
    'plot',1,... % decide to look at the plot while fitting
    'maxspread',2,... % set goodness of fit condition
    'spolesopt',2, ... % you do not necessarily need to modify the parameters below
    'weightparam',2, ...
    'stabfit',0,...
    'dterm',0,...
    'spy',0,...
    'fullauto',1,...
    'extweights', [],...
    'extpoles', []);

  names = {...
    'spolesopt',...
    'Nmaxiter',...
    'minorder',...
    'maxorder',...
    'weightparam',...
    'plot',...
    'maxspread',...
    'stabfit',...
    'dterm',...
    'spy',...
    'fullauto',...
    'extweights',...
    'extpoles'};

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
  maxspread = defaultparams.maxspread;
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

  % the method accepts only one input
  if Ny>1
    error('You can fit only one PSD per time!')
  end

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

  ext = 0;


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



      bres = res;
      bpoles = spoles;
      bdterm = dterm;
      bmresp = abs(mresp);


      if spy
        utils.helper.msg(utils.const.msg.PROC1, ['Iter' num2str(hh)])
      end

      if autosearch
        % test that the spread of the whitened noise is below the given
        % value
        noisemaxspread = max(abs((y./bmresp) - 1));
        if noisemaxspread <= maxspread
          ext = 1;
          msg = 'Maximum whitened noise spread is below the required threshold!';
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




  poles = bpoles;
  res = bres;
  dterm = bdterm;
  psdmod = bmresp;


  if all(ext) == 0
    utils.helper.msg(utils.const.msg.PROC1, ' Fitting iteration completed without reaching the prescribed accuracy. Try changing Nmaxiter or maxorder or accuracy requirements ')
  else
    utils.helper.msg(utils.const.msg.PROC1, ' Fitting iteration completed successfully ')
  end
  
end
