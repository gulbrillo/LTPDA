% FROMDATAFILE Construct smodel object from filename AND parameter list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromDatafile
%
% DESCRIPTION: Construct smodel object from filename AND parameter list
%
% CALL:        a = fromFilenameAndPlist(a, pli)
%
% PARAMETER:   a:   empty ltpda-model-object
%              pli: plist-object (must contain the filename)
%
% FORMAT:      The text file must have the following format:
%
%              - Blank lines are ignored
%              - Lines starting with a hash (#) are ignored
%                (* see description part
%              - The first continuous comment block will be put into the
%                description field
%              - The values for the model are defined with some keywords
%              - Use only one line for a value
%              - A colon after a keyword can be optionally inserted
%              - The following keywords (inside the quotes) are mandatory
%                and must be at the beginning of a line.
%                'expr'   - the expression of the model
%                'params' - parameters which are used in the model
%                'values' - default values for the parameters
%                'xvar'   - X-variable
%              - The following keywords are optional
%                'xunits' - units of the x-axis
%                'yunits' - units of the y-axis
%                'xvals'  - values for the X-variable
%              - It is possible to read more than one model from a file.
%                Use for this the indeces behind the keywords. For example
%                expr(1,2): ...
%                expr(3) ...
%              - It is necessary that each mandatory keyword have an entry
%                for each index. If a keyword have only one entry then will
%                be this enty copied to all other models.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mdl = fromDatafile(mdlin, pli)
  
  utils.helper.msg(utils.const.msg.PROC1, 'constructing from filename and/or plist');
  
  % get ltpda-model info
  mi = smodel.getInfo('smodel', 'From ASCII File');
  
  % Get filename
  file_name = find_core(pli, 'filename');
  
  [pathstr, f_name, ext] = fileparts(file_name);
  
  %%%%%%%%%%   Get default parameter list   %%%%%%%%%%
  dpl = smodel.getDefaultPlist('From ASCII File');
  pl  = applyDefaults(dpl, pli);
  
  pl = pset(pl, 'filename', [f_name ext]);
  pl = pset(pl, 'filepath', pathstr);
  
  dxunits = pl.find_core('xunits');
  dyunits = pl.find_core('yunits');
  dxvals  = pl.find_core('xvals');
  ddesc   = pl.find_core('description');
  
  %%%%%%%%%%   read file   %%%%%%%%%%
  [fid,msg] = fopen (file_name, 'r');
  if (fid < 0)
    error ('### can not open file: %s \n### error msg: %s',file_name, msg);
  end
  
  firstCommentBlock = true;
  
  desc = '';
  expr = {};
  params = {};
  xvar = {};
  values = {};
  
  xvals  = {};
  xunits = {};
  yunits = {};
  
  while ~feof(fid)
    
    fline = fgetl(fid);
    fline = strtrim(fline);
    
    if isempty(fline)
      firstCommentBlock = isFirstCommentBlock(desc);
    elseif fline(1) == '#'
      if firstCommentBlock && ~isempty(strtrim(fline(2:end)))
        desc = [desc, strtrim(fline(2:end)), '\n'];
      end
      
    elseif strcmpi(fline(1:4), 'expr')
      firstCommentBlock = isFirstCommentBlock(desc);
      [i,j,txt] = parseLine(fline, 'expr');
      expr{i,j} = txt;
      
    elseif strcmpi(fline(1:6), 'params')
      firstCommentBlock = isFirstCommentBlock(desc);
      [i,j,txt] = parseLine(fline, 'params');
      params{i,j} = txt;
      
    elseif strcmpi(fline(1:4), 'xvar')
      firstCommentBlock = isFirstCommentBlock(desc);
      [i,j,txt] = parseLine(fline, 'xvar');
      xvar{i,j} = txt;
      
    elseif strcmpi(fline(1:6), 'values')
      firstCommentBlock = isFirstCommentBlock(desc);
      [i,j,txt] = parseLine(fline, 'values');
      values{i,j} = txt;
      
    elseif strcmpi(fline(1:5), 'xvals')
      firstCommentBlock = isFirstCommentBlock(desc);
      [i,j,txt] = parseLine(fline, 'xvals');
      xvals{i,j} = txt;
      
    elseif strcmpi(fline(1:6), 'xunits')
      firstCommentBlock = isFirstCommentBlock(desc);
      [i,j,txt] = parseLine(fline, 'xunits');
      xunits{i,j} = txt;
      
    elseif strcmpi(fline(1:6), 'yunits')
      firstCommentBlock = isFirstCommentBlock(desc);
      [i,j,txt] = parseLine(fline, 'yunits');
      yunits{i,j} = txt;
      
    end
    
  end
  fclose(fid);
  
  % Get maximum size of the smodel matrix
  maxi = max([size(expr,1), size(params,1), size(xvar,1), size(values,1), size(xvals,1), size(xunits,1), size(yunits,1)]);
  maxj = max([size(expr,2), size(params,2), size(xvar,2), size(values,2), size(xvals,2), size(xunits,2), size(yunits,2)]);
  
  % Make some plausibly checks
  %   1) Replicate the array to the maximum size of the used indices if the
  %      array have only one input.
  %   2) The array must have the same size as the used indices.
  if isempty(xunits)
    xunits = {dxunits};
  end
  if isempty(yunits)
    yunits = {dyunits};
  end
  if isempty(xvals)
    xvals = {dxvals};
  end
  if ~isempty(ddesc)
    desc = ddesc;
  end
  expr   = checkArray(expr, maxi, maxj);
  params = checkArray(params, maxi, maxj);
  xvar   = checkArray(xvar, maxi, maxj);
  values = checkArray(values, maxi, maxj);
  xvals  = checkArray(xvals, maxi, maxj);
  xunits = checkArray(xunits, maxi, maxj);
  yunits = checkArray(yunits, maxi, maxj);
  
  mdl = smodel.newarray([maxi, maxj]);
  
  % Check mandatory fields
  if isempty(expr) || isempty(params) || isempty(xvar) || isempty(values)
    error('### At least one of the mandatory fields (''expr'', ''params'', ''xvar'', ''values'') is empty.');
  end
  
  % Create Object
  for ii = 1:numel(mdl)
    
    % mandatory fields
    mdl(ii).expr   = expr{ii};
    mdl(ii).params = regexp(strtrim(params{ii}), ',', 'split');
    mdl(ii).xvar   = xvar{ii};
    mdl(ii).values = cellfun(@str2num, regexp(strtrim(values{ii}), ',', 'split'));
    
    % Optional fields
    if ~isempty(xvals)
      if ischar(xvals{ii})
        mdl(ii).xvals  = eval(xvals{ii});
      else
        mdl(ii).xvals  = xvals{ii};
      end
    end
    if ~isempty(xunits)
      mdl(ii).xunits = xunits{ii};
    end
    if ~isempty(yunits)
      mdl(ii).yunits = yunits{ii};
    end
    mdl(ii).description = desc(1:end-2); % remove the last break
    mdl(ii).addHistory(mi, pl, [], []);
    
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromDatafile
%
% DESCRIPTION:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = isFirstCommentBlock(desc)
  if isempty(desc)
    flag = true;
  else
    flag = false;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getIndex
