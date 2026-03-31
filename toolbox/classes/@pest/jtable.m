% JTABLE display the parameters from PEST objects in a java table.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   JTABLE display the parameters from PEST objects in a java table.
%
% CALL:          jtable(pest)
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'jtable')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = jtable(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all PEST objects
  [ps, ps_invars] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
  
  % Create empty java table
  jTable = datatable.TableForm();
  
  % Get PEST names from the object or from the input variable name
  pestNames = {ps.name};
  emptyIdx = cellfun(@isempty, pestNames);
  pestNames(emptyIdx) = ps_invars(emptyIdx);
  
  % Get all parameter names
  allParamNames = unique([ps.names]);
  
  % Create title for the PEST objects
  jTable.getDataTable.getModel.getTitle.add(java.lang.String); % Colum for the parameters
  % Add Columns for each PEST object
  for ii=1:numel(pestNames)
    jTable.getDataTable.getModel.getTitle.add(pestNames{ii});
    jTable.getDataTable.getModel.getTitle.add(sprintf('%s (error)', pestNames{ii}));
  end
  
  % Add data Columns
  jTable.getDataTable.getModel.addColumnData(allParamNames);
  
  for ii=1:numel(ps)
    val = cell(size(allParamNames));
    dval = cell(size(allParamNames));
    idx = getIndexOfParams(allParamNames, ps(ii).names);
    val(idx)  = num2cell(ps(ii).y);
    dval(idx) = num2cell(ps(ii).dy);
    jTable.getDataTable.getModel.addColumnData(val);
    jTable.getDataTable.getModel.addColumnData(dval);
  end
  
  jTable.setSize(java.awt.Dimension(900, 300));
  jTable.setVisible(true);
  
end

function idx = getIndexOfParams(all, subset)
  idx = [];
  for ii=1:numel(subset)
    idx = [idx find(strcmp(all, subset{ii}))];
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
  ii.setModifier(false);
  ii.setOutmin(0);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist();
end


