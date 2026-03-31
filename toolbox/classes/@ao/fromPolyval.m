% FROMPOLYVAL Construct an ao from polynomial coefficients
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromPolyval
%
% DESCRIPTION: Construct an ao from polynomial coefficients
%
% CALL:        a = fromPolyval(a, vals)
%
% PARAMETER:   pl: plist containing 'polyval', 'Nsecs', 'fs', or 't'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function a = fromPolyval(a, pli)
  
  import utils.const.*
  
  % get AO info
  ii = ao.getInfo('ao', 'From Polynomial');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  
  coeffs = find_core(pl, 'polyval');
  Nsecs  = find_core(pl, 'Nsecs');
  fs     = find_core(pl, 'fs');
  t      = find_core(pl, 't');
  x      = find_core(pl, 'x');
  f      = find_core(pl, 'f');
  dtype  = find_core(pl, 'type');
  
  % Collect the coefficients
  coeff_class = class(coeffs);
  
  switch coeff_class
    case 'ao'
      if numel(coeffs) == 1
        % Single AO with an array of coefficients
        coeffs = coeffs.y;
      else
        % Vector of AOs with single coefficients
        error(['### Incorrect container for coefficients. \n' ...
          'Supporting only aos, aos inside Nx1 or 1xN matrix object, single pest objects, double arrays']);
      end
    case 'matrix'
      % A matrix of AOs with single coefficients
      coeff_array = [ao];
      ncol =  ncols(coeffs);
      nrow = nrows(coeffs);
      if ncol > 1
        if nrow == 1
          nc = ncol;
          for jj = 1:nc
            coeff_array(jj) = coeffs.getObjectAtIndex(1, jj);
          end
          coeffs = coeff_array.y;
        else
          error(['### Incorrect container for coefficients. \n' ...
            'Supporting only aos, aos inside Nx1 or 1xN matrix object, single pest objects, double arrays']);
        end
      else
        nc = nrow;
        for jj = 1:nc
          coeff_array(jj) = coeffs.getObjectAtIndex(jj, 1);
        end
        coeffs = coeff_array.y;
      end
    case 'pest'
      nc = numel(coeffs.y);
      if numel(coeffs) == 1
        % Single pest with an array of coefficients
        if ~isempty(coeffs.models)
          yunits = coeffs.models.yunits;
        else
          yunits = [];
        end
        coeff_yunits = coeffs.yunits;
        coeffs = coeffs.y;
      else
        % Vector of pests with single coefficients
        error(sprintf(['### Incorrect container for coefficients. \n' ...
          'Supporting only aos, aos inside Nx1 or 1xN matrix object, single pest objects, double arrays']));
      end
    case 'double'
      % Do nothing in this case
    otherwise
      error(sprintf(['### Incorrect container for coefficients. \n' ...
        'Supporting only aos, aos inside Nx1 or 1xN matrix object, single pest objects, double arrays']));
  end
  
  % Try to decide what to do if the user doesn't specify data type
  if isempty(dtype)
    if  ~isempty(Nsecs) || ~isempty(t) || ~isempty(fs)
      dtype = 'tsdata';
    elseif ~isempty(x)
      dtype = 'xydata';
    elseif ~isempty(f)
      dtype = 'fsdata';
    else
      error('### Please specify data type and parameters');
    end
  end
  
  switch dtype
    case 'tsdata'
      if isa(t, 'ao')
        t_xunits = t.xunits;
        % Override the xunits by using those from the t vector
        utils.helper.msg(msg.OFF, ...
          'warning: overriding the user-input xunits %s with the t ao %s', ...
          char(find_core(pl, 'xunits')), char(t_xunits));
        t = t.x;
      else
        t_xunits = [];
      end
      
      % Check t vector
      if isempty(t)
        if isempty(Nsecs) || isempty(fs)
          error('Please provide either ''Nsecs'' and ''fs'', or ''t'' for polyval constructor with data type ''tsdata''.');
        end
        t = tsdata.createTimeVector(fs, Nsecs);
      end
      
      y = polyval(coeffs,t);
      
      % Make a tsdata object
      p = tsdata(t, y);
      
      % Make sure the actual sampling frequency fs is captured in the plist
      pl.pset('fs', p.fs);
      
      % set T0
      p.setT0(pl.find_core('t0'));
      
      % set Toffset
      if ~isempty(pl.find_core('toffset'))
        toffset = p.toffset + 1000*pl.find_core('toffset');
        p.setToffset(toffset);
      end
      
      % Checks the units
      % xunits
      if isempty(t_xunits)
        new_xunits = find_core(pl, 'xunits');
        if isempty(new_xunits)
          new_xunits = 's';
        end
      else
        new_xunits = t_xunits;
      end
      pl.pset('xunits', new_xunits);
      
    case 'xydata'
      if isa(x, 'ao')
        x_xunits = x.xunits;
        % Override the xunits by using those from the x vector
        utils.helper.msg(msg.OFF, ...
          'warning: overriding the user-input xunits %s with the x ao %s', ...
          char(find_core(pl, 'xunits')), char(x_xunits));
        pl.pset('xunits', x_xunits);
        x = x.x;
      else
        x_xunits = [];
      end
      
      % Check x vector
      if isempty(x)
        error('### Please provide the x values');
      end
      
      y = polyval(coeffs,x);
      
      % Make a xydata object
      p = xydata(x, y);
      
      % Checks the units
      % xunits
      if isempty(x_xunits)
        new_xunits = find_core(pl, 'xunits');
      else
        new_xunits = x_xunits;
      end
      pl.pset('xunits', new_xunits);
      
    case 'fsdata'
      if isa(f, 'ao')
        f_xunits = f.xunits;
        % Override the xunits by using those from the x vector
        utils.helper.msg(msg.OFF, ...
          'warning: overriding the user-input xunits %s with the x ao %s', ...
          char(find_core(pl, 'xunits')), char(f_xunits));
        pl.pset('xunits', f_xunits);
        f = f.x;
      else
        f_xunits = [];
      end
      
      % Check f vector
      if isempty(f)
        error('### Please provide the frequency values');
      end
      
      y = polyval(coeffs,f);
      
      % Make a fsdata object
      p = fsdata(f, y);
      
      % Checks the units
      % xunits
      if isempty(f_xunits)
        new_xunits = find_core(pl, 'xunits');
        if isempty(new_xunits)
          new_xunits = 'Hz';
        end
      else
        new_xunits = f_xunits;
      end
      pl.pset('xunits', new_xunits);
      
    otherwise
      error('### Unsupported data type %s', dtype);
  end
  
  % yunits
  switch lower(coeff_class)
    case 'matrix'
      % Matrix of AOs with coefficients was provided. So the units must be
      % consistent (with requested, if any, and between each other)
      new_yunits = find_core(pl, 'yunits');
      if isempty(new_yunits)
        new_yunits = simplify(coeff_array(1).yunits .* (new_xunits.^(nc-1)));
      else
        new_yunits = unit(new_yunits);
      end
      for jj = 1:nc
        if ~isequal(coeff_array(jj).yunits * (new_xunits.^(nc-jj)), new_yunits)
          error('### Inconsistent units either between coefficients or with requested')
        end
      end
      pl.pset('yunits', new_yunits);
    case 'pest'
      % A pest object with coefficients was provided
      % Did the user provide yunits? Let's use them
      new_yunits = find_core(pl, 'yunits');
      % Otherwise, let's use the yunits of the smodel inside the pest
      if isempty(new_yunits)
        new_yunits = yunits;
      end
      % Otherwise, let's calculate them
      if isempty(new_yunits)
        new_yunits = simplify(coeff_yunits(1) .* (new_xunits.^(nc-1)));
        for jj = 1:nc
          if ~isequal(simplify(coeff_yunits(jj) * (new_xunits.^(nc-jj))), new_yunits)
            error('### Inconsistent units either between coefficients')
          end
        end
      end
      pl.pset('yunits', new_yunits);
    otherwise
  end
  
  % Make an analysis object
  a.data  = p;
  % Set xunits
  a.data.setXunits(pl.find_core('xunits'));
  % Set yunits
  a.data.setYunits(pl.find_core('yunits'));
  % Simplify units
  a.simplifyYunits(plist('Prefixes', false));
  % Add history
  a.addHistory(ii, pl, [], []);
  % Set object properties from the plist
  a.setObjectProperties(pl, {'xunits', 'yunits', 'fs', 'x', 'toffset'});
end

