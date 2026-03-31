% CPSD computes the output theoretical CPSD shape with given inputs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CPSD computes the output theoretical CPSD shape with given inputs.
%              Unlike ssm/psd, it returns the total contribution and takes
%              input vectors/square matrices of objects 
%
% CALL: [mat_out] = cpsd(sys, pl)
%
% INPUTS:
%         - sys, (array of) ssm object
%
% OUTPUTS:
%          _ mat_out contains specified returned aos
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'cpsd')">Parameters Description</a>
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cpsd(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;
  
  utils.helper.msg(utils.const.msg.PROC3, ['running ', mfilename]);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all SSMs and plists
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  % Get plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  
  % retrieve system info  
  if numel(sys)~=1
    error('ssm/cpsd needs exactly one ssm as an input')
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
  if ~callerIsMethod
    inhist  = sys.hist;
  end
  
  % modifying system's ordering
  if find(pl, 'reorganize')
    reorgPlist = ssm.getInfo('reorganize', 'for cpsd').plists;
    sys = reorganize(sys, subset(pl.pset('set', 'for cpsd'), reorgPlist.getKeys));
  end
  
  % collecting functions i/o data
  aos_in = find(pl, 'aos');
  PZ_in = find(pl, 'PZmodels');
  cov_in = find(pl, 'covariance');
  cpsd_in = find(pl, 'CPSD');
  noise_in = blkdiag(cov_in, cpsd_in/(timestep*2));
  [U1,S1,V1] = svd(noise_in.');
  noise_mat = U1*sqrt(S1);
    
  % getting system's i/o sizes
  inputSizes = sys.inputsizes;
  outputSizes = sys.outputsizes;
  
  Naos_in = inputSizes(1);
  NPZmodels = inputSizes(3);
  
  % retrieving frequency vector
  if isempty(aos_in)
    freqs = pl.find('f');
    if isempty(freqs)
      f1 = find(pl,'f1');
      f2 = find(pl,'f2');
      NFreqs = find(pl,'nf');
      if isempty(f1) || isempty(f2)|| isempty(NFreqs)
        error('### Please specify frequency vector a start and stop frequency .');
      else
        freqs = 10.^linspace(log10(f1), log10(f2), NFreqs);
      end
    else
      NFreqs = numel(freqs);
    end
  else
    freqs = aos_in(1).x;
    NFreqs = numel(freqs);
  end
  
  % checking frequency vector
  for i=2:numel(aos_in)
    if ~isequal(freqs,aos_in(i).x)
      error('there exist different frequency vectors');
    end
  end
  
  % reshape pzmodels and aos for input cross-spectra
  if numel(PZ_in)==NPZmodels
    PZfull = false;
    PZdata = zeros(NPZmodels,NFreqs);
    for i=1:NPZmodels
      a = resp(PZ_in(i), freqs);
      PZdata(i,:) = reshape(a.y,[1,NFreqs]) ;
    end
  elseif size(PZ_in,1)==NPZmodels && size(PZ_in,2)==NPZmodels 
    PZfull = true;
    PZdata = zeros(Npzmodels,Npzmodels,NFreqs);
    for i=1:NPZmodels
      for j=1:Npzmodels
        a = resp(PZ_in(i,j), freqs);
        PZdata(i,j,:) = reshape(a.y,[1,NFreqs]) ;
      end
    end
  else
    error('Wrong size for field PZ_in')
  end
  
  if numel(aos_in)==Naos_in
    AOfull = false;
    AOdata = zeros(Naos_in,NFreqs);
    for i=1:Naos_in
      AOdata(i,:) = reshape(aos_in(i).y,[1,NFreqs]) ;
    end
  elseif size(aos_in,1)==Naos_in && size(aos_in,2)==Naos_in
    AOfull = true;
    AOdata = zeros(Naos_in,Naos_in,NFreqs);
    for i=1:Naos_in
      for j=1:Naos_in
        AOdata(i,j,:) = reshape(aos_in(i,j).y,[1,NFreqs]) ;
      end
    end
  else
    error('Wrong size for field aos_in')
  end
    
  % SSM Transfer function
  [a, b, c, d, Ts, InputName, StateName, OutputName,...
    inputvarunits, ssvarunits, outputvarunits] = double(sys);
  resps    = ssm.doBode(a, b, c, d, 2*pi*freqs, Ts);
  Noutputs = numel(OutputName);

  % power for each frequency with SVD computation
  Result = zeros(Noutputs,Noutputs,NFreqs);
  
  for i_freq=1:NFreqs
    % contribution from aos, testing positiveness
    if AOfull
      PowAO = squeeze(AOdata(:,:,i_freq));
      [U1,S1,V1] = svd(PowAO.');
      if (sum(S1<0)>0)
        error('AO covariance matrix is not positive')
      end
      AmpAO = U1*sqrt(S1);
    else
      if (sum(AOdata(:,i_freq)<0)>0)
        error('non positive covariance')
      end
      AmpAO = diag(AOdata(:,i_freq).^0.5);
    end
    % contribution from PZmodels, testing positiveness
    if PZfull
      PowPZ = squeeze(PZdata(:,:,i_freq));
      [U1,S1,V1] = svd(PowPZ.');
      if (sum(S1<0)>0)
        error('PZmodels covariance matrix is not positive')
      end
      AmpPZ = U1*sqrt(S1);
    else
      if (sum(PZdata(:,i_freq)<0)>0)
        error('non positive covariance')
      end
      AmpPZ = diag(PZdata(:,i_freq).^0.5);
    end
    % summing all three contributions sources, computing CPSD
    Amp = blkdiag(AmpAO, noise_mat, AmpPZ);
    RespLoc = squeeze(resps(:,:,i_freq));
    noise = RespLoc * Amp * (RespLoc*Amp)';
    Result(:,:,i_freq) = real(noise) * (2*timestep); % 2 correction added here
  end
  
  % saving in aos
  ao_out = ao.initObjectWithSize(Noutputs, Noutputs);

  for io=1:Noutputs
    for jo=1:Noutputs
      ao_out(io,jo).setData(fsdata(freqs, squeeze(Result(jo,io,:))));
      if io~=jo
        ao_out(io,jo).setName( ['Cross PSD of ', OutputName{jo}, ' and ', OutputName{io}]);
      else
        ao_out(io,jo).setName( ['PSD of ' , OutputName{jo}]);
      end
      ao_out(io,jo).setXunits(unit.Hz);
      ao_out(io,jo).setYunits(outputvarunits(io)*outputvarunits(jo) / unit.Hz);
      if io~=jo
        ao_out(io,jo).setDescription( ['Cross PSD of ', OutputName{jo}, ' and ', OutputName{io}]);
      else
        ao_out(io,jo).setDescription( ['PSD of ' , OutputName{jo}]);
      end
    end
  end
  
  % construct output matrix object
  out = matrix(ao_out);
  if callerIsMethod
    % do nothing
  else
    myinfo = getInfo('None');
    out.addHistory(myinfo, pl , ssm_invars(1), inhist );
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, out);
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
  
  pl = copy(ssm.getInfo('reorganize', 'for CPSD').plists, 1);
  pl.remove('set');
  
  p = param({'covariance', 'The covariance of this noise between input ports for the <i>time-discrete</i> noise model.'}, []);
  pl.append(p);
  
  p = param({'CPSD', 'The one sided cross-psd of the white noise between input ports.'}, []);
  pl.append(p);
  
  p = param({'aos', 'An array of input AOs, The power spectrum of this noise between input ports for the <i>time-continuous</i> noise model.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'PZmodels', 'An array of input pzmodels for noise filtering'}, paramValue.EMPTY_DOUBLE); 
  pl.append(p);
  
  p = param({'reorganize', 'When set to 0, this means the ssm does not need be modified to match the requested i/o. Faster but dangerous!'}, paramValue.TRUE_FALSE);
  pl.append(p);

  p = param({'f2', 'The maximum frequency. Default is Nyquist or 1Hz.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'f1', 'The minimum frequency. Default is f2*1e-5.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'nf', 'The number of frequency bins. Frequencies are scale logarithmically'}, paramValue.DOUBLE_VALUE(200));
  pl.append(p);
  
  p = param({'f', 'Specify a vector of frequencies. If this is used, ''f1'', ''f2'', and ''nf'' parameters are ignored.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end

