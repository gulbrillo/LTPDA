% LINFITSVD Linear fit with singular value decomposition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Linear least square problem with singular value
% decomposition
%
% ALGORITHM: Perform linear identification of the parameters of a
% multichannel systems. The results of different experiments on the same
% system can be passed as input. The algorithm, thanks to the singular
% value decomposition, extract the maximum amount of information from each
% single channel and for each experiment. Total information is then
% combined to get the final result.
%            
% CALL:                   pars = linfitsvd(os1,...,osn,pl);
% 
% INPUT:
%               - osi are vector of system output signals. They must be
%               Nx1 matrix objects, where N is the output dimension of the
%               system
% 
% OUTPUT:
%               - pars: a pest object containing parameter estimation
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'linfitsvd')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = linfitsvd(varargin)
  
  %%% LTPDA stufs and get data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
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
  
  inhists = [mtxs(:).hist];
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  %%% get input parameters
  % if the model is a matrix of smodels
  lmod      = find_core(pl, 'dmodel');
  % if the model is ssm
  inNames   = find_core(pl,'InNames');
  outNames  = find_core(pl,'OutNames');
  % common parameters
  mod        = find_core(pl,'Model');
  fitparams  = find_core(pl,'FitParams');
  inputdat   = find_core(pl,'Input');
  WF         = find_core(pl,'WhiteningFilter');
  nloops     = find_core(pl,'Nloops');
  ncut       = find_core(pl,'Ncut');
  npad       = find_core(pl,'Npad');
  kwnpars    = find_core(pl,'KnownParams');
  tol        = find_core(pl,'tol');
  fastopt    = find_core(pl,'fast');
  setalias   = find_core(pl,'SetAlias');
  sThreshold = find_core(pl,'sThreshold');
  diffStep   = find_core(pl,'diffStep');
  resample_filter = find_core(pl, 'Resample filter');
  
  boundedpars = find_core(pl,'BoundedParams');
  boudary     = find_core(pl,'BoundVals');
  
  modelFS     = find_core(pl, 'Model FS');
  
  % check if there are bounded parameters
  if ~isempty(boundedpars)
    boundparams = true;
  else
    boundparams = false;
  end
  
  
  % check the class of the model
  if isa(mod,'ssm')
    ssmmod = true;
  else
    ssmmod = false;
  end
  
  %%% some sanity checks
  if ~ssmmod
    if numel(mtxs) ~= numel(inputdat.objs)
      error('Number of input data vectors must be the same of fit data vectors')
    end
  end
  
  
  [fitparams,idx] = sort(fitparams);
  fitparvals = fitparams;
  paramunits = unit.initObjectWithSize(numel(fitparams),1);
  if ssmmod
    %%% get fit parameters
    for ii=1:numel(fitparams)
      fitparvals{ii} = mod.getParameters(plist('names',fitparams{ii}));
      paramunits(ii) = mod.params.getPropertyForKey(fitparams{ii}, 'units');
    end
    if isempty(diffStep)
      sdiffStep = cell2mat(fitparvals).*0.01;
      idz = sdiffStep == 0;
      sdiffStep(idz) = 1e-7;
    else
      sdiffStep = diffStep(idx);
    end
  else
    %%% get a single set of parameters
    totparnames = {};
    totparvals  = {};
    for ii=1:numel(mod.objs)
      aa = mod.objs(ii).params;
      cc = mod.objs(ii).values;
      % get total parameter names
      [bb,i1,i2]=union(totparnames,aa);
      totparnames = [totparnames(i1),aa(i2)];
      % get total parameter values
      totparvals = [totparvals(i1),cc(i2)];
    end
    [totparnames,id] = sort(totparnames);
    totparvals = totparvals(id);

    %%% get fit parameters
    [nn,i1,i2] = intersect(totparnames,fitparams);
    fitparams = totparnames(i1);
    fitparvals = totparvals(i1);
    [fitparams,id] = sort(fitparams);
    fitparvals = fitparvals(id);
  end
  
  if ~ssmmod
    %%% linearize model with respect to fit parameters
    if isempty(lmod) 
      lmod = linearize(mod,plist('Params',fitparams,'Sorting',false));
    end
  end
  
  
  if isempty(WF)
    wfdat = copy(mtxs,1);
  elseif ~fastopt
    %%% whitening fit data
    wfdat = copy(mtxs,1);
    for ii=1:numel(mtxs)
      wfdat(ii) = filter(mtxs(ii),WF);
    end
  end
  
  % decide to pad in any case, assuming the objects have the same length
  if isempty(npad)
    npad = length(mtxs(1).objs(1).data.y) - 1;
  end
  
  % set alias if there are
  if setalias && (~ssmmod && ~isempty(mod.objs(1).aliasNames))
    nsecs = mtxs(1).objs(1).data.nsecs;
    fs = mtxs(1).objs(1).data.fs;

    plalias = plist('nsecs',nsecs,'npad',npad,'fs',fs);
    for ii=1:numel(mod.objs)
     mod.objs(ii).assignalias(mod.objs(ii),plalias);
    end
    for jj=1:numel(lmod.objs)
      for ii=1:numel(lmod.objs{jj}.objs)
       lmod.objs{jj}.objs(ii).assignalias(lmod.objs{jj}.objs(ii),plalias);
      end
    end
  end
  
  % do a copy to add at the output pest
  outmod = copy(mod,1);
  
  % check if the fast option is active
  if ~ssmmod && fastopt
    % set length of fft (this should match the operation made in fftfilt_core)
    nfft = length(mtxs(1).objs(1).data.y) + npad;
    fs = mtxs(1).objs(1).data.fs;
    % get fft freqs for current data. type option must match the one used
    % in fftfilt_core for fft_core
    fftfreq = utils.math.getfftfreq(nfft,fs,'one');
    % calculate freq resp of diagonal elements of WF
    rWF = getWFresp(WF,fftfreq,fs);
    % combine symbolic models with rWF
    mod = joinmodelandfilter(mod,rWF);
    lmod = joinmodelandfilter(lmod,rWF);
    WF = [];
    %%% whitening fit data
    wfdat = copy(mtxs,1);
    for ii=1:numel(mtxs)
      for jj=1:numel(mtxs(ii).objs)
        wfdat(ii).objs(jj) = fftfilt_core(wfdat(ii).objs(jj),rWF.objs(jj),npad);
      end
    end
    clear rWF
  end
  
  % init storage struct
  loop_results = struct('a',cell(1),...
    'Ca',cell(1),...
    'Corra',cell(1),...
    'Vu',cell(1),...
    'bu',cell(1),...
    'Cbu',cell(1),...
    'Fbu',cell(1),...
    'mse',cell(1),...
    'params',cell(1),...
    'ppm',cell(1));
  
  % init user interaction variable
  reply = 'N';
  
  %%% run fit loop

  % This causes problems on some machines so we remove it for now until we
  % can investigate further.
  %   fftw('planner', 'exhaustive');

  for kk=1:nloops
    
    % init index variable
    xxx = 1;
    
    % init data struct
    exps = struct();
    
    %%% Set fit parameters into model
    if ssmmod
      fs = wfdat(1).objs(1).fs;
      if isempty(modelFS)
        modelFS = fs;
      end
      mod.doSetParameters(fitparams,cell2mat(fitparvals));
      lmod = parameterDiff(mod,plist('names',fitparams,'values',sdiffStep));
      lmod.modifyTimeStep(plist('newtimestep',1/modelFS));
    else
      % fitparvals are updated at each fit loop
      if fastopt
        for ii = 1:numel(mod.objs)
          mod.objs(ii).objs{2}.setParams(fitparams,fitparvals);
        end
      else
        for ii = 1:numel(mod.objs)
          mod.objs(ii).setParams(fitparams,fitparvals);
        end
      end
    end
    
    %%% run over input data
    
    for ii=1:numel(inputdat.objs)
      if ssmmod
        %%% extract input
        if isa(inputdat.objs{ii},'ao')
          in = inputdat.objs{ii};
        elseif isa(inputdat.objs{ii},'matrix')
          in = inputdat.objs{ii}.objs(:);
        else
          error('Unknown Input data type.')
        end
        
        %%% Resample input data to 10Hz, if necessary
        if in.fs ~= modelFS
          in = resample(in, plist('fsout', modelFS, 'filter', resample_filter));
        end
        
        %%% calculates zero order response
        plsym = plist('AOS VARIABLE NAMES',inNames{ii},...
          'RETURN OUTPUTS',outNames{ii},...
          'AOS',in);
        zor = simulate(lmod,plsym);
        % check dimensions
        if size(zor.objs,1)<size(zor.objs,2)
          % do transpose
          zor = transpose(zor);
        end
        
        % resample
        if fs ~= modelFS
          zor = resample(zor, plist('fsout', fs, 'filter', resample_filter));
        end
        
        %%% calculates first order response
        for jj=1:numel(fitparams)
          % get output ports names
          [token, remain] = strtok(outNames{ii},'.');
          loutNames = token;
          for zz=1:numel(token)
            loutNames{zz} = sprintf('%s_DIFF_%s%s',token{zz},fitparams{jj},remain{zz});
          end

          plsym = plist('AOS VARIABLE NAMES',inNames{ii},...
            'RETURN OUTPUTS',loutNames,...
            'AOS',in);
          fstor(jj) = simulate(lmod,plsym);
          % check dimensions
          if size(fstor(jj).objs,1)<size(fstor(jj).objs,2)
            % do transpose
            fstor(jj) = transpose(fstor(jj));
          end
          fstor(jj).setName(fitparams{jj});

          % resample
          if fs ~= modelFS
            fstor(jj) = resample(fstor(jj), plist('fsout', fs, 'filter', resample_filter));
          end
          
        end
        
      else
        %%% calculates zero order response
        zor = fftfilt(inputdat.objs{ii},mod,plist('Npad',npad));

        %%% calculates first order response
        for jj=1:numel(lmod.objs)
          fstor(jj) = fftfilt(inputdat.objs{ii},lmod.objs{jj},plist('Npad',npad));
          fstor(jj).setName(lmod.objs{jj}.name);
        end
      end

      if isempty(WF)
        wzor = zor;
        wfstor = fstor;
      else
        %%% whitening zor
        wzor = filter(zor,WF);

        %%% whitening fstor
        for jj=1:numel(fstor)
          wfstor(jj) = filter(fstor(jj),WF);
          wfstor(jj).setName(fstor(jj).name);
        end
      end
      
      %%% Collect object for the fit procedure
      for jj=1:numel(wfdat(ii).objs)
        % get difference between fit data and zero order response 
        tfdat = wfdat(ii).objs(jj) - wzor.objs(jj);
        % remove whitening filter transient
        tfdats = tfdat.split(plist('samples',[ncut+1 numel(tfdat.y)]));
        % insert into exps struct
        fitdata(xxx,1) = tfdats;
        
        % build fit basis
        for gg=1:numel(fitparams)
          for hh=1:numel(wfstor)
            if strcmp(fitparams(gg),wfstor(hh).name)
              bsel = wfstor(hh).objs(jj);
              % remove whitening filter transient
              bsels = bsel.split(plist('samples',[ncut+1 numel(tfdat.y)]));
            end
          end
          bs(gg) = bsels;
        end
        % insert basis
        fitbasis(xxx,:) = bs;
        
        % step up xxx
        xxx = xxx + 1;
      end %jj=1:numel(wfdat(ii).objs)
      
    end %ii=1:numel(inputdat.objs)
    
    %%% build input objects
    [NN,MM] = size(fitbasis);
    
    for zz=1:MM
      H(1,zz) = matrix(fitbasis(:,zz));
    end
    
    Y = matrix(fitdata);
    
    %%% Insert known parameters
    if ~isempty(kwnpars)
      kwnparmanes = kwnpars.names;
      kwnparvals = kwnpars.y;
      kwnparerrors = kwnpars.dy;

      % init struct
      groundexps = struct;

      for ii=1:numel(kwnparmanes)
        for jj=1:numel(fitparams)
          if strcmp(kwnparmanes{ii},fitparams{jj})
            groundexps(ii).pos = jj;
            groundexps(ii).value = kwnparvals(ii);
            groundexps(ii).err = kwnparerrors(ii);
          end
        end
      end
    end
    
    
    %%% do fit
    if ~isempty(kwnpars) && isfield(groundexps,'pos')
      plfit = plist('KnownParams',groundexps,'sThreshold',sThreshold);
      [out,a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = linlsqsvd(H,Y,plfit);
    else
      plfit = plist('sThreshold',sThreshold);
      [out,a,Ca,Corra,Vu,bu,Cbu,Fbu,mse,dof,ppm] = linlsqsvd(H,Y,plfit);
    end
    
    %%% update parameters values
    for ii=1:numel(fitparams)
      fitparvals{ii} = fitparvals{ii} + a(ii);
    end
    
    %%% check for bouded params
    if boundparams
      for pp=1:numel(fitparams)
        for qq=1:numel(boundedpars)
          if strcmp(fitparams{pp},boundedpars{qq});
            % check boudaries
            bd = boudary{qq};
            if fitparvals{pp}<bd(1)
              fitparvals{pp} = bd(1);
            elseif fitparvals{pp}>bd(2)
              fitparvals{pp} = bd(2);
            end
          end
        end
      end
    end
    
    % useful in debug phase
    %plot_residuals(inputdat,mtxs,mod,inNames,outNames,fitparams,fitparvals,fs)
    
    %%% store intermediate results
    loop_results(kk).a = a;
    loop_results(kk).Ca = Ca;
    loop_results(kk).Corra = Corra;
    loop_results(kk).Vu = Vu;
    loop_results(kk).bu = bu;
    loop_results(kk).Cbu = Cbu;
    loop_results(kk).Fbu = Fbu;
    loop_results(kk).mse = mse;
    loop_results(kk).params = fitparvals;
    loop_results(kk).ppm = ppm;
    
    utils.helper.msg(msg.IMPORTANT, 'loop %d, mse %d\n',kk,mse);
    
    % check fit stability and accuracy
    fitmsg = checkfit(Vu,a);
    if ~isempty(fitmsg) && ~strcmpi(reply,'Y')
      % display message
      utils.helper.msg(msg.IMPORTANT, fitmsg);
      % decide if stop for cycle
      reply = input('Do you want to carry on with fit iteration? Y/N [Y]: ', 's');
      if isempty(reply)
        reply = 'Y';
      end
      if strcmpi(reply,'N')
        break
      end
    end
    
    % check convergence
    condvec = (abs(a).^2)./diag(Ca); % parameters a are going to zero during the fit iterations

    if all(condvec < tol)
      condmsg = sprintf(['Fit parameters have reached convergence.\n'...
        'Fit loop was terminated at iteration %s.\n'],num2str(kk));
      utils.helper.msg(msg.IMPORTANT, condmsg);
      break
    end

    
  end %for kk=1:nloops
  
  %%% output data
  % get minimum mse
  % fitmsg is non-empty only if a problem is found during the fit. Therefore
  % in any normal fit the set of instruction in the else command will be
  % executed
  if ~isempty(fitmsg)
    val = mse;
    idx = kk;
  else
    mseprog = zeros(numel(loop_results),1);
    for ii=1:numel(loop_results)
      mseprog(ii) = loop_results(ii).mse;
    end
    [val,idx] = min(abs(mseprog-1)); % get the value nearest to 1
    utils.helper.msg(msg.IMPORTANT, ['Output values at mse nearest to 1; mse = %d\n'],mseprog(idx));
  end
  
  % output pest object
  pe = pest();
  pe.setY(cell2mat(loop_results(idx).params));
  pe.setDy(sqrt(diag(loop_results(idx).Ca)));
  pe.setCov(loop_results(idx).Ca);
  pe.setChi2(loop_results(idx).mse);
  pe.setNames(fitparams);
  pe.setDof(dof);
  pe.setModels(outmod);
  pe.setName(sprintf('linfitsvd(%s)', mod.name));
  pe.setProcinfo(plist('loop_results',loop_results));
  if ssmmod
    pe.setYunits(paramunits);
  end

  % set History
  pe.addHistory(getInfo('None'), pl, [mtxs_invars(:)], [inhists(:)]);
  varargout{1} = pe;
  
  
  
end

%--------------------------------------------------------------------------
% check fit accuracy and stability
%--------------------------------------------------------------------------
function msg = checkfit(V,aa)

  if size(V,1)<numel(aa)
    % The number of parameters combinations is less than the number of fit
    % parameters. Information cannot be reconstructed fit results will be
    % compromised
    VV = abs(V).^2;
    num = numel(aa)-size(V,1);
    mVV = max(VV);
    % try to identify non measured params
    unmparams = [];
    for jj = 1:num
      [vl,idx] = min(mVV);
      unmparams = [unmparams idx];
      mVV(idx) = [];
    end
    msg = sprintf(['!!! The number of parameters combinations is less than the number of fit parameters. \n' ...
      'Information cannot be reconstructed and fit results will be compromised. \n'...
      'Try to remove parameters %s from the fit parameters list or add information with more experiments !!!\n'],num2str(unmparams));
    
  else
    
    unmparams = [];
    trh1 = 1e-4;
    
    % eigenvectors are normalized, therefore square of the rows of V are sum
    % to one. Each column of V store the coefficients for a given parameter
    % for the set of eigenvectors
    for jj = 1:size(V,2)
      cl = abs(V(:,jj)).^2;
      if all(cl<trh1)
        unmparams = [unmparams jj];
      end
    end
    if ~isempty(unmparams)
      msg = sprintf(['!!! Parameter/s %s is/are not well measured. \n'...
        'Fit accuracy could be impaired. \n'...
        'Try to remove such parameters from the fit parameters list !!!\n'],num2str(unmparams));
    else
      msg = '';
    end
  end
  
  
  
  
    
end

%--------------------------------------------------------------------------
% calculate frequency response of diagonal elements of the whitening filter
%--------------------------------------------------------------------------
function rsp = getWFresp(wf,f,fs)
  % run over wf elements
  obj = wf.objs;
  [rw,cl] = size(obj);
  if rw~=cl
    error('??? Matrix of whitening filter must be square');
  end
  amdl = ao.initObjectWithSize(rw,1);
  for jj=1:rw
    % check filter type
    switch lower(class(obj(jj,jj)))
      case 'filterbank'
        % get filter response on given frequencies
        amdly = utils.math.mtxiirresp(obj(jj,jj).filters,f,fs,obj(jj,jj).type);
        amdl(jj,1) = ao(fsdata(f, amdly, fs));
      case 'miir'
        % get filter response on given frequencies
        amdly = utils.math.mtxiirresp(obj(jj,jj),f,fs,[]);
        amdl(jj,1) = ao(fsdata(f, amdly, fs));
    end
  end
  rsp = matrix(amdl,plist('shape',[rw 1]));

end

%--------------------------------------------------------------------------
% Join Symbolic model and whitening filter for fast calculations
%--------------------------------------------------------------------------
function jmod = joinmodelandfilter(smod,fil)
  switch class(smod)
    case 'matrix'
      mobj = smod.objs;
      [nn,mm] = size(mobj);
      nmobj = collection.initObjectWithSize(nn,mm);
      for ii=1:nn
        for jj=1:mm
          nmobj(ii,jj) = collection(fil.objs(ii,1),mobj(ii,jj));
          nmobj(ii,jj).setName(mobj(ii,jj).name);
        end
      end
      jmod = matrix(nmobj, plist('shape',[nn,mm]));
      jmod.setName(smod.name);
    case 'collection'
      matobj = matrix.initObjectWithSize(1,numel(smod.objs));
      for kk=1:numel(smod.objs)
        mobj = smod.objs{kk}.objs;
        [nn,mm] = size(mobj);
        nmobj = collection.initObjectWithSize(nn,mm);
        for ii=1:nn
          for jj=1:mm
            nmobj(ii,jj) = collection(fil.objs(ii,1),mobj(ii,jj));
            nmobj(ii,jj).setName(mobj(ii,jj).name);
          end
        end
        matobj(kk) = matrix(nmobj);
        matobj(kk).setName(smod.objs{kk}.name);
        %smod.objs{kk} = matobj;
      end
      jmod = collection(matobj);
  end

end

%--------------------------------------------------------------------------
% plot residuals
%--------------------------------------------------------------------------
function plot_residuals(inputdat,mtxs,mod,inNames,outNames,fitparams,fitparvals,fs)
  
  Nexps = numel(mtxs);
  
  plsp = plist('order',1);
  
  idf = 1;
  
  HH = copy(mod,1);
  HH.doSetParameters(fitparams,cell2mat(fitparvals));
  HH.subsParameters;
  HH.modifyTimeStep(plist('NEWTIMESTEP',1/fs));
  
  for ii=1:Nexps
    in = inputdat.objs{ii};
    om = mtxs(ii);
    
    t0 = in(1).t0;
    plsym = plist('AOS VARIABLE NAMES',inNames{ii},...
      'RETURN OUTPUTS',outNames{ii},...
      'AOS',in,...
      't0',t0);
    sm = simulate(HH,plsym);
    
    Nout = numel(sm.objs);
    for jj=1:Nout
      
      oo = om.objs(jj);
      ss = sm.objs(jj);
      rr = oo-ss;
      
      rrxx = lpsd(rr,plsp);
      
      lgd = sprintf('Exp. %s, Ch. %s',num2str(ii),num2str(jj));
      h = figure(idf);
      iplot(rrxx,plist('FIGURE',h,'LEGENDS',{lgd}));
      hold on
      
      idf = idf + 1;
      
    end
    
  end

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
  ii.setModifier(false);
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

  % General plist for multichannel fits
  pl = copy(plist.MCH_FIT_PLIST,1);
    
  p = param({'BoundedParams','A cell array with the names of the bounded fit parameters'}, {});
  pl.append(p);
  
  p = param({'BoundVals','A cell array with the boundaries values for the bounded fit parameters'}, {});
  pl.append(p);
  
  p = param({'dModel','Partial derivatives of the system parametric model. A matrix of smodel objects'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
    
  p = param({'WhiteningFilter','The multichannel whitening filter. A matrix object of filters'},paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'Nloops', 'Number of desired iteration loops.'}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  p = param({'Ncut', 'Number of bins to be discharged in order to cut whitening filter transients'}, paramValue.DOUBLE_VALUE(100));
  pl.append(p);
  
  % Number of points for zero padding
  p = param({'Npad', 'Number of points for zero padding.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'KnownParams', 'Known Parameters. A pest object containing parameters values, names and errors'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'tol','Convergence threshold for fit parameters'}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  p = param({'fast',['Using fast option causes the whitening filter to be applied in frequency domain.'... 
    'The filter matrix is considered diagonal. The method skip time domain filtering saving some process time'...
    'It works only when the imput model is a matrix of smodels']}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  p = param({'SetAlias','Set to true in order to aassign internally the values to the model alias'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  p = param({'sThreshold',['Fix upper treshold for singular values.'...
    'Singular values larger than the value will be ignored.'...
    'This correspon to consider only parameters combinations with error lower then the value']},...
    paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  p = plist({'diffStep','Numerical differentiation step for ssm models'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'Model FS','The sample rate to discretize the model at for performing the simulations.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = plist({'Resample filter','The filter used for resampling when adjusting the input data to the model fs.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end
