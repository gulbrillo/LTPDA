% TOLABEL converts a unit object to LaTeX string suitable for use as axis labels.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TOLABEL converts a unit object to LaTeX string suitable for
%              use as axis labels.
%
% CALL:        lbl = tolabel(u)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = tolabel(varargin)

  objs = [varargin{:}];

  pstrs = {};

  for ii = 1:numel(objs)
    u = objs(ii);
    
    [num, den] = factor(u);
    
    numstr = formatUnit(num);
    denstr = formatUnit(den);
    
    if isempty(denstr)      
      str =['$$\left[' numstr ' \right]$$'];
    else
      if isempty(numstr)
        str =['$$\left[1/' denstr ' \right]$$'];
      else
        str =['$$\left[\frac{' numstr '}{' denstr '} \right]$$'];
      end
    end    
    
    pstrs = [pstrs {str}];
    
  end
  
  varargout{1} = pstrs;
end


function s = formatUnit(u)
  
  s = '';
  for kk=1:numel(u.strs)
    prefix = unit.val2prefix(u.vals(kk));
    if u.exps(kk) == 0.5
      s = [s '\,{\sqrt{\textrm{' prefix u.strs{kk}  '}}}'];
    elseif u.exps(kk) == 1
      s = [s '\,{\textrm{' prefix u.strs{kk} '}}'];
    elseif u.exps(kk) > 0
      [n,d] = rat(u.exps(kk));
      if d == 1
        s = [s '\,{\textrm{' prefix u.strs{kk} '}}^{' num2str(n) '}'];
      else
        s = [s '\,{\textrm{' prefix u.strs{kk} '}}^{' num2str(n) '/' num2str(d) '}'];
      end
    end
  end
      
end

