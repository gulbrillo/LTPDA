% DISPAYPROPERTIES displays the ssm model porperties.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISPAYPROPERTIES displays the ssm model porperties
%
% CALL:   displayProperties(sys , plist)
%
% INPUTS:
%         'sys'   - a ssm object to display properties
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'displayProperties')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = displayProperties(varargin)
  %% starting initial checks
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin,in_names{ii} = inputname(ii); end
  
  % Collect all SSMs and plists
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pli, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pli = pli.combine(plist(rest{:}));
  end
  pli = combine(pli, getDefaultPlist);
    
  if numel(sys)~=1
    error(['There should be only one input object to ' mfilename])
  end
  
  propName = pli.find('propName');
  
  switch upper(propName)
    case 'IOS'
      doIOS = true;
      doParameters = false;
    case 'PARAMETERS'
      doIOS = false;
      doParameters = true;
    otherwise
      doIOS = true;
      doParameters = true;
  end
  
  %% display inputs/states/outputs
  nInputs = sys.Ninputs;
  nStates = sys.Nstates;
  nOutputs = sys.Noutputs;
  
  if doIOS
    display(['MODEL INFORMATION OF : ' sys.name])
    display(sys.description)
    display(['===========INPUTS===========' ])
    display(['  number of blocks : ' num2str(nInputs) ])
    
    for i=1:nInputs
      blk = sys.inputs(i);
      display(['    input number ' num2str(i) ' : "' blk.name '"'])
      display(['    input description : ' blk.description ])
      display(['       number of ports : ' num2str(numel(blk.ports)) ])
      for j=1:numel(blk.ports)
        p = blk.ports(j);
        display(['       port number ' num2str(j) ' : ' p.name '  ' char(p.units) '  -  ' p.description ])
      end
    end
    display(['===========STATES===========' ])
    display(['  number of blocks : ' num2str(nStates) ])
    for i=1:nStates
      blk = sys.states(i);
      display(['    state ' num2str(i) ' : "' blk.name '"'])
      display(['      state description : ' blk.description ])
      display(['      state size : ' num2str(numel(blk.ports)) ])
      for j=1:numel(blk.ports)
        p = blk.ports(j);
        display(['       port number ' num2str(j) ' : ' p.name '  ' char(p.units) '  -  ' p.description ])
      end
    end
    display(['===========OUTPUTS===========' ])
    display(['  number of blocks : ' num2str(nOutputs) ])
    for i=1:nOutputs
      blk = sys.outputs(i);
      display(['    output ' num2str(i) ' : "' blk.name '"'])
      display(['      output description : ' blk.description ])
      display(['      output size : ' num2str(numel(blk.ports)) ])
      for j=1:numel(blk.ports)
        p = blk.ports(j);
        display(['       port number ' num2str(j) ' : ' p.name '  ' char(p.units) '  -  ' p.description ])
      end
    end
  end
  %% display parameters
  if doParameters
    p1 = sys.params.params;
    p2 = sys.numparams.params;
    display(['===========MODEL INFORMATION OF : ' sys.name '==========='])
    display(sys.description)
    display(['Number of symbolic parameters : ' num2str(sys.params.nparams)]);
    for i = 1:numel(p1)
      pv = p1(i).val;
      if ~isempty(pv.property) && ~isempty(pv.property.units)
        display([ '      sym. parameter number ' num2str(i) ' : ' p1(i).key ' = ' num2str(pv.options{pv.valIndex}) '  ' char(pv.property.units) '  -  ' p1(i).desc]);
      else
        display([ '      sym. parameter number ' num2str(i) ' : ' p1(i).key ' = ' num2str(pv.options{pv.valIndex}) '  -  ' p1(i).desc]);
      end
    end
    display(['Number of numerical parameters : ' num2str(sys.numparams.nparams)]);
    for i = 1:numel(p2)
      pv = p2(i).val;
      if ~isempty(pv.property) && ~isempty(pv.property.units)
        display([ '      num. parameter number ' num2str(i) ' : ' p2(i).key ' = ' num2str(pv.options{pv.valIndex}) '  ' char(pv.property.units) '  -  ' p2(i).desc]);
      else
        display([ '      num. parameter number ' num2str(i) ' : ' p2(i).key ' = ' num2str(pv.options{pv.valIndex}) '  -  ' p2(i).desc]);
      end
    end
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  pl = plist();
  % plist
  p = param({'propName','Choose to display all, or only block and port data, or only parameter data.'},...
    {1, {'ALL', 'ISO' , 'parameters'}, paramValue.SINGLE});
  pl.append(p);
end

