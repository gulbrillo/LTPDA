% FIXAXISLABEL performs some substitutions on the axis label string.
% 

function ss = fixAxisLabel(ss)
  
  MAX_LENGTH = 100;
  wasCell = true;
  if ~iscell(ss)
    ss = {ss};
    wasCell = false;
  end
  
  for kk = 1:numel(ss)
    s = ss{kk};
    if ~isempty(s)
      % Replace all ^(...) with ^{...}
      jj = 1;
      while jj < numel(s)
        if strcmp(s(jj:jj+1), '^(')
          % find next )
          for k = 1:numel(s)-jj+1
            if s(jj+k) == ')'
              s(jj+1) = '{';
              s(jj+k) = '}';
              break;
            end
          end
        end
        jj = jj + 1;
      end
      % Replace all .^ with ^
      s = strrep(s, '.^', '^');
      
      % reduce size
      if length(s) > MAX_LENGTH
        addStr = '...';
      else
        addStr = '';
      end
      ssize = min(MAX_LENGTH, length(s));
      s = [s(1:ssize) addStr];
    end
    ss(kk) = {s};
  end
  
  
  if ~wasCell
    ss = ss{1};
  end
  
end