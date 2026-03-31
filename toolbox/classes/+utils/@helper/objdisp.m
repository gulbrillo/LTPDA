% OBJDISP displays the input object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: OBJDISP displays the input object.
%
%        utils.helper.objdisp(obj)
%  txt = utils.helper.objdisp(obj)    Returns the display text as a cell
%                                     array of strings.
%
% The following call returns an info object for this method.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = objdisp(varargin)
  
  % Go through each input
  txt = {};
  for jj = 1:nargin
    % get this input
    objs = varargin{jj};
    
    % Print emtpy object
    if isempty(objs)
      hdr = sprintf('------ %s -------', class(objs));
      ftr(1:length(hdr)) = '-';
      txt = [txt; {hdr}];
      txt = [txt; sprintf('empty-object [%d,%d]',size(objs))];
      txt = [txt; {ftr}];
    end
    
    % go through each object in this input arg
    for kk = 1:numel(objs)
      % header
      obj = objs(kk);
      hdr = sprintf('------ %s/%d -------', class(obj), kk);
      ftr(1:length(hdr)) = '-';
      txt = [txt; {hdr}];
      % Go through each field of this object
      fnames = fieldnames(obj);
      % get longest name for padding
      maxl = max(cellfun('length', fnames));
      
      for ii = 1:numel(fnames)
        f = fnames{ii};
        fval = obj.(f);
        padstr = sprintf('%*s', maxl, fnames{ii});
        npadstr = repmat(' ', 1, length(padstr));
        % deal with cell-arrays of strings
        switch class(fval)
          case 'cell'
            cs = ['[' utils.helper.mat2str(size(fval,1)), 'x', utils.helper.mat2str(size(fval,2)) ']'];
            cstr =  Cell2String(fval);
            if isempty(cstr)
              txt = [txt; [sprintf('%s: ', padstr), '{}']];
            else
              str = [sprintf('%s: ', padstr), cstr(1,:)];
              txt = [txt; str];
              for mm=2:size(cstr,1)
                str = [sprintf('%s  ', npadstr), cstr(mm,:)];
                txt = [txt; str];
              end
            end
            txt{end} = [txt{end} '  ' cs];
          case {...
              'single', 'double', ...
              'uint8',  'int8',   ...
              'uint16', 'int16',  ...
              'uint32', 'int32',  ...
              'uint64', 'int64'}
            MAX_LENGTH = 40;
            if isempty(fval)
              str = [sprintf('%s: ', padstr) mat2str(fval)];
            elseif isvector(fval)
              str = [sprintf('%s: ', padstr) utils.helper.mat2str(fval(1:min(MAX_LENGTH, numel(fval))))];
            else
              str = [sprintf('%s: ', padstr) mat2str(fval(1:min(MAX_LENGTH, numel(fval))))];
            end
            if MAX_LENGTH<numel(fval)
              str  = [str(1:end-1) ' ... ]'];
            end
            txt = [txt; str];
          case 'ssmblock'
            txt = [txt; sprintf('%s:  [%dx%d %s]', padstr, size(fval), class(fval))];
            margin = sprintf('%s: ', padstr);
            whitespace = '';
            for mm = 1:(numel(margin)-4)
              whitespace = [whitespace ' '];
            end
            for mm = 1:numel(fval)
              txt = [txt ; [ sprintf( '%s%s%s%s', whitespace , num2str(mm) ,' : ') strtrim(char(fval(mm))) ] ];
            end
          case 'meta.method'
            if isempty(objs.testMethods)
              txt = [txt; {sprintf('%s: - No Methods -', padstr)}];
            else
              txt = [txt; {sprintf('%s: %s', padstr, fval(1).Name)}];
              for mm = 2:numel(fval)
                sp(1:maxl) = ' ';
                txt = [txt; {sprintf('%s  %s', sp, fval(mm).Name)}];
              end
            end
          case 'handle'
            txt = [txt; sprintf('%s: %s [%dx%d %s]', padstr, strtrim(char(fval)), size(fval), class(fval))];
          case 'logical'
            txt = [txt; sprintf('%s: ', padstr) mat2str(fval)];
          case 'struct'
            fieldsTxt = utils.helper.objdisp(fval);
            txt = [txt; sprintf('%s: %s', padstr, fieldsTxt{1})];
            for qq = 2:numel(fieldsTxt)
              txt = [txt; sprintf('%s  %s', blanks(numel(padstr)), fieldsTxt{qq})];
            end
          case {'meta.package', 'meta.class', 'meta.property'}
            txt = [txt; sprintf('%s: [%dx%d %s(%s)]', padstr, size(fval), class(fval), fval.Name)];
          case 'function_handle'
            txt = [txt; sprintf('%s: @%s', padstr, char(fval))];
          case {'MException', 'matlab.exception.JavaException'}
            txt = [txt; sprintf('%s: [%dx%d %s] %s', padstr, size(fval), class(fval), fval.message)];
          otherwise
            txt = [txt; sprintf('%s: %s', padstr, char(fval))];
        end
      end
      txt = [txt; {ftr}];
    end % end object loop
  end % end input loop
  
  if nargout == 0
    for ii = 1:length(txt)
      disp(txt{ii});
    end
  elseif nargout == 1
    varargout{1} = txt;
  end
end

function txt = Cell2String(c)
  sc = size(c);
  % recursive code to print the content of cell arrays
  if iscell(c) % for a cell
    txt = '';%;
    for ii = 1:sc(1)
      if ii == 1
        txti = '{';
      else
        txti = ' ';
      end
      for jj = 1:sc(2)
        txti = [txti ' ' Cell2String(c{ii,jj})];
      end
      if ii == size(c,1)
        txti = [txti, ' }'];
      end
      txt = strvcat(txt, txti);
    end
  elseif islogical(c) % for a logical
    txt = mat2str(c);
  elseif isnumeric(c) || isa(c,'sym') % for a numerical array, only size is displayed
    if isequal(sc, [0 0])
      txt = '  []   ';
    elseif isa(c, 'double') && numel(c)==1
      txt = ['[' sprintf('%.17g', c) ']'];
    elseif isa(c,'double') && (norm(c)==0) % for zero array (test dos not carsh for sym)
      txt = '  []   ';
    else % for non empty array
      if sc(1) > 9
        txt1 = ['[',utils.helper.num2str(sc(1))];
      else
        txt1 = [' [',utils.helper.num2str(sc(1))];
      end
      if sc(2) > 9
        txt2 = [utils.helper.num2str(sc(2)),']'];
      else
        txt2 = [utils.helper.num2str(sc(2)),'] '];
      end
      txt = [txt1,'x',txt2 ];
    end
    % txt = mat2str(c); % old display
  elseif ischar(c)
    txt = ['''' c ''''];
  else
    txt = char(c);
  end
end
