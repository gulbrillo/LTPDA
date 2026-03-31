% <METHOD_UPPER> performs actions on <CLASS> objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: <METHOD_UPPER> performs actions on <class> objects.
%
%
% CALL:        out = obj.<METHOD>(pl)
%              out = <METHOD>(objs, pl)
%
% INPUTS:      pl      - a parameter list
%              obj(s)  - input <CLASS> object(s)
%
% OUTPUTS:     out - some output.
% 
% <a href="matlab:utils.helper.displayMethodInfo('<CLASS>', '<METHOD>')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = <METHOD>(varargin)
  
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
  
  % Collect all objects of class <CLASS>
  [objs, obj_invars] = utils.helper.collect_objects(varargin(:), '<CLASS>', in_names);
  
  %--- Decide on a deep copy or a modify.
  % If the no output arguments are specified, then we are modifying the
  % input objects. If output arguments are specified (nargout>0) then we
  % make a deep copy of the input objects and return modified versions of
  % those copies.
  objsCopy = copy(objs, nargout);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Extract input parameters from the plist
  val = pl.find('param1');
  
  % Loop over input objects
  for jj = 1 : numel(objsCopy)
    % Process object jj
    object = objsCopy(jj);
      
    % Do something to the objects. Here we just change the name of the
    % object using the plist parameter value as an example.
    object.name = sprintf('<METHOD> - %g', val);
    
    % Add history
    if ~callerIsMethod
      object.addHistory(getInfo('None'), pl, obj_invars(jj), object.hist);
    end
  end % loop over analysis objects
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, objsCopy);
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
  ii = minfo(mfilename, mfilename('class'), '<MODULE>', utils.const.categories.sigproc, '', sets, pl);
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
  
  % My Parameter 1
  p = param(...
    {'Param1', 'A description of this parameter'},...
    paramValue.DOUBLE_VALUE(1)...
    );
  pl.append(p);

  % SOME OTHER PARAMETER EXAMPLES
  
%     % Scale
%   p = param({'Scale',['The scaling of output. Choose from:<ul>', ...
%     '<li>PSD - Power Spectral Density</li>', ...
%     '<li>ASD - Amplitude (linear) Spectral Density</li>', ...
%     '<li>PS  - Power Spectrum</li>', ...
%     '<li>AS  - Amplitude (linear) Spectrum</li></ul>']}, {1, {'PSD', 'ASD', 'PS', 'AS'}, paramValue.SINGLE});
%   pl.append(p);

%   % GDoff
%   p = param({'GDOFF', 'Switch off correction for group delay.'}, paramValue.TRUE_FALSE);
%   p.val.setValIndex(2);
%   pl.append(p);

    
end

% END
