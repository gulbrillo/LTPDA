% LINCOM make a linear combination of objects within the collection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LINCOM makes a linear combination of the objects within the
% collection.
% 
% The method extracts the objects from the collection and calls the lincom
% method of the appropriate class. If no lincom method exists for the class
% of the inner objects, an error will result. Unpredicatable results will
% be achieved if the inner objects are of different classes.
%
% CALL:        b = lincom(collection, pest)
%              b = lincom(c1, c2, ... , pest)
%              b = lincom([c1 c2], plist)
%
%
%              If no plist is specified, the last object should be:
%               + an AO of type cdata with the coefficients inside OR
%               + a vector of AOs of type cdata with individual coefficients OR
%               + a pest object with the coefficients
%
% INPUTS:      ai - a list of analysis objects of the same type
%              c  - analysis object OR pest object with coefficient(s)
%              pl - input parameter list
%
% OUTPUTS:     b  - output collection of AOs, one per input collection
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'lincom')">Parameters Description</a>
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
  [colls, c_invars, rest] = utils.helper.collect_objects(varargin(:), 'collection', in_names);
  [ps, ps_invars, rest] = utils.helper.collect_objects(rest(:), 'pest', in_names);
  pl                    = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % Combine input PLIST with default PLIST
  usepl = applyDefaults(getDefaultPlist(), pl);
  
  % Check inputs
  if numel(ps) > 1
    error('### This method supports only one PEST object.')
  end
  
  % copy inputs
  b = copy(colls, 1);
  
  % get data
  out = ao.initObjectWithSize(1, numel(b));
  outname = '(';
  for cc=1:numel(b)
    
    objs = [b(cc).objs{:}];

    % call lincom
    out(cc) = lincom(objs, ps, pl);
    if ~isempty(b(cc).name)
      out(cc).setName(b(cc).name);
    end
    outname = [outname b(cc).name ', '];
  end
 
  outname = outname(1:end-2);
  outname = [outname ')'];
  
  % output collection
  c = collection(out);
  c.setName(outname);
  
  %%% Add History
  if ~isempty(ps)
    psHist = ps.hist;
  else
    psHist = [];
  end
  
  c.addHistory(getInfo('None'), usepl, [c_invars ps_invars], [colls.hist psHist]);
  
  % Set output
  varargout{1} = c;
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


