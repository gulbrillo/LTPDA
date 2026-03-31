% MCHNOISEGENFILTER Construct a matrix filter from cross-spectral density matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    mchNoisegenFilter
%
% DESCRIPTION: Construct matrix filter from cross-spectral density. Such a
% filter can be used for multichannel noise generation in combination with
% the mchNoisegen method of the matrix class.
%
%
% CALL:        fil = mchNoisegenFilter(mod, pl)
%
% INPUT:
%         mod: is a matrix object containing the model for the target
%         cross-spectral density matrix. Elements of mod must be fsdata
%         analysis objects.
%
% OUTPUT:
%         fil: is a matrix object containing the noise generating filter.
%         Such a filter can be used to generate colored noise from
%         uncorrelated unitary variance white time series. Fil can be a
%         matrix of filterbanks objects or of parfrac objects according to
%         the chosen output options.
%
% NOTE:
%
%         The cross-spectral matrix is assumed to be frequency by frequency
%         of the type:
%
%                         / csd11(f)  csd12(f) \
%               CSD(f) =  |                    |
%                         \ csd21(f)  csd22(f) /
%
%
%
% HISTORY:     22-04-2009 L Ferraioli
%              Creation
%
% ------------------------------------------------------------------------
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'mchNoisegenFilter')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = mchNoisegenFilter(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all ltpdauoh objects
  [mtxs, mtxs_invars] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  [pl, invars] = utils.helper.collect_objects(varargin(:), 'plist');
  
  inhists = mtxs.hist;
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  pl.getSetRandState();
  
  % get elements out of the input matrix
  if numel(mtxs)>1 % the method work only with one matrix at the input
    error('### Please provide one matrix at the input.');
  end
  csdm = copy(mtxs,nargout);
  csdao = csdm.objs;
  
  % Get parameters and set params for fit
  fs     = find_core(pl, 'fs');
  
  target = lower(find_core(pl, 'targetobj')); % decide to perform s domain or z domain identification
  % if target is parfrac output a matrix of parfarc objs (s domain
  % identification)
  % if target is miir output a matrix of filterbank parallel miir objects
  % (z domain identification)
  
  usesym = lower(find_core(pl, 'UseSym'));
  
  if  (fs == 0) && strcmpi(target,'miir')
    error('### Please provide a valid sampling frequency for CSD constructor.');
  elseif isempty(fs) && strcmpi(target,'miir')
    error('### Please provide a valid sampling frequency for CSD constructor.');
  end
  
  % get units for filters
  tgiunit = find_core(pl,'iunits');
  tgounit = find_core(pl,'ounits');
  
  % require filter initialization
  initfilter = utils.prog.yes2true(find_core(pl, 'InitFilter'));
  
  params = struct();
  
  params.Nmaxiter = find_core(pl, 'MaxIter');
  params.minorder = find_core(pl, 'MinOrder');
  params.maxorder = find_core(pl, 'MaxOrder');
  params.spolesopt = find_core(pl, 'PoleType');
  params.weightparam = find_core(pl, 'Weights');
  
  % set the target output
  if strcmpi(target,'miir')
    params.TargetDomain = 'z';
  elseif strcmpi(target,'parfrac')
    params.TargetDomain = 's';
  else
    error('### Unknown option for ''targetobj''.');
  end
  
  % Tolerance for MSE Value
  lrscond = find_core(pl, 'FITTOL');
  % give an error for strange values of lrscond
  if lrscond<0
    error('### Negative values for FITTOL are not allowed. ')
  end
  % handling data
  lrscond = -1*log10(lrscond);
  % give a warning for strange values of lrscond
  if lrscond<0
    warning('You are searching for a MSE lower than %s', num2str(10^(-1*lrscond)))
  end
  params.lrscond = lrscond;
  
  % Tolerance for the MSE relative variation
  msevar = find_core(pl, 'MSEVARTOL');
  % handling data
  msevar = -1*log10(msevar);
  % give a warning for strange values of msevar
  if msevar<0
    warning('You are searching for MSE relative variation lower than %s', num2str(10^(-1*msevar)))
  end
  params.msevar = msevar;
  
  if isempty(params.msevar)
    params.ctp = 'chival';
  else
    params.ctp = 'chivar';
  end
  
  if(find_core(pl, 'plot'))
    params.plot = 1;
  else
    params.plot = 0;
  end
  
  params.fs = fs;
  params.dterm = 0; % it is better to fit without direct term
  
  % check if symbolic calculation is required
  if strcmpi(usesym,'on')
    params.usesym = 1;
  elseif strcmpi(usesym,'off')
    params.usesym = 0;
  else
    error('### Unknown option for ''UseSym''.');
  end
  
  % extracting csd
  if numel(csdao)==1 % one dimensional psd
    csd = csdao.y;
    freq = csdao.x;
    dim = 'one';
  else % multichannel system
    dim = 'multi';
    [nn,mm] = size(csdao);
    if nn~=mm
      error('### CSD Matrix must be square. ')
    end
    freq = csdao(1).x;
    for ii = 1:nn
      for jj = 1:nn
        tcsd = csdao(ii,jj).y;
        % willing to work with columns
        [aa,bb] = size(tcsd);
        if aa<bb
          tcsd = tcsd.';
        end
        csd(ii,jj,:) = tcsd;
      end
    end
    
  end
  
  
  % call csd2tf
  % ostruct is a struct array whose fields contain the residues and poles
  % of estimated TFs. Since the fit is porformed on the columns of the TF
  % matrix, each element of the array contains the residues and poles
  % corresponding to the functions on the given column of the TF matrix.
  
  %ostruct = utils.math.csd2tf(csd,freq,params);
  
  ostruct = utils.math.csd2tf2(csd,freq,params);
  
  
  % the filter for each channel is implemented by the rows of the TF matrix
  
  switch dim
    case 'one'
      
      switch target
        case 'miir'
          % --- filter ---
          res = ostruct.res;
          poles = ostruct.poles;
          % check if filter init is required
          if initfilter
            Zi = utils.math.getinitstate(res,poles,1,'mtd','svd');
          else
            Zi = zeros(size(res));
          end
          
          % construct a struct array of miir filters vectors
          pfilts(numel(res),1) = miir;
          for kk=1:numel(res)
            ft = miir(res(kk), [ 1 -poles(kk)], fs);
            ft.setIunits(unit(tgiunit));
            ft.setOunits(unit(tgounit));
            ft.setHistout(Zi(kk));
            pfilts(kk,1) = ft;
            clear ft
          end
          filt = filterbank(pfilts,'parallel');
          
          csdm = matrix(filt);
          
          % Add history
          csdm.addHistory(getInfo('None'), pl, [mtxs_invars(:)], [inhists(:)]);
          
        case 'parfrac'
          res = ostruct.res;
          poles = ostruct.poles;
          
          fbk = parfrac(res,poles,0);
          fbk.setIunits(unit(tgiunit));
          fbk.setOunits(unit(tgounit));
          
          csdm = matrix(fbk);
          
          % Add history
          csdm.addHistory(getInfo('None'), pl, [mtxs_invars(:)], [inhists(:)]);
      end
      
      
    case 'multi'
      
      switch target
        case 'miir'
          % init filters array
          %fbk(nn*nn,1) = filterbank;
          %fbk = filterbank.newarray([nn nn]);
          
          for zz=1:nn*nn % run over system dimension
            % --- get column filter coefficients ---
            % each column of mres\mpoles are the coefficients of a given filter
            clear res poles
            res = ostruct(zz).res;
            poles = ostruct(zz).poles;
            
            % construct a struct array of miir filters vectors
            %ft(numel(res),1) = miir;
            for kk=1:numel(res)
              ft(kk,1) = miir(res(kk), [1 -poles(kk)], fs);
              ft(kk,1).setIunits(unit(tgiunit));
              ft(kk,1).setOunits(unit(tgounit));
            end
            
            fbk(zz,1) = filterbank(ft,'parallel');
            clear ft
            
          end
          
          mfbk = reshape(fbk,nn,nn);
          
          % check if filter init is required
          if initfilter
            ckidx = 0;
            while ckidx<nn*nn
              resv = [];
              plsv = [];
              for ii=1+ckidx:nn+ckidx
                resv = [resv; ostruct(ii).res];
                plsv = [plsv; ostruct(ii).poles];
              end
              % get init states
              Zi = utils.math.getinitstate(resv,plsv,1,'mtd','svd');
              clear resv plsv
              % unpdate into the filters
              for ii=1+ckidx:nn+ckidx
                for kk=1:numel(mfbk)
                  mfbk(ii).filters(kk).setHistout(Zi(kk));
                end
              end
              % update ckidx
              ckidx = ckidx + nn;
            end
          end
          
          csdm = matrix(mfbk);
          
          
          % Add history
          csdm.addHistory(getInfo('None'), pl, [mtxs_invars(:)], [inhists(:)]);
          
        case 'parfrac'
          % init filters array
          %fbk(nn*nn,1) = parfrac;
          
          for zz=1:nn*nn % run over system dimension
            % --- get column filter coefficients ---
            % each column of mres\mpoles are the coefficients of a given filter
            clear res poles
            res = ostruct(zz).res;
            poles = ostruct(zz).poles;
            
            fbk(zz,1) = parfrac(res,poles,0);
            fbk(zz,1).setIunits(unit(tgiunit));
            fbk(zz,1).setOunits(unit(tgounit));
            
          end
          
          mfbk = reshape(fbk,nn,nn);
          
          csdm = matrix(mfbk);
          
          % Add history
          csdm.addHistory(getInfo('None'), pl, [mtxs_invars(:)], [inhists(:)]);
      end
      
  end
  
  % Set properties from the default plist
  csdm.setObjectProperties(pl);
  
  % output data
  varargout{1} = csdm;
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setArgsmin(1);
  ii.setOutmin(1);
  ii.setOutmax(1);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  pl = plist();
  
  % Target Objects
  p = param({'targetobj', ['Choose the type of output objects:<ul>',...
    '<li>''miir'' output a matrix containing filterbanks of parallel miir filters</li>',...
    '<li>''parfrac'' output a matrix containing parafracs objects</li>']}, ...
    {1, {'miir','parfrac'}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Fs
  p = param({'fs', 'The sampling frequency of the discrete filters.'}, {1, {1}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Iunits
  p = param({'iunits', 'The unit to set as input unit for the output filters'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % Ounits
  p = param({'ounits', 'The unit to set as output unit for the output filters'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % Plot
  p = param({'InitFilter', 'Initialize filters (works only for miir objects) to cope with startup transients.'}, paramValue.TRUE_FALSE);
  p.val.setValIndex(1);
  pl.append(p);
  
  % Max Iter
  p = param({'MaxIter', 'Maximum number of fit iterations.'}, {1, {50}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Pole type
  p = param({'PoleType',['Choose the pole type for fitting initialization:<ul>',...
    '<li>1 == use real starting poles</li>',...
    '<li>2 == generates complex conjugate poles of the type <tt>a.*exp(theta*pi*j)</tt> with <tt>theta = linspace(0,pi,N/2+1)</tt></li>',...
    '<li>3 == generates complex conjugate poles of the type <tt>a.*exp(theta*pi*j)</tt> with <tt>theta = linspace(0,pi,N/2+2)</tt></li></ul>']}, ...
    {1, {1, 2, 3}, paramValue.SINGLE});
  pl.append(p);
  
  % Min order
  p = param({'MinOrder','Minimum order to fit with.'}, {1, {7}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Max Order
  p = param({'MaxOrder','Maximum order to fit with.'}, {1, {35}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Weights
  p = param({'Weights',['Choose weighting for the fit:<ul>',...
    '<li> 1 == equal weights for each point</li>',...
    '<li> 2 == weight with <tt>1/abs(model)</tt></li>',...
    '<li> 3 == weight with <tt>1/abs(model).^2</tt></li>',...
    '<li> 4 == weight with inverse of the square mean spread of the model</li></ul>']}, {3, {1 2 3 4}, paramValue.SINGLE});
  pl.append(p);
  
  % Plot
  p = param({'Plot', 'Plot results of each fitting step.'}, paramValue.TRUE_FALSE);
  p.val.setValIndex(2);
  pl.append(p);
  
  % MSE Vartol
  p = param({'MSEVARTOL', ['Mean Squared Error Variation - Check if the realtive variation of the mean squared error is<br>',...
    'smaller than the value specified. This option is useful for finding the minimum of Chi squared.']}, ...
    {1, {1e-1}, paramValue.OPTIONAL});
  pl.append(p);
  
  % FIT TOL
  p = param({'FITTOL',['Mean Squared Error Value - Check if the mean squared error value <br>',...
    ' is lower than the value specified.']},  {1, {1e-2}, paramValue.OPTIONAL});
  pl.append(p);
  
  % UseSym
  p = param({'UseSym', ['Use symbolic calculation in eigen-decomposition.<ul>'...
    '<li>''on'' - uses symbolic math toolbox calculation<br>'...
    'for poles stabilization</li>'...
    '<li>''off'' - perform double-precision calculation<br>'...
    'for poles stabilization</li>']}, {1, {'on','off'}, paramValue.SINGLE});
  pl.append(p);
  
  % RAND_STREAM
  pl.append(copy(plist.RAND_STREAM, 1));
  
end


