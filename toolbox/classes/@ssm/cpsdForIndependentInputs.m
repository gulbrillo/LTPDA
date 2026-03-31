% CPSDFORINDEPENDENTINPUTS computes the output theoretical CPSD shape with given inputs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: cpsdForIndependentInputs computes the output theoretical
%              CPSD or PSD shape for given input shapes.
%              It returns summed and individual contributions and takes
%              input vectors of objects (instead of square matrices)
%
% CALL:        [mat_outSum, mat_out] = PSD(sys, pl)
%
% INPUTS:
%               sys - (array of) ssm object
%
% OUTPUTS:
%              mat_outSum - contains specified returned aos, noise is
%                           summed over all the specified input noises
%              mat_out    - contains specified returned aos
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'cpsdForIndependentInputs')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cpsdForIndependentInputs(varargin)
  
  %% starting initial checks
  
  % use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all SSMs and plists
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  %%% Internal call: Only one object + don't look for a plist
  internal = utils.helper.callerIsMethod();
  
  %% begin function body
  
  %% retrieve system infos
  
  if numel(sys)~=1
    error('noisespectrum needs exactly one ssm as an input')
  end
  if ~sys.isnumerical
    error(['error because system ',sys.name,' is not numerical']);
  end
  if ~sys.isStable
    error('input ssm is not stable!')
  end
  if sys.timestep==0
    timestep = 1;
  else
    timestep = sys.timestep;
  end
  if ~internal
    inhist  = sys.hist;
  end
  
  %% modifying system's ordering
  if find(pl, 'reorganize')
    sys = reorganize(sys, pl, plist('set', 'for cpsdForIndependentInputs'));
  end
  
  %% collecting functions i/o data
  aos_in = find(pl, 'aos');
  PZ_in = find(pl, 'PZmodels');
  cov_in = find(pl, 'variance');
  cpsd_in = find(pl, 'PSD');
  
  noise_mat = [...
    reshape(cov_in, [numel(cov_in),1]) ; ...
    reshape(cpsd_in, [numel(cpsd_in),1]) / (timestep*2)];
  if sum(noise_mat<0) > 0
    error('input PSD is not positive!')
  end
  
  %% getting system's i/o sizes
  inputSizes = sys.inputsizes;
  outputSizes = sys.outputsizes; %#ok<NASGU>
  
  Naos_in = inputSizes(1);
  Nnoise = inputSizes(2);
  NPZmodels = inputSizes(3);
  
  %% retrieving frequency vector
  if isempty(Naos_in)==0
    f1 = find(pl,'f1');
    f2 = find(pl,'f2');
    NFreqs = find(pl,'nf');
    if isempty(f1) || isempty(f2)|| isempty(NFreqs)
      error('### Please specify frequency vector a start and stop frequency .');
    else
      freqs = 10 .^ linspace(log10(f1), log10(f2), NFreqs);
    end
  else
    freqs = aos_in(1).x;
  end
  
  %% checking frequency vector
  for i=2:numel(aos_in)
    if ~isequal(freqs,aos_in(i).x)
      error('there exist different frequency vectors');
    end
  end
  
  %% reshape pzmodels and aos for input cross-spectra
  if numel(PZ_in)==NPZmodels
    PZdata = zeros(NPZmodels,NFreqs);
    for i=1:NPZmodels
      a = resp(PZ_in(i), freqs);
      PZdata(i,:) = reshape(a.y,[1,NFreqs]) ;
    end
  else
    error('Wrong size for field PZ_in')
  end
  
  if numel(aos_in)==Naos_in
    AOdata = zeros(Naos_in,NFreqs);
    for i=1:Naos_in
      AOdata(i,:) = reshape(aos_in(i).y,[1,NFreqs]) ;
    end
  else
    error('Wrong size for field aos_in')
  end
  
  %% SSM Transfer function
  [a, b, c, d, Ts, InputName, StateName, OutputName,...
    inputvarunits, ssvarunits, outputvarunits] = double(sys); %#ok<ASGLU>
  resps    = ssm.doBode(a, b, c, d, 2*pi*freqs, Ts);
  Noutputs = numel(OutputName);
  
  %% power for each frequency with SVD computation
  diagOnly = pl.find('DIAGONAL ONLY');
  if diagOnly
    Result = zeros(Noutputs, Nnoise+Naos_in+NPZmodels, NFreqs);
  else
    Result = zeros(Noutputs, Noutputs, Nnoise+Naos_in+NPZmodels, NFreqs);
  end
  
  for ff=1:NFreqs
    for ii = 1:(Nnoise+Naos_in+NPZmodels)
      powWhiteNoise = zeros(1,Nnoise);
      powAO = zeros(1, Naos_in);
      powPZ = zeros(1,NPZmodels);
      if ii<Nnoise+1,
        %% contribution from white noise
        powWhiteNoise(ii) = noise_mat(ii) ;
      elseif ii<Nnoise+Naos_in+1
        %% contribution from aos
        i_input2 = ii-Nnoise;
        if AOdata(i_input2,ff)<0
          error('input PSD is not positive!')
        end
        powAO(i_input2) = AOdata(i_input2,ff);
      else
        %% contribution from PZmodels
        i_input2 = ii-Nnoise-Naos_in;
        if PZdata(i_input2,ff)<0
          error('input PSD is not positive!')
        end
        powPZ(i_input2) = real( PZdata(i_input2,ff) * conj( PZdata(i_input2,ff)) );
      end
      %% computing CPSD
      pow = diag([powAO; powWhiteNoise; powPZ]);
      RespLoc = squeeze(resps(:,:,ff));
      noise = RespLoc * pow * RespLoc' * (2*timestep);
      if diagOnly
        Result(:,ii,ff) = real(diag(noise));
      else
        Result(:,:,ii,ff) = noise;
      end
      
    end
  end
  
  %% saving in aos
  if diagOnly
    ao_outSum = ao.initObjectWithSize(Noutputs, 1);
    %% sum of all inputs
    for oo=1:Noutputs
      ao_outSum(oo,1).setData(fsdata(freqs, squeeze(sum(Result(oo,:,:),2))));
      ao_outSum(oo,1).setName( ['PSD of ' , OutputName{oo} ' due to all contributions']);
      ao_outSum(oo,1).setXunits(unit.Hz);
      ao_outSum(oo,1).setYunits(outputvarunits(oo)^2 / unit.Hz);
      ao_outSum(oo,1).setDescription( ['PSD of ' , OutputName{oo} ' due to all contributions']);
    end
    if nargout ~= 1;
      ao_out = ao.initObjectWithSize(Noutputs, Nnoise+Naos_in+NPZmodels);
      %% individual inputs
      for oo=1:Noutputs
        for ii=1:(Nnoise+Naos_in+NPZmodels)
          ao_out(oo,ii).setData(fsdata(freqs, squeeze(Result(oo,ii,:))));
          ao_out(oo,ii).setName( ['PSD of ' , OutputName{oo} ' due to ' InputName{ii}]);
          ao_out(oo,ii).setXunits(unit.Hz);
          ao_out(oo,ii).setYunits(outputvarunits(oo)^2 / unit.Hz);
          ao_out(oo,ii).setDescription( ['PSD of ' , OutputName{oo} ' due to ' InputName{ii}]);
        end
      end
    end
  else
    ao_outSum = ao.initObjectWithSize(Noutputs, Noutputs);
    %% sum of all inputs
    for oo=1:Noutputs
      for pp=1:Noutputs
        ao_outSum(oo,pp).setData(fsdata(freqs, squeeze(sum(Result(oo,pp,:,:),3))));
        ao_outSum(oo,pp).setXunits(unit.Hz);
        ao_outSum(oo,pp).setYunits(outputvarunits(oo)^2 / unit.Hz);
        if oo~=pp
          ao_outSum(oo,pp).setName( ['Cross PSD of ', OutputName{oo}, ' and ', OutputName{pp} ' due to all contributions']);
          ao_outSum(oo,pp).setDescription( ['Cross PSD of ', OutputName{oo}, ' and ', OutputName{pp} ' due to all contributions']);
        else
          ao_outSum(oo,pp).setName( ['PSD of ' , OutputName{oo}]);
          ao_outSum(oo,pp).setDescription( ['PSD of ' , OutputName{oo}]);
        end
      end
    end
    if nargout ~= 1;
      ao_out = ao.initObjectWithSize(Noutputs, Noutputs, Nnoise+Naos_in+NPZmodels);
      %% individual inputs
      for oo=1:Noutputs
        for pp=1:Noutputs
          for ii=1:(Nnoise+Naos_in+NPZmodels)
            ao_out(oo,pp,ii).setData(fsdata(freqs, squeeze(Result(oo,pp,ii,:))));
            ao_out(oo,pp,ii).setXunits(unit.Hz);
            ao_out(oo,pp,ii).setYunits(outputvarunits(oo)^2 / unit.Hz);
            if oo~=pp
              ao_out(oo,pp,ii).setName( ['Cross PSD of ', OutputName{oo}, ' and ', OutputName{pp} ' due to ' InputName{ii}]);
              ao_out(oo,pp,ii).setDescription( ['Cross PSD of ', OutputName{oo}, ' and ', OutputName{pp} ' due to ' InputName{ii}]);
            else
              ao_out(oo,pp,ii).setName( ['PSD of ' , OutputName{oo} ' due to ' InputName{ii}]);
              ao_out(oo,pp,ii).setDescription( ['PSD of ' , OutputName{oo} ' due to ' InputName{ii}]);
            end
          end
        end
      end
    end
  end
  
  
  
  %% construct output matrix object
  if nargout ~= 1;
    out = matrix(ao_out);
  end
  outSum = matrix(ao_outSum);
  if callerIsMethod
    % do nothing
  else
    myinfo = getInfo('None');
    if nargout ~= 1;
      out.addHistory(myinfo, pl , ssm_invars(1), inhist );
    end
    outSum.addHistory(myinfo, pl , ssm_invars(1), inhist );
  end
  
  %% Set output depending on nargout
  if nargout == 1;
    varargout = {outSum};
  elseif nargout == 2;
    varargout = {outSum out };
  elseif nargout == 0;
    iplot(ao_outSum, ao_out);
  else
    error('Wrong number of outputs')
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
  
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  pl = ssm.getInfo('reorganize', 'for cpsdForIndependentInputs').plists;
  pl.remove('set');
  
  p = param({'variance', 'The variance vector of this noise between input ports for the <i>time-discrete</i> noise model. '}, []);
  pl.append(p);
  
  p = param({'PSD', 'The one sided psd vector of the white noise between input ports.'}, []);
  pl.append(p);
  
  p = param({'aos', 'A vector of input PSD AOs, The spectrum of this noise between input ports for the <i>time-continuous</i> noise model.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'PZmodels', 'vector of noise shape filters for the different corresponding inputs.'}, paramValue.DOUBLE_VALUE(zeros(0,1)));
  pl.append(p);
  
  p = param({'reorganize', 'When set to 0, this means the ssm does not need be modified to match the requested i/o. Faster but dangerous!'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'f2', 'The maximum frequency. Default is Nyquist or 1Hz.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'f1', 'The minimum frequency. Default is f2*1e-5.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'nf', 'The number of frequency bins. Frequencies are scale logarithmically'}, paramValue.DOUBLE_VALUE(200));
  pl.append(p);
  
  p = param({'diagonal only', 'Set to true if you want the PSD instead of the CPSD'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
end

