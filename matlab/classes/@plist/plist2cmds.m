% PLIST2CMDS convert a plist to a set of commands.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLIST2CMDS convert a plist to a set of commands.
%
% CALL:        cmds = plist2cmds(pl)
%              cmds = plist2cmds(pl, option_plist)
%
% INPUTS:
%              pl  - parameter list (see below)
%
% OUTPUTS:     cell-array of MATLAB commands.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cmd = plist2cmds(varargin)
  
  %%% Check if this is a call for parameters
%   if utils.helper.isinfocall(varargin{:})
%     cmd = getInfo(varargin{3});
%     return
%   end
  
  pl = varargin{1};
  
  if numel(pl) ~= 1
    error('### Please input (only) one plist');
  end
  
  if nargin > 1
%     opl = varargin{2};
    stop_option = varargin{2}; %opl.find_core('stop_option');
  else
    stop_option = 'full';
  end
    
  % look at the input parameters
  if isempty(pl)
    ps = '';
    before_pl = '';
  elseif isa(pl, 'plist')
    [ps, before_pl] = writePlist(pl, stop_option);
  end
  if strcmp(ps, 'plist([])')
    ps = '';
  end
  
  if ~isempty(ps)
    if ps(end) == ','
      ps = ps(1:end-1);
    end
  end
  cmd = sprintf('pl = %s;', ps);
  cmd = {cmd before_pl{:}};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% FUNCTION:    writePlist                                                     %
