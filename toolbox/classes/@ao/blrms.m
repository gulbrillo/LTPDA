% BLRMS computes band-limited RMS trends of the input time-series.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: BLRMS computes band-limited RMS trends of the input time-series.
%
% CALL:        b = blrms(a, pl)
% 
% Inputs:
%           a - input time-series AOs
% Outputs:
%           b - an array of collection objects, one per input time-series AO.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'blrms')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = blrms(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);

  % Make copies or handles to inputs
  bs = copy(as, nargout);

  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  % Extract necessary parameters
  freqs = pl.find('f');
  bws  = pl.find('bandwidths');

  plotinfo.resetStyles;
  tsaos = [];
  for jj = 1:numel(bs)
    if ~isa(bs(jj).data, 'tsdata')
      warning('!!! The ao/blrms method can only be computed on input time-series. Skipping AO %s', ao_invars{jj});
    else
      tsaos = [tsaos bs(jj)];
    end
  end
    
  if numel(freqs) ~= numel(bws)
    error('Specify one bandwidth per frequency.');
  end
    
  % Loop over input AOs
  plotinfo.resetStyles;
  for jj = 1:numel(tsaos)
    
    % capture input history
    inhist = bs(jj).hist;
    
    % power
    obj = bs(jj);
    
    clear out;
    names = {};
    for kk=1:numel(freqs)
      
      % heterodyne
      qc = heterodyne(obj, plist('f0', freqs(kk), 'bw', bws(kk), 'quad', 'cos'));
      qs = heterodyne(obj, plist('f0', freqs(kk), 'bw', bws(kk), 'quad', 'sin'));
      out(kk) = sqrt(qc.^2 + qs.^2);
      names{kk} = sprintf('%s @ %0.2g', bs(jj).name, freqs(kk));
      out(kk).setName(names{kk});
    end
    
    % output collection
    c(jj) = collection(out);
    c(jj).setName(sprintf('blrms(%s)', bs(jj).name));
    
    % Add history
    c(jj).addHistory(getInfo('None'), pl, ao_invars(jj), inhist);
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, c);
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
  
  pl = plist();

  % segment length
  p = param({'frequencies', 'The array of frequencies around which to compute the band-limited RMS.'}, paramValue.EMPTY_DOUBLE);
  p.addAlternativeKey('f');
  pl.append(p);
  
  % bws
  p = param({'bandwidths', 'Specify the bandwidth for each frequency.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
                                    
end

% END
