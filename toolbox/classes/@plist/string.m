% STRING converts a plist object to a command string which will recreate the plist object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRING converts a plist object to a command string which will
%              recreate the plist object.
%
% CALL:        cmd = string(pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'string')">Parameters Description</a>
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = string(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  objs = utils.helper.collect_objects(varargin(:), 'plist');

  if numel(objs)>1
    pstr = '[';
  else
    pstr = '';
  end
  
  for ll = 1:numel(objs)
    pl   = objs(ll);
    pstr = sprintf('%splist(', pstr);
    Nparams = numel(pl.params);
    for jj = 1:Nparams
      p = pl.params(jj);
      pVal = p.getVal;
      if ischar(pVal)
        %---- CHAR
        val = sprintf('''%s''', strrep(pVal, '''', ''''''));

      elseif isnumeric(pVal)
        %---- NUMERIC
        val = sprintf('[%s]', utils.helper.mat2str(pVal));

      elseif islogical(pVal)
        %---- LOGICAL
        val = sprintf('[%s]', mat2str(pVal));

      elseif isjava(pVal)
        %---- JAVA
        if strcmp(class(pVal), 'sun.util.calendar.ZoneInfo')
          val = sprintf('java.util.TimeZone.getTimeZone(''%s'')',char(pVal.getID));
        else
          error('### Unknown java object [%s]', class(pVal));
        end

      elseif iscell(pVal)
        %---- CELL
        val = sprintf('%s', utils.prog.mcell2str(pVal));

      elseif isstruct(pVal)
        %---- STRUCT
        ss     = pVal;
        ss_str = '[';
        fields = fieldnames(ss);
        for oo = 1:numel(pVal)
          ss_str = sprintf('%s struct(', ss_str);
          for ii = 1:numel(fields)
            if isnumeric(ss(oo).(fields{ii})) || islogical(ss(oo).(fields{ii}))
              ss_str = sprintf('%s''%s'', [%s], ', ss_str, fields{ii}, mat2str(ss(oo).(fields{ii}), 17));
            elseif ischar(ss(oo).(fields{ii}))
              ss_str = sprintf('%s''%s'', ''%s'', ',ss_str, fields{ii}, strrep(ss(oo).(fields{ii}), '''', ''''''));
            elseif isa(ss(oo).(fields{ii}), 'ltpda_obj')
              ss_str = sprintf('%s''%s'', %s, ', ss_str, fields{ii}, string(ss(oo).(fields{ii})));
            elseif isa(ss(oo).(fields{ii}), 'sym')
              symstr = char(ss(oo).(fields{ii}));
              ss_str = sprintf('%s''%s'', sym(''%s''), ', ss_str, fields{ii}, symstr);
            elseif isjava(ss(oo).(fields{ii}))
              if strcmp(class(ss(oo).(fields{ii})), 'sun.util.calendar.ZoneInfo')
                ss_str = sprintf('%s''%s'', java.util.TimeZone.getTimeZone(''%s''), ', ss_str, fields{ii}, char(getID(ss(oo).(fields{ii}))));
              else
                error('### Unknown java object [%s]', class(ss(oo).(fields{ll})));
              end
            else
              error('### Unknown type [%s] in struct', class(ss(oo).(fields{ii})));
            end
          end
          ss_str = [ss_str(1:end-2), ')'];
        end
        val = sprintf('%s]', ss_str);

      elseif isa(pVal, 'sym')
        %---- SYM
        val = sprintf('sym(''%s'')', char(pVal));

      elseif isa(pVal, 'history')
        %---- HISTORY
        if ~isa(pVal.inhists, 'history')
          cmds = hist2m(pVal);
          [s,r] = strtok(cmds{2}, '=');
          val = regexprep(strtrim(r(2:end)), ';[ ]*%.*', '');
        else
          error('### Can not run string on an object containing history. Use type() instead.');
        end

      elseif isa(pVal, 'ltpda_nuo') || isa(pVal, 'plist')
        %---- Non-user object or plist
        val = string(pVal);

      elseif isa(pVal, 'ltpda_uoh')
        %---- Object with history
        for vv=1:numel(pVal)
          if isempty(pVal(vv).hist)
            val = string(pVal(vv));
          else
            if ~isa(pVal(vv).hist.inhists, 'history')
              cmds = hist2m(pVal(vv).hist);
              [s,r] = strtok(cmds{2}, '=');
              val = regexprep(strtrim(r(2:end)), ';[ ]*%.*', '');
            else
              % Since we can not run string on an object containing history, we call type() instead
              val = type(pVal(vv));
            end
          end
        end
        
      else
        val = ['' class(pVal) ''];
      end
      
      if iscell(p.key)
        keyStr = p.key{1};
      else
        keyStr = p.key;
      end
      pstr = sprintf('%s''%s'', %s, ', pstr, keyStr, val);
      
    end

    pstr = strtrim(pstr);
    if pstr(end) == ','
      pstr = pstr(1:end-1);
    end

    % close bracket
    pstr = [pstr '), '];
  end

  % Finish string
  pstr = strtrim(pstr);
  pstr = pstr(1:end-1);
  if numel(objs)>1
    pstr = [pstr ']'];
  end
  varargout{1} = pstr;
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
  ii.setModifier(false);
  ii.setArgsmin(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plo = getDefaultPlist()
  plo = plist.EMPTY_PLIST;
end