%                                                                             %
% DESCRIPTION: write a plist                                                  %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ps, before_pl] = writePlist(pls, stop_option)
  
  before_pl = {};
  ps = '[';
  
  for pp=1:numel(pls)
    pl = pls(pp);
    ps = [ps 'plist('];
    for ii=1:length(pl.params)
      p = pl.params(ii);
      pVal = p.getVal;
      
      [cmd, pre_cmd] = val2cmd(pVal, stop_option);
      
      before_pl = [before_pl pre_cmd];
      
      % If we have alternative key names, use the default
      keyStr = p.defaultKey;
      
      if isempty(p.desc)
        ps = sprintf('%s''%s'', %s, ', ps, keyStr, cmd);
      else
        ps = sprintf('%s{''%s'', ''%s''}, %s, ', ps, keyStr, strrep(p.desc, '''', ''''''), cmd);
      end
      
    end
    if strcmp(ps(end-1:end), ', ')
      ps = ps(1:end-2);
    end
    ps = [ps '), '];
  end
  if strcmp(ps(end-1:end), ', ')
    ps = [ps(1:end-2) ']'];
  end
  
end


function [cmd, pre_cmd] = val2cmd(pVal, stop_option)
  pre_cmd = {};
  cmd = '';
  if ischar(pVal)
    %%%   char   %%%
    cmd = sprintf('''%s''', strrep(pVal, '''', ''''''));
    
  elseif isnumeric(pVal)
    %%%   numeric   %%%
    if isempty(pVal)
      cmd = '[]';
    else
      cmd = sprintf('[%s]', utils.helper.mat2str(pVal));
    end
    
  elseif islogical(pVal)
    %%%   logical   %%%
    cmd = sprintf('[%s]', mat2str(pVal));
    
  elseif isjava(pVal)
    %%%   java   %%%
    if strcmp(class(pVal), 'sun.util.calendar.ZoneInfo')
      cmd = sprintf('java.util.TimeZone.getTimeZone(''%s'')',char(pVal.getID));
    else
      error('### Unknown java object [%s]', class(pVal));
    end
    
  elseif isa(pVal, 'history') || isa(pVal, 'ltpda_uoh')
    %%%   history   %%%
    if isa(pVal, 'ltpda_uoh')
      h = [pVal(:).hist];
      h = reshape(h, size(pVal));
    else
      h = pVal;
    end
    
    varnames = '[';
    
    for vv1 = 1:size(h,1)
      for hh1 = 1:size(h,2)
        
        obj      = h(vv1,hh1);
        objpl    = hist2m(obj, stop_option);
        objpl(1) = []; % drop last 'a_out' line
        pre_cmd  = [pre_cmd objpl];
        varnames = [varnames strtok(objpl{1})];
        if size(h,2) > 1 && hh1 ~= size(h,2)
          varnames = [varnames, ', '];
        end
      end
      if size(h,1) > 1 && vv1 ~= size(h,1)
        varnames = [varnames, '; '];
      end
    end
    
    cmd = [strtrim(varnames) ']'];
    
  elseif isa(pVal, 'ltpda_nuo')
    %%%   non-user object   %%%
    cmd = string(pVal);
    
  elseif isa(pVal, 'plist')
    %%%   plist object   %%%
    [cmd, pre_cmd] = writePlist(pVal, stop_option);
    
  elseif isa(pVal, 'sym')
    %%%   symbolic math object   %%%
    cmd = sprintf('sym(''%s'')', char(pVal));
    
  elseif iscell(pVal)
    %%% Cell %%%
    if isempty(pVal)
      cmd = sprintf('cell(%d,%d)', size(pVal,1), size(pVal,2));
    else
      cmd = '{';
      
      for vv = 1:size(pVal,1)
        for hh = 1:size(pVal,2)
          [cell_cmd, cell_pre_cmd] = val2cmd(pVal{vv,hh}, stop_option);
          cmd = [cmd, cell_cmd];
          pre_cmd = [pre_cmd cell_pre_cmd];
          if size(pVal,2) > 1 && hh ~= size(pVal,2)
            cmd = [cmd, ', '];
          end
        end
        if size(pVal,1) > 1 && vv ~= size(pVal,1)
          cmd = [cmd, '; '];
        end
      end
      
      cmd = [strtrim(cmd) '}'];
    end
    
  elseif isstruct(pVal)
    %%% Struct %%%
    ss     = pVal;
    ss_str = '[';
    fields = fieldnames(ss);
    for oo = 1:numel(pVal)
      ss_str = sprintf('%s struct(', ss_str);
      for ii = 1:numel(fields)
        if isnumeric(ss(oo).(fields{ii})) || islogical(ss(oo).(fields{ii}))
          ss_str = sprintf('%s''%s'', [%s], ', ss_str, fields{ii}, utils.helper.mat2str(ss(oo).(fields{ii})));
        elseif ischar(ss(oo).(fields{ii}))
          ss_str = sprintf('%s''%s'', ''%s'', ',ss_str, fields{ii}, strrep(ss(oo).(fields{ii}), '''', ''''''));
        elseif isa(ss(oo).(fields{ii}), 'ltpda_nuo')
          ss_str = sprintf('%s''%s'', %s, ', ss_str, fields{ii}, string(ss(oo).(fields{ii})));
        elseif isa(ss(oo).(fields{ii}), 'plist')
          [struct_cmd, struct_pre_cmd] = writePlist(ss(oo).(fields{ii}), stop_option);
          ss_str = sprintf('%s''%s'', %s, ', ss_str, fields{ii}, struct_cmd);
          pre_cmd = [pre_cmd struct_pre_cmd];
        elseif isa(ss(oo).(fields{ii}), 'ltpda_uoh')
          h = ss(oo).(fields{ii}).hist;
          varnames = '[';
          for kk=1:numel(h)
            obj       = h(kk);
            objpl = hist2m(obj);
            objpl(1) = []; % drop last 'a_out' line
            pre_cmd = [pre_cmd objpl];
            varnames = [varnames strtok(objpl{1}) ' '];
          end
          ss_str = sprintf('%s''%s'', %s, ', ss_str, fields{ii}, [strtrim(varnames) ']']);
        elseif isa(ss(oo).(fields{ii}), 'sym')
          symstr = char(ss(oo).(fields{ii}));
          ss_str = sprintf('%s''%s'', sym(''%s''), ', ss_str, fields{ii}, symstr);
        elseif iscell(ss(oo).(fields{ii})) && isempty(ss(oo).(fields{ii}))
          ss_str = sprintf('%s''%s'', {{}}, ', ss_str, fields{ii});
        elseif iscellstr(ss(oo).(fields{ii}))
          ss_str = sprintf('%s''%s'', %s, ', ss_str, fields{ii}, strcat('{', utils.helper.val2str(ss(oo).(fields{ii})), '}') );
        elseif isjava(ss(oo).(fields{ii}))
          if strcmp(class(ss(oo).(fields{ii})), 'sun.util.calendar.ZoneInfo')
            ss_str = sprintf('%s''%s'', java.util.TimeZone.getTimeZone(''%s''), ', ss_str, fields{ii}, char(getID(ss(oo).(fields{ii}))));
          else
            error('### Unknown java object [%s]', class(ss(oo).(fields{ii})));
          end
        else
          warning('### Unknown type [%s] in struct', class(ss(oo).(fields{ii})));
          ss_str = '';
        end
      end
      ss_str = [ss_str(1:end-2), ')'];
    end
    cmd = sprintf('%s]', ss_str);
  elseif isa(pVal, 'handle') && ismethod(pVal, 'obj2cmds')
    [cmd, pre_cmd] = obj2cmds(pVal);
  else
    error('### Unknown parameter type: %s.\n\Non LTPDA classes must implement a public method: [cmd, pre_cmd] = obj2cmds(objsIn)\n', class(pVal));
  end
end

