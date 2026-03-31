% NOISEPOWER computes the noise power spectral density in a time-series as a function of time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: NOISEPOWER computes the noise power spectral density in a
%              time-series as a function of time. 
% 
% The method takes the prescribed spectra of the input data and computes
% the mean spectral density in the specified frequency band and returns
% this for each segment that can be fit into the original time-series.
%
%
% CALL:        out = obj.noisePower(pl)
%              out = noisePower(objs, pl)
%
% INPUTS:      pl      - a parameter list
%              obj(s)  - input ao object(s)
%
% OUTPUTS:     out - some output.
%
%
% Created 2016-03-08, M Hewitson
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'noisePower')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = noisePower(varargin)
  
  % Determine if the caller is a method or a user
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Print a run-time message
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names for storing in the history
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all objects of class ao
  [objs, obj_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  %--- Decide on a deep copy or a modify.
  % If the no output arguments are specified, then we are modifying the
  % input objects. If output arguments are specified (nargout>0) then we
  % make a deep copy of the input objects and return modified versions of
  % those copies.
  objsCopy = copy(objs, nargout);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Extract input parameters from the plist
  psdpl = pl.subset(ao.getInfo('psd').plists.getKeys);
  freqs = pl.find('frequencies');
  
  if mod(numel(freqs), 2) ~= 0
    error('Please specify the frequency interval in the form of a vector [f1 f2 f3 f4], i.e. a set of frequency intervals');
  end
  
  if freqs(2) <= freqs(1)
    error('Please specify a positive frequency interval (f2 > f1)');
  end
  
  % Loop over input objects
  for jj = 1 : numel(objsCopy)
    % Process object jj
    object = objsCopy(jj);
    
    
    % process plist
    segs = psdSegments(psdpl.pset('L', object));
    sampleSegs = segs.find('samples');
    segTimes   = mean(reshape(sampleSegs-1, 2, length(sampleSegs)/2), 1);
    segTimes   = segTimes ./ object.fs;
    sampleSegs = sampleSegs(1:2:end);
    
    fprintf('* will compute %d segments from [%s]...\n', numel(sampleSegs), object.name);
    
    % PSD
    psdpl.pset('scale', 'PSD');
    
    S = psd(split(object, segs), psdpl);
    
    % get band
    clear Ss
    for ll=1:numel(S)
      Ss(ll) = join(split(S(ll), plist('frequencies', freqs)));
    end
    
    % get mean in band
    fprintf('* computing mean in band [%f %f]\n', freqs(1), freqs(2));
    Ss = Ss.select(1:pl.find('bins'):Ss.len);
    if pl.find('total power')
      df = Ss(1).x(2) - Ss(1).x(1);
      Smean = sum(Ss).* ao(df, plist('yunits', 'Hz'));
    else
      Smean = mean(Ss);
    end
        
    fprintf('* generating time-series...\n');
    out(jj) = convert(join(Smean), plist('action', 'to tsdata'));
    out(jj).setX(segTimes);
    out(jj).setT0(object.t0 + object.x(1));
    out(jj).toSI;
    out(jj).setName(sprintf('%s [%0.2g %0.2g] Hz', object.name, freqs(1), freqs(2)));
    
    if ~isempty(object.plotinfo)
      out(jj).plotinfo = copy(object.plotinfo, 1);
    end
    
    out(jj).addHistory(getInfo('None'), pl,  obj_invars(jj), object.hist);
    
  end % loop over analysis objects
  
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
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  % Create empty plsit
  pl = copy(ao.getInfo('psd').plists, 1);
  
  % frequencies
  p = param(...
    {'frequencies', 'The frequency interval over which to average. Specify a vector [f1 f2].'},...
    paramValue.DOUBLE_VALUE([0 inf])...
    );
  p.addAlternativeKey('freqs');
  p.addAlternativeKey('f');
  pl.append(p);

  % scale
  p = param(...
    {'total power', 'Scale to be total power (mulitply by bandwidth).'},...
    paramValue.FALSE_TRUE...
    );
  p.addAlternativeKey('tot pwr');
  pl.append(p);
  
  % skip bins
  p = param(...
    {'bins', 'Select every nth bin in the averaging.'},...
    paramValue.DOUBLE_VALUE(1) ...
    );
  pl.append(p);
  
end

% END
