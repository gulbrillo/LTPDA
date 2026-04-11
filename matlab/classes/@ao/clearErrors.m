function clearErrors(varargin)

  bs = varargin{1};
  if nargin > 1
    pl = varargin{2};
    app_axis = pl.find_core('axis');
  else 
    app_axis = 'xy';
  end
  
  % Set units
  for jj = 1:numel(bs)
    if any('X'==upper(app_axis)) && isa(bs(jj).data, 'data2D')
      bs(jj).data.setDx([]);
    end
    if any('Y'==upper(app_axis))
      bs(jj).data.setDy([]);    
    end
  end
  
  
end
