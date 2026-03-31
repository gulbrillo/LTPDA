% TOLATEX display the parameters from PEST objects in a LaTeX table.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   TABLE display the parameters from PEST objects in a LaTeX table.
%
% The name of the pest will be used to generate the label for the table.
% The description of the pest will become the caption.
%
% CALL:          table(pest)
%
%                      toLaTeX(pest)
%                txt = toLaTeX(pest)
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'toLaTeX')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = toLaTeX(varargin)
  
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
  [ps, ps_invars, rest] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
  [pls,  invars, rest]     = utils.helper.collect_objects(rest(:), 'plist');
  
  % Make copies or handles to inputs
  ps   = copy(ps, nargout);

  % combine plists
  pl = applyDefaults(getDefaultPlist(), pls);
  
  % Fill the table data with the values
  txt = {};
  for ii=1:numel(ps)
    str = '';
    str = [str sprintf('\\begin{table}[htp]\n')];
    str = [str sprintf('\\def\\arraystretch{%f}\n', pl.find('spacing'))];
    str = [str sprintf('\\begin{center}\n')];
    
    colstr = repmat('|c', 1, numel(ps(ii).y));
    
    str = [str sprintf('\\begin{tabular}{%s|} \\hline\n', colstr)];
    str = [str sprintf('Parameter & Value & Error & Units \\\\ \\hline\n')];
    for pp=1:numel(ps(ii).y)
      y = ps(ii).y(pp);
      if ~isempty(ps(ii).dy)
        dy = ps(ii).dy(pp);
      else
        dy = nan;
      end
      ustr = tolabel(ps(ii).yunits(pp));
      ustr = strrep(ustr{1}, '$$', '$');
      str = [str sprintf('$%s$    &    $%s$ & $%s$      & %s \\\\ \\hline\n', ...
        ps(ii).names{pp}, utils.helper.obj2tex(y), utils.helper.obj2tex(dy), ustr)];
    end
    str = [str sprintf('\\end{tabular}\n')];
    str = [str sprintf('\\end{center}\n')];
    str = [str sprintf('\\caption{%s}\n', ps(ii).description)];
    str = [str sprintf('\\label{tab:%s}\n', utils.helper.genvarname(ps(ii).name))];
    str = [str sprintf('\\end{table}\n')];
    
    txt = [txt {str}];
  end
  
  
  % Print the cell-array
  % return outputs if requested (useful for autoreporter)
  if nargout == 1
    varargout{1} = txt;
  else
    for kk=1:numel(txt)
      fprintf('%s\n', txt{kk});
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
  
  % spacing
  p = param({'spacing', 'Control the spacing of cells in the table.'}, paramValue.DOUBLE_VALUE(2));
  pl.append(p);

  
end


