% BODECST makes a bodecst plot from the given inputs to outputs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: BODECST makes a bodecst plot from the given inputs to outputs.
%
% CALL:   as = bodecst(sys, pl)
%         as = bodecst(sys, 'key1', 'option1')
%
% INPUTS:
%         'sys' - ssm object
%         'pl'  - plist of options
%
% OUTPUTS:
%
%        'as' - array of output AOs containing the requested responses.
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'bodecst')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = bodecst(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;
  
  utils.helper.msg(utils.const.msg.PROC3, ['running ', mfilename]);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [system, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  
  % Apply default plist
  pl = applyDefaults(getDefaultPlist(), varargin{:});
  
  % retrieving system's infos
  if numel(system)~=1
    error('we should have only one ssm and one plist object as an input')
  end
  if ~callerIsMethod
    inhist  = system.hist;
    if ~system.isStable
      error('input ssm is not stable!')
    end
  end
  if (system.isnumerical == 0)
    warning(['The system ' system.name ' is symbolic. The system is made numeric for bode calculation.'])
    sys = copy(system,1);
    sys.keepParameters;
  else
    sys = system;
  end
  
  % Compute frequency vector
  f = pl.find('f');
  if isempty(f)
    % finding "f2"
    if isempty(pl.find('f2'))
      if sys.timestep>0
        f2 = 0.5/sys.timestep;
      else
        f2 = 1;
      end
    else
      f2 = pl.find('f2');
    end
    % finding "f1"
    if isempty(pl.find('f1'))
      f1 = f2*1e-5;
    else
      f1 = pl.find('f1');
    end
    nf = pl.find('nf');
    scale = pl.find('scale');
    % building "f" vector
    switch lower(scale)
      case 'log'
        f = logspace(log10(f1), log10(f2), nf);
      case 'lin'
        f = linspace(f1, f2, nf);
      otherwise
        error('### Unknown scale option');
    end
  end
  
  % Is the f vector in an AO?
  if isa(f, 'ao') && (isa(f.data, 'fsdata') || isa(f.data, 'xydata'))
    f = f.x;
  end
  
  % Compute omega
  w = 2*pi*f;
  
  if find(pl, 'reorganize')
    reorgPlist = ssm.getInfo('reorganize', 'for bode').plists;
    sys = reorganize(sys, subset(pl.pset('set', 'for bode'), reorgPlist.getKeys));
  end
  
  % getting system's i/o sizes
  timestep = sys.timestep;
  fs      = 1/timestep;
  
  inputSizes = sys.inputsizes;
  outputSizes = sys.outputsizes;
  
  Nin = inputSizes(1);
  NstatesOut = outputSizes(1);
  NoutputsOut = outputSizes(2);
  
  A = sys.amats{1,1};
  Coutputs = sys.cmats{2,1};
  Cstates  = sys.cmats{1,1};
  B     = sys.bmats{1,1};
  D     = sys.dmats{2,1};
  Dstates = zeros(size(Cstates,1), size(D,2));
  
  % bode computation
  sys_ss = ss(A, B, [Cstates; Coutputs], [Dstates; D], timestep);
  [mag,phase]  = bode(sys_ss, w);
  resps = mag.*(cos(phase*pi/180) + 1i.*sin(phase*pi/180));
  
  % build AO
  
  myinfo  = getInfo('None');
  isysStr = sys.name;
  ao_out = ao.initObjectWithSize(NstatesOut+NoutputsOut, Nin);
  myInfo = getInfo('None');
  
  for ii=1:Nin
    for oo=1:NstatesOut
      ao_out(oo,ii).setData(fsdata(f, squeeze(resps(oo,ii,:)), fs));
      if ~ callerIsMethod
        ao_out(oo,ii).setName( [sys.inputs(1).ports(ii).name '-->' sys.outputs(1).ports(oo).name]);
        ao_out(oo,ii).setXunits(unit.Hz);
        ao_out(oo,ii).setYunits( simplify(sys.outputs(1).ports(oo).units / sys.inputs(1).ports(ii).units));
        ao_out(oo,ii).setDescription(...
          ['Bode of ' isysStr, ' from ',  sys.inputs(1).ports(ii).description,...
          ' to ' sys.outputs(1).ports(oo).description]);
        
        ao_out(oo,ii).addHistory(myInfo, pl, ssm_invars, inhist );
      end
    end
    for oo=1:NoutputsOut
      ao_out(NstatesOut+oo,ii).setData(fsdata(f, squeeze(resps(NstatesOut+oo,ii,:)), fs));
      if ~ callerIsMethod
        ao_out(NstatesOut+oo,ii).setName( [sys.inputs(1).ports(ii).name '-->' sys.outputs(2).ports(oo).name]);
        ao_out(NstatesOut+oo,ii).setXunits(unit.Hz);
        ao_out(NstatesOut+oo,ii).setYunits( simplify(sys.outputs(2).ports(oo).units / sys.inputs(1).ports(ii).units));
        ao_out(NstatesOut+oo,ii).setDescription(...
          ['Bode of ' isysStr, ' from ',  sys.inputs(1).ports(ii).description,...
          ' to ' sys.outputs(2).ports(oo).description]);
        ao_out(NstatesOut+oo,ii).addHistory(myinfo, pl, ssm_invars(1), inhist );
      end
    end
  end
  
  % construct output matrix object
  out = matrix(ao_out);
  if callerIsMethod
    % do nothing
  else
    out.addHistory(getInfo('None'), pl , ssm_invars(1), inhist );
  end
  
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
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  
  pl = copy(ssm.getInfo('reorganize', 'for bode').plists, 1);
  pl.remove('set');
  
  p = param({'f', 'A frequency vector (replaces f1, f2 and nf).'}, paramValue.EMPTY_DOUBLE) ;
  pl.append(p);
  
  p = param({'f2', 'The maximum frequency. Default is Nyquist or 1Hz.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'f1', 'The minimum frequency. Default is f2*1e-5.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'nf', 'The number of frequency bins.'}, paramValue.DOUBLE_VALUE(1000));
  pl.append(p);
  
  p = param({'scale', 'Distribute frequencies on a ''log'' or ''lin'' scale.'}, {1, {'log', 'lin'}, paramValue.SINGLE});
  pl.append(p);
  
  p = param({'reorganize', 'When set to 0, this means the ssm does not need be modified to match the requested i/o. Faster but dangerous!'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
end




