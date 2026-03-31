% IACF computes the inverse auto-correlation function from a spectrum.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: IACF computes the inverse auto-correlation function from a
%              spectrum.
%
%
% CALL:        out = obj.iacf(pl)
%              out = iacf(objs, pl)
%
% INPUTS:      pl      - a parameter list
%              obj(s)  - input ao object(s)
%
% OUTPUTS:     out - one xydata AO per input spectrum, containing sample
%                    indices in the x-field and the inverse autocorrelation
%                    values in the y field.
%
%
% Created 2013-02-20, M Hewitson
%     - adapted from code writen by Curt Cutler and Ira Thorpe.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'iacf')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = iacf(varargin)
  
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
  [aos, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [mdls, mdl_invars] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
  [pests, pest_invars] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
  
  %--- Decide on a deep copy or a modify.
  % If the no output arguments are specified, then we are modifying the
  % input objects. If output arguments are specified (nargout>0) then we
  % make a deep copy of the input objects and return modified versions of
  % those copies.
  
  names = {};
  objs = {};
  if ~isempty(aos)
    aosCopy   = copy(aos, nargout);
    for kk=1:numel(aosCopy), objs = [objs {aosCopy(kk)}]; names = [names ao_invars(kk)]; end
  end
  if ~isempty(mdls)
    mdlsCopy  = copy(mdls, nargout);
    for kk=1:numel(mdlsCopy), objs = [objs {mdlsCopy(kk)}]; names = [names mdl_invars(kk)]; end
  end
  if ~isempty(pests)
    pestsCopy = copy(pests, nargout);
    for kk=1:numel(pestsCopy), objs = [objs {pestsCopy(kk)}]; names = [names pest_invars(kk)]; end
  end
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Extract input parameters from the plist
  N = pl.find('samples');
  
  % Loop over input objects
  out = [];
  for jj = 1:numel(objs)
    
    % Process object jj
    object = objs{jj};
    
    % What kind of object are we dealing with?
    switch class(object)
      case 'ao'
        
        % this needs to be an fsdata AO
        if ~isa(object.data, 'fsdata')
          error('The iacf method requires an fsdata AO as input');
        end
        a = object;
        
        % rotate if necessary
        if size(a.y,2) > 1
          a = transpose(a);
        end
        
      case 'smodel'
        
        a = eval(object);
        
      case 'pest'
        
        a = eval(object);
        
      otherwise
        warning('The object [%s] of class [%s] can not be used to estimate an IACF', object.name, class(object));
    end
    
    x = a.x;
    y = a.y;
    
    % Now we have the data samples, so we can compute the inverse
    % correlation function
    invS = 1.0./y;
    y = invS';
    
    % convert PSD from single-sided to double-sided
    yl = fliplr(y);
    yr = y;
    yr(end) = [];
    yr(1) = [];
    y = 0.5*[yl yr];
    
    % Compute IFFT
    y = fftshift(y);
    y = ifft(y)*length(y)*(x(2)-x(1));
    
    % truncate
    if ~isempty(N)
      y= y(1:N);
    end
    
    % taper
    Ntap = double(pl.find('taper'));
    
    if Ntap > 0
      % force taper to be even
      if mod(Ntap,2), Ntap = Ntap+1; end
      w = cos(pi/2*(0:Ntap)/Ntap).^2;
      y(end-Ntap:end) = y(end-Ntap:end).*w;
    end
    
    ia = ao(plist(...
      'xvals', 0:length(y)-1, ...
      'yvals', 4*y, ...  % note the *4 is to make agreement to Curt's code as of 2013-06-10
      'xunits', 'Index', ...
      'yunits', simplify(a.yunits*unit('Hz'))));
    
    ia.name = sprintf('iacf(%s)', names{jj});
    ia.addHistory(getInfo('None'), pl,  names(jj), object.hist);
    
    % collect this for output
    out = [out ia];
    
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
  pl = plist();
  
  % samples
  p = param(...
    {'samples', 'The number of samples to truncate the correlation vector to. If empty, the full inverse correlation vector will be returned.'},...
    paramValue.EMPTY_DOUBLE...
    );
  pl.append(p);
  
  % taper
  p = param(...
    {'taper', 'The number of samples over which to taper the correlation prior to the end'},...
    0 ...
    );
  pl.append(p);
  
  
end

% END
