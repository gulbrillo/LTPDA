function varargout = find_core(pl, key, varargin)
  
  matches =  matchKey_core(pl, key);
  
  if any(matches)
    val = pl.params(matches).getVal;
  else
    if ~isempty(varargin)
      val = varargin{1};
    else
      val = [];
    end
  end
  
  if isa(val, 'ltpda_obj')
    varargout{1} = copy(val, 1);
  else
    varargout{1} = val;
  end
end
