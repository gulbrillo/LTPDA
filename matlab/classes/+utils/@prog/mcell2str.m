% MCELL2STR recursively converts a cell-array to an executable string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MCELL2STR recursively converts a cell-array to an executable
%              string.
%
% CALL:       s = wrapstring(s, n)
%
% INPUTS:     s  - String
%             n  - max length of each cell
%
% OUTPUTS:    s  - the wrapped cell string
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fstr = mcell2str(c)
  
  %----- Check the input
  if ~iscell(c)
    error('### The input must be a cell but it is from the class [%s]', class(c));
  end
  
  if isempty(c)
    fstr = sprintf('cell(%d,%d)', size(c, 1), size(c,2));
  else
    fstr = '{';
    Nj = size(c,1);
    Nk = size(c,2);
    for jj=1:Nj
      for kk=1:Nk
        if iscell(c{jj,kk})
          %----- cell
          fstr = [fstr utils.prog.mcell2str(c{jj,kk})  ','];
          
        elseif ischar(c{jj,kk})
          %----- char
          fstr = sprintf('%s''%s'', ', fstr, strrep(c{jj, kk}, '''', ''''''));
          
        elseif isa(c{jj,kk}, 'sym')
          %----- sym
          fstr = [fstr 'sym(''' char(c{jj,kk}) '''),'];
          
        elseif isnumeric(c{jj,kk})
          %----- numeric
          fstr = [fstr utils.helper.mat2str(c{jj,kk}) ','];
          
        elseif islogical(c{jj,kk})
          %----- logical
          fstr = [fstr utils.helper.mat2str(c{jj,kk})  ','];
          
        elseif  isjava(c{jj,kk})
          %----- java
          if strcmp(class(c{jj,kk}), 'sun.util.calendar.ZoneInfo')
            fstr = [fstr 'java.util.TimeZone.getTimeZone(''' char(getID(c{jj,kk})) '''),'];
          else
            error('### Unknown java object [%s]', class(c{jj,kk}));
          end
          
        elseif isa(c{jj,kk}, 'ltpda_obj')
          %----- ltpda_obj
          
          if isa(c{jj,kk}, 'history')
            %----- history
            cl = history.getObjectClass(c{jj,kk});
            ncl = numel(c{jj,kk});
            cstr = '[';
            for ll=1:ncl
              cstr = [cstr sprintf('%s(%s)', cl, string(c{jj,kk}(ll).plistUsed)) ', '];
            end
            cstr = strtrim(cstr);
            cstr(end) = ']';
            fstr = sprintf('%s%s, ', fstr, cstr);
          else
            if isa(c{jj,kk}, 'ltpda_uoh')
              %---- Object with history 
              if isempty(c{jj,kk}.hist)
                str = sprintf('%s%s, ', fstr, string(c{jj,kk}));
              else
                if ~isa(c{jj,kk}.hist.inhists, 'history')
                  cmds = hist2m(c{jj,kk}.hist);
                  [s,r] = strtok(cmds{2}, '=');
                  val = regexprep(strtrim(r(2:end)), ';[ ]*%.*', '');
                else
                  % Since we can not run string on an object containing history, we call type() instead
                  val = type(c{jj,kk});
                end
                fstr = sprintf('%s%s, ', fstr, val);
              end
            else
              fstr = sprintf('%s%s, ', fstr, string(c{jj,kk}));
            end
          end
          
        elseif isstruct(c{jj,kk})
          %----- structure
          fn = fieldnames(c{jj,kk});
          fstr = [fstr 'struct('];
          for ii=1:numel(fn)
            obj = c{jj,kk};
            if ischar(obj.(fn{ii}))
              fstr = [fstr '''' fn{ii} ''',''' obj.(fn{ii})  ''','];
            elseif isnumeric(obj.(fn{ii})) || islogical(obj.(fn{ii}))
              fstr = [fstr '''' fn{ii} ''',' utils.helper.mat2str(obj.(fn{ii}))  ','];
            elseif isa(obj.(fn{ii}), 'sym')
              fstr = [fstr '''' fn{ii} ''',' 'sym(''' char(obj.(fn{ii})) '''),'];
            elseif isa(obj.(fn{ii}), 'ltpda_obj')
              fstr = [fstr '''' fn{ii} ''',' string(obj.(fn{ii}))  ','];
            end
          end
          fstr = [fstr(1:end-1) '),'];
          
        else
          % if we have a string method, use it
          try
            fstr = sprintf('%s%s, ', fstr, string(c{jj,kk}));
          catch Me
            % try to convert to char
            try
              fstr = [fstr '''' char(c{jj,kk}) ''''];
            catch Me
              disp(c{jj,kk});
              error(['### unknown cell content: ' class(c{jj,kk})]);
            end
          end
        end
      end
      fstr = strtrim(fstr);
      if fstr(end) == ','
        fstr = fstr(1:end-1);
      end
      fstr = [fstr ';'];
    end
    
    fstr = strtrim(fstr);
    if fstr(end) == ','
      fstr = fstr(1:end-1);
    end
    if fstr(end) == ';'
      fstr = fstr(1:end-1);
    end
    fstr = [fstr '}'];
  end
end
