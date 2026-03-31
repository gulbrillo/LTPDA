% SSM2MIIR converts a statespace model object to a miir object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SSM2MIIR converts a statespace model object to an miir object.
%
% CALL:
%              >> filts = ssm2miir(ssm, pl);
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
% OUTPUT:
%
%            filts - an array of miir filter objects
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'ssm2miir')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ssm2miir(varargin)
  
  %% starting initial checks
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
  pl = combine(pl, getDefaultPlist);
  
  if numel(sys) ~= 1
    error('### Input (only) one SSM object.');
  end
  
  %% begin function body
  % minimal Realization
  sys.sMinReal();
  
  %% convert to double
  % Convert to double arrays
  [A,B,C,D,Ts,inputvarnames,ssvarnames,outputvarnames, inputunit, ssunit, outputunit] =...
    double(sys, pl);
  
  Ninputs_out  = numel(inputvarnames);
  Noutputs_out = numel(outputvarnames);
  
  if ~(Ts > 0)
    error('ssm should be time-discrete, use ssm2rational instead')
  end
  
  %% convert to miir
  miir_out = miir.initObjectWithSize(Noutputs_out, Ninputs_out);
  
  for ii=1:Ninputs_out
    for oo=1:Noutputs_out
      
      [a,b] = ss2tf(A,B(:,ii),C(oo,:),D(oo, ii ));
      name = [ssm_invars{1},' : ',inputvarnames{ii},' -> ',outputvarnames{oo}];
      pl = plist('inunits', inputunit(ii), 'ounits' ,outputunit(oo));
      if b==0
        m = miir(); % CASE TO DELETE???
      else
        data = plist('a', real(a), 'b', real(b),'fs', 1/sys.timestep);
        m = miir(data.combine( pl));
      end
      m.addHistory(ssm.getInfo(mfilename), pl , ssm_invars, sys.hist );
      m.name = name;
      miir_out(oo, ii) = m;
    end
  end
  if nargout == numel(miir_out)
    for ii = 1:numel(miir_out)
      varargout{ii} = miir_out(ii);
    end
  else
    varargout{1} = miir_out;
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

