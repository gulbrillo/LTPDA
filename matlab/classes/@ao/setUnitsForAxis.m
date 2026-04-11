function setUnitsForAxis(bs, pl, u)
  
  % Set units
  for ii = 1:numel(bs)
    app_axis = pl.find_core('axis');
    if any('X'==upper(app_axis))
      bs(ii).data.setXunits(u);
    end
    if any('Y'==upper(app_axis))
      bs(ii).data.setYunits(u);
    end
    if any('Z'==upper(app_axis))
      bs(ii).data.setZunits(u);
    end
  end
  
end
