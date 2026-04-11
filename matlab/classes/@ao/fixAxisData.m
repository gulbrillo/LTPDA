% Fix up the data type according to the users chosen axis
%

function bs = fixAxisData(bs, pl, callerIsMethod)
  
  % Set data
  for ii = 1:numel(bs)
    
    if (isa(bs(ii).data, 'cdata'))
      if strfind(pl.find('axis'), 'x')
        warning('### An AO with cdata doesn''t have a x-axis. Setting the axis to ''y''.');
        pl.pset('axis', 'y');
      end
    else
      xu = bs(ii).data.xunits;
    end
    
    yu = bs(ii).data.yunits;
    switch lower(pl.find_core('axis'))
      case 'xy'
      case 'x'
        if bs(ii).data.isprop('xaxis')
          bs(ii).data = cdata(bs(ii).data.x);
          bs(ii).data.setYunits(xu);
        else
          error('### It is not possible to compute on the x-axis of an cdata object.')
        end
      case 'y'
        bs(ii).data = cdata(bs(ii).data.y);
        bs(ii).data.setYunits(yu);
      otherwise
        error('### shouldn''t happen.');
    end
    
    if ~callerIsMethod && ~isempty(bs(ii).hist) && ~isempty(bs(ii).hist.plistUsed)
      % Fix the history to what we actually return
      bs(ii).hist.plistUsed.pset('axis', pl.find_core('axis'));
    end
  end
  
  
end
