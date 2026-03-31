% TOMFIR approximates a pole/zero model with an FIR filter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TOMFIR approximates a pole/zero model with an FIR filter.
%              The response of the pzmodel is computed using pzmodel/resp with
%              the additional input parameter of param('f1', 0). The final
%              frequency in the response is set automatically from the
%              pzmodel/resp function if not specified as an input. This upper
%              frequency is then taken as the Nyquist frequency and the
%              sample rate of the corresponding fsdata AO is set accordingly.
%              The function then calls mfir() with the new fsdata AO as input.
%              The result is an FIR filter designed to have a magnitude response
%              equal to the magnitude response of the pole/zero model. The filter
%              has linear phase and the phase of the pzmodel is ignored.
%
% CALL:        f = tomfir(pzm)
%              f = tomfir(pzm, plist)
%
% <a href="matlab:utils.helper.displayMethodInfo('pzmodel', 'tomfir')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = tomfir(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check output arguments number
  if nargout == 0
    error('### pzmodel/tomfir cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [pzms, pzm_invars] = utils.helper.collect_objects(varargin(:), 'pzmodel', in_names);
  pls  = utils.helper.collect_objects(varargin(:), 'plist');
  
  % Store inhists to suppress intermediate history steps
  inhists = [pzms(:).hist];
  
  % Get default parameters
  pl = applyDefaults(getDefaultPlist, pls);
  
  % Decide on a deep copy or a modify
  pzms = copy(pzms, nargout);
  
  % check design parameters
  fs = find_core(pl, 'fs');
  f1 = find_core(pl, 'f1');
  f2 = find_core(pl, 'f2');
  nf = find_core(pl, 'nf');
  f2 = fs/2;
  
  r = resp(pzms, plist('f1', f1, 'f2', f2, 'nf', nf, 'scale', 'lin'));
  
  % Set fs
  r.setFs(fs);
  
  % compute filter
  for kk = 1:numel(r)
    % throws a warning if the model has a delay
    if(pzms(kk).delay~=0)
      disp('!!!  PZmodel delay is not used in the discretization')
    end
    % Compute mfir filter
    f(kk) = mfir(r(kk));
    
    if ~callerIsMethod
      % create new history for the case that the method isn't called from
      % a LTPDA method
      f(kk).addHistory(getInfo, pl, pzm_invars(kk), inhists(kk));
    end
  end
  
  % Reshape the output to the shape of the input
  f = reshape(f, size(r));
  
  % Set output
  if nargout == numel(f)
    % List of outputs
    for ii = 1:numel(f)
      varargout{ii} = f(ii);
    end
  else
    % Single output
    varargout{1} = f;
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  ii.setModifier(false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function plo = buildplist()
  fs = 10;
  f2 = fs/2;
  
  plo = plist();
  
  % FS
  p = param({'fs', 'Frequency of the fir filter.'}, paramValue.DOUBLE_VALUE(fs));
  plo.append(p);
  
  % F1
  p = param({'f1','Start frequency.'}, paramValue.DOUBLE_VALUE(0));
  plo.append(p);
  
  % F2
  p = param({'f2','Stop frequency.'}, paramValue.DOUBLE_VALUE(f2));
  plo.append(p);
  
  % Nf
  p = param({'nf','Number of evaluation frequencies.'}, paramValue.DOUBLE_VALUE(1000));
  plo.append(p);
  
  % Scale
  p = param({'scale',['Spacing of frequencies:<ul>', ...
    '<li>''lin'' - Linear scale.</li>', ...
    '<li>''log'' - Logarithmic scale.</li></ul>']}, {1, {'lin', 'log'} paramValue.SINGLE});
  plo.append(p);
  
end

