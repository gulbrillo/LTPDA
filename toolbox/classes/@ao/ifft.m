% IFFT overloads the ifft operator for Analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: IFFT overloads the ifft operator for Analysis objects.
%
% CALL:        b = ifft(a, pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'ifft')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ifft(varargin)

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

  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  % two-sided or one?
  type    = find_core(pl, 'type');
  
  % scale?
  scale = utils.prog.yes2true(find_core(pl, 'scale'));

  % Check input analysis object
  for jj = 1:numel(bs)
    
    % call core method of the fft
    bs(jj).ifft_core(type);
    if scale
        bs(jj) = bs(jj)./ao(plist('vals',1/as(jj).data.fs,'yunits','Hz^-1'));
        bs(jj).simplifyYunits();
    end
    % Set name
    bs(jj).name = sprintf('ifft(%s)', ao_invars{jj});    
    % Add history
    bs(jj).addHistory(getInfo('None'), pl, ao_invars, bs(jj).hist);
    
  end

  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
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
  
  % Type
  p = param({'type', 'Assume the data is symmetric or nonsymmetric.'}, {1, {'symmetric', 'nonsymmetric'}, paramValue.SINGLE});
  pl.append(p);
  
  % Scale by sample rate?
  p = param({'scale',['set to ''true'' to scale FFT by sampling rate to match '...
      'amplitude in continuous domain. Only applicable to data with sampel rates.']},...
      paramValue.FALSE_TRUE);  
  pl.append(p);
    
end

