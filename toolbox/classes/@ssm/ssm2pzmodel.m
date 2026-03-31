% SSM2PZMODEL converts a time-continuous statespace model object to a pzmodel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SSM2PZMODEL converts a time-continuous statespace model
%              object to a pzmodel
%
% CALL:
%              >> pzms = ssm2pzmodel(ssm, pl);
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
%            pzms - an array of pzmodels objects if the timestep is zero
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'ssm2pzmodel')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ssm2pzmodel(varargin)
  
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
  pl = combine(pl, getDefaultPlist);
  
  if numel(sys) ~= 1
    error('### Input (only) one SSM object.');
  end
  
  %% begin function body
  
  %% convert to double
  % Convert to double arrays
  [A,B,C,D,Ts,inputvarnames,ssvarnames,outputvarnames, inputunit, ssunit, outputunit] =...
    double(sys, pl);
  
  Ninputs_out  = numel(inputvarnames);
  Noutputs_out = numel(outputvarnames);
  
  if Ts > 0
    error('ssm should be time continuous, use ssm2miir instead')
  end
  %% convert to pzm
  pzm_out = pzmodel.initObjectWithSize(Noutputs_out, Ninputs_out);
  for ii=1:Ninputs_out
    for oo=1:Noutputs_out
      [b,a] = ss2tf(A,B(:,ii),C(oo,:),D(oo, ii));
      % computing poles and zeros
      pa = roots(a);
      if isempty(pa)
        p = pz.initObjectWithSize(1,0);
        gainP = 1;
      else
        [p, gainP] = roots2poly(pa);
      end
      zb = roots(b);
      if isempty(zb)
        z = pz.initObjectWithSize(1,0);
        gainZ = 1;
      else
        [z, gainZ] = roots2poly(zb);
      end
      % computing gain coefficient
      apos = a(a~=0);
      bpos = b(b~=0);
      if ~isempty(bpos) && ~isempty(apos)
        Gain = bpos(1)/apos(1);
      elseif ~isempty(apos)
        Gain = 1/apos(1);
      elseif ~isempty(bpos) % NB theoretically impossible to reach : SSM can't have more zeros than poles
        Gain = bpos(1);
      else
        Gain = 0;
      end
      Gain = Gain / gainP * gainZ;
      % constructing output pzm
      name = [sys.name,'_',num2str(ii),':',num2str(oo)];
      pzm_out(oo,ii) = pzmodel(plist(...
        'gain', Gain, 'poles', p, 'zeros', z, 'name', name, ...
        'inunits', inputunit(ii),  'ounits' ,outputunit(oo) ));
      pzm_out(oo,ii).addHistory(ssm.getInfo(mfilename), pl , ssm_invars, sys.hist);
    end
  end
  if nargout == numel(pzm_out)
    for ii = 1:numel(pzm_out)
      varargout{ii} = pzm_out(ii);
    end
  else
    varargout{1} = pzm_out;
  end
end


function varargout = roots2poly(roots)
  poly = pz.initObjectWithSize(1,0);
  i=1;
  gain = 1;
  while i < length(roots)+1
    if isreal(roots(i))
      poly = [poly pz(-roots(i)/2/pi)]; %#ok<AGROW>
      gain = gain * abs(roots(i));
      i = i+1;
    else
      f = norm(roots(i)/2/pi);%*sign(real(roots(i)));
      Q = norm(roots(i))/abs(2*real(roots(i)));
      poly = [poly pz(f,Q)]; %#ok<AGROW>
      gain = gain * abs(roots(i))^2;
      i = i+2; %#ok<FXSET>
    end
  end
  varargout = {poly, gain};
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

