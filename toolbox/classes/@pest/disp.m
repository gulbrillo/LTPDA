% DISP overloads display functionality for pest objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for pest objects.
%
% CALL:        txt  = disp(pest)
%
% INPUT:       pest - pest object
%
% OUTPUT:      txt  - cell array with strings to display the pest object
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'disp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  objs = utils.helper.collect_objects(varargin(:), 'pest');
  
  txt = {};
  
  % Print emtpy object
  if isempty(objs)
    hdr = sprintf('------ %s -------', class(objs));
    ftr(1:length(hdr)) = '-';
    txt = [txt; {hdr}];
    txt = [txt; sprintf('empty-object [%d,%d]',size(objs))];
    txt = [txt; {ftr}];
  end
  
  for jj=1:numel(objs)
    
    obj = objs(jj);
    nParams = max(numel(obj.names), numel(obj.y));
    
    banner = sprintf('---- pest %d ----', jj);
    txt = [txt; {banner}];
    
    % display
    txt = [txt; {sprintf('       name: %s', obj.name)}];
    txt = [txt; {sprintf(' parameters:')}];
    for pp=1:nParams
      txt = [txt; {sprintf('             %s', getParameterString(obj, pp))}];
    end
    txt = [txt; {' '}];
    txt = [txt; {sprintf('        pdf: %s', utils.helper.val2str(obj.pdf))}];
    txt = [txt; {sprintf('        cov: %s', utils.helper.val2str(obj.cov))}];
    txt = [txt; {sprintf('       corr: %s', utils.helper.val2str(obj.corr))}];
    txt = [txt; {sprintf('      chain: %dx%d', size(obj.chain, 1), size(obj.chain, 2))}];
    txt = [txt; {sprintf('       chi2: %s', utils.helper.val2str(obj.chi2))}];
    txt = [txt; {sprintf('        dof: %s', num2str(obj.dof))}];
    txt = [txt; {sprintf('     models: %s', char(obj.models))}];
    txt = [txt; {sprintf('description: %s', utils.prog.cutString(obj.description, 120))}];
    txt = [txt; {sprintf('       UUID: %s', obj.UUID)}];
    banner_end(1:length(banner)) = '-';
    txt = [txt; {banner_end}];
  end
  
  if nargout == 0
    for jj=1:length(txt)
      disp(txt{jj});
    end
  else
    varargout{1} = txt;
  end
  
end

function s = getParameterString(obj, idx)
  maxParamName = max(cellfun(@length, obj.names));
  if numel(obj.names) >= idx
    s = sprintf('%1$*2$s:',obj.names{idx}, maxParamName);
  else
    s = sprintf('%1$*2$s:', '???', maxParamName);
  end
  
  % Add Value for the parameter if exists
  if numel(obj.y) >= idx
    s = sprintf('%s %15.8g', s, obj.y(idx));
  end
  % Add Error for the parameter if exists
  if numel(obj.dy) >= idx
    s = sprintf('%s +- %15.8g', s, obj.dy(idx));
  end
  % Add Error for the parameter if exists
  if numel(obj.yunits) >= idx
    s = sprintf('%s %s', s, char(obj.yunits(idx)));
  end
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
  ii.setModifier(false);
  ii.setOutmin(0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function plo = buildplist()
  plo = plist.EMPTY_PLIST;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    mat2valstr
%
% DESCRIPTION: Convert a matrix into a string with the maximum size of 40 characters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = mat2valstr(val)
  str = mat2str(val,5);
  if numel(str) > 40
    str = [str(1:40), ' ...'];
  end
end


