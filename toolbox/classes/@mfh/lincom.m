% LINCOM make a linear combination of supplied models objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LINCOM makes a linear combination of the input analysis
% objects
%
% CALL:        
%              b = lincom(m1, m2, m3, ..., mN, c)
%              b = lincom(m1, m2, m3, ..., mN, pest)
%              b = lincom([m1, m2, m3, ..., mN], [c1, c2, c3, ..., cN])
%              b = lincom(m1, m2, m3, ..., mN, pl)
%              b = lincom([m1, m2, m3, ..., aN], pl)
%
%
%              If no plist is specified, the last object should be:
%               + an AO of type cdata with the coefficients inside OR
%               + a vector of AOs of type cdata with individual coefficients OR
%               + a pest object with the coefficients
%
% INPUTS:      mi - a list of mfh objects which can be evaluated
%              c  - analysis object OR pest object with coefficient(s)
%              pl - input parameter list
%
% OUTPUTS:     b  - output analysis object
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'lincom')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = lincom(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  if nargout == 0
    error('### lincom cannot be used as a modifier. Please give an output variable.');
  end
  
  %%% Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin
    in_names{ii} = inputname(ii);
  end
    
  % Collect all AOs and plists
  [models, m_invars, rest] = utils.helper.collect_objects(varargin(:), 'mfh', in_names);
  [ps, ps_invars, rest]    = utils.helper.collect_objects(rest(:), 'pest', in_names);
  pls                      = utils.helper.collect_objects(rest(:), 'plist', in_names);

  % Combine input PLIST with default PLIST
  usepl = applyDefaults(getDefaultPlist(), pls);
  
  % Evaluate each model
  data = ao.initObjectWithSize(1, numel(models));
  for mm = 1:numel(models)
    model = models.index(mm);
    data(mm) = model.eval();
    data(mm).setName(model.name);
  end
  
  % pass results to ao/lincom
  b = lincom(data, ps, usepl);  
  
  %%% Add History
  if ~isempty(ps)
    psHist = ps.hist;
  else
    psHist = [];
  end
  
  b.addHistory(getInfo('None'), usepl, [m_invars ps_invars], [models.hist psHist]);
  
  % Set output
  varargout{1} = b;
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
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
  
  pl = ao.getInfo('lincom').plists;
  
end
% END


