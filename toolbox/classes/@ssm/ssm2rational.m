% SSM2RATIONAL converts a statespace model object to a rational frac. object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SSM2RATIONAL converts a statespace model object to
%              a rational fraction object.
%
% CALL:
%              >> rats = ssm2rational(ssm, pl);
%
% INPUT :
%
%           ssm     - a ssm object
%           pl      - a plist with parameters 'inputs', 'states' and
%                     'outputs' to indicate which inputs, states and output
%                     variables are taken in account. This requires proper
%                     variable naming. If a variable called appears more
%                     that once it will be used once only.
%
%
% OUTPUT:
%
%           rats - an array of rational fraction object
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'ssm2rational')">Parameters Description</a>
%
% IMPLEMENTATION NOT FINISHED!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ssm2rational(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  %% starting initial checks
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
  
  if numel(sys) ~= 1
    error('### Input (only) one SSM object.');
  end
  
  %% begin function body
  
  %% convert to double
  % Convert to double arrays
  [A,B,C,D,Ts,inputvarnames,ssvarnames,outputvarnames] = double(sys, pl);
  
  Ninputs_out  = numel(inputvarnames);
  Noutputs_out = numel(outputvarnames);
  
  if Ts > 0
    error('system should be time continuous. Use ssm2miir instead');
  else
    %% convert to pzm
    rational_out(Noutputs_out, Ninputs_out) = rational();
    for ii=1:Ninputs_out
      for oo=1:Noutputs_out
        sys_loc =ss( A,B(:,ii),C(oo,:),D(oo, ii ),Ts);
        sys_loc = minreal(sys_loc);
        [A_loc, B_loc, C_loc, D_loc]=ssdata(sys_loc);
        [b,a] = ss2tf(A_loc, B_loc, C_loc, D_loc);
        name = [ssm_invars{1},' : ',inputvarnames{ii},' -> ',outputvarnames{oo}];
        if isequal(b,0) || isequal(a,0)
          m = rational();
        else
          m = rational(real(b), real(a), 1/sys.timestep);
        end
        m.addHistory(ssm.getInfo(mfilename), pl , ssm_invars, sys.hist);
        m.name = name;
        rational_out(oo, ii) = m;
      end
    end
  end
  if nargout == numel(rational_out)
    for ii = 1:numel(rational_out)
      varargout{ii} = rational_out(ii);
    end
  else
    varargout{1} = rational_out;
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