%
% DESCRIPTION: Returns the index of the input string.
%              '(3,2)' -> i=3, j=2
%              '(3)'   -> i=3, default: j=1
%              '()'    -> default i=1, default: j=1
%              ''      -> default i=1, default: j=1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [i,j] = getIndex(token)
  ij = regexp(token, '\d*', 'match');
  if numel(ij) == 2
    i = eval(ij{1});
    j = eval(ij{2});
  elseif numel(ij) == 1
    i = eval(ij{1});
    j = 1;
  else
    i = 1;
    j = 1;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    parseLine
%
% DESCRIPTION: Returns the indices i,j and the remaining value for the
%              given field.
%
% Example:     expr: a+b*t        -> i=1, j=1, txt=a+b*t
%              expr a+b*t         -> i=1, j=1, txt=a+b*t
%              expr(3)    a+b*t   -> i=3, j=1, txt=a+b*t
%              expr(3,2): a+b*t   -> i=3, j=2, txt=a+b*t
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [i,j,txt] = parseLine(lineIn, field)
  exp = [field '(?<idx>\(\d*(,\d*)?\))?:? *'];
  idx = regexp(lineIn, exp, 'end');
  ij  = regexp(lineIn, exp, 'names');
  [i,j] = getIndex(ij(1).idx);
  txt = lineIn(idx+1:end);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    checkArray
%
% DESCRIPTION: There are the following rules
%              1) If the array have only one input then replicate this
%                 input to the maximum size of the used indices.
%              2) Throw an error if the inputs are more than one but not so
%                 much as the maximum of the used indices.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function array = checkArray(array, maxi, maxj)
  if numel(array) == 0
    % Do nothing
  elseif numel(array) == 1
    array = repmat(array, maxi, maxj);
  elseif size(array,1) ~= maxi || size(array,2) ~= maxj
    error('### One model is not well defined. Max (i,j) = (%d,%d) but only used (%d,%d)', maxi, maxj, size(array,1), size(array,2));
  end
end

