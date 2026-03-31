% SSM2SS converts a statespace model object to a MATLAB statespace object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SSM2SS converts a statespace model object to a MATLAB statespace object.
%
% CALL:        Convert a statespace model object to a MATLAB statespace object.
%              >> ss = ssm2ss(ssm, pl);
%
% ssm -     ssm object
% plist with parameters 'inputs', 'states' and 'outputs' to indicate which
% inputs, states and outputs variables are taken in account. This requires
% proper variable naming. If a variable called appears more that once it
% will be used once only.
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'ssm2ss')">Parameters Description</a>
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ssm2ss(varargin)
  
  %% starting initial checks
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  [obj, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  %% begin function body
  if ~obj.isnumerical
    error('system should be numeric')
  end
  if nargout == numel(obj)
    for ii = 1:numel(obj)
      [A,B,C,D,Ts,inputvarnames,ssvarnames, outputvarnames] = double(obj(ii), pl);
      sys = ss(A,B,C,D,Ts);
      sys.StateName = ssvarnames;
      sys.InputName = inputvarnames;
      sys.OutputName = outputvarnames;
      sys.Notes = obj.description;
      sys.Name = obj.name;
      varargout{ii} = sys;
    end
  else
    [A,B,C,D,Ts,inputvarnames,ssvarnames, outputvarnames] = double(obj, pl);
    sys = ss(A,B,C,D,Ts);
    sys.StateName = ssvarnames;
    sys.InputName = inputvarnames;
    sys.OutputName = outputvarnames;
    sys.Notes = obj.description;
    sys.Name = obj.name;
    varargout{1} = sys;
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.converter, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  pl = plist();
  
  p = param({'inputs', ['Specify the inputs. Give one of:<ul>'...
                        '<li>A cell-array of input port names.</li>'...
                        '<li>A cell-array of logical arrays specifying which input ports to use for each input block.</li>'...
                        '<li>A cell-array of double values specifying which input ports to use for each input block.<li>'...
                        '<li>The string ''ALL'' to use all inputs.']}, paramValue.STRING_VALUE('ALL'));
  pl.append(p);
  
  p = param({'states', 'Specify the states. Specify the states as for the ''inputs'' parameter.'}, paramValue.STRING_VALUE('ALL'));
  pl.append(p);
  
  p = param({'outputs', 'Specify the outputs. Specify the outputs as for the ''inputs'' parameter.'}, paramValue.STRING_VALUE('ALL'));
  pl.append(p);
end




