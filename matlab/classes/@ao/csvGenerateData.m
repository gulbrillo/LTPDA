% CSVGENERATEDATA Default method to convert a analysis object into csv data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    csvGenerateData
%
% DESCRIPTION:
%
% CALL:        [data, pl] = csvGenerateData(aos)
%
% INPUTS:      aos:  Input objects
%
% OUTPUTS:     data: Cell array with the data which should should be
%                    written to the file.
%              pl:   Parameter list which contains the description of the
%                    data. The parameter list must contain the following
%                    keys:
%                'DESCRIPTION':   Description for the file
%                'COLUMNS':       Meaning of each column seperated by a
%                                 comma. For additional information add
%                                 this name as a key and a description as
%                                 the value. For example:
%                                 |  key  |    value
%                                 -----------------------
%                                 |COLUMNS| 'X1, X2'
%                                 |   X1  | 'x-axis data'
%                                 |   X2  | 'y-axis data'
%
%                'NROWS':         Number of rows
%                'NCOLS':         Number of columns
%                'XUNITS':        The xunits property of the objects
%                'YUNITS':        The yunits property of the objects
%                'T0':            The t0 property of the objects
%                'OBJECT IDS':    UUID of the objects seperated by a comma
%                'OBJECT NAMES':  Object names seperated by a comma
%                'CREATOR':       Creator of the objects
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data, pl] = csvGenerateData(objs)
  
  description = '';
  columns     = '';
  uuids       = '';
  names       = '';
  creators    = {};
  creatorStr  = '';
  data        = {};
  t0s         = [];
  xunits      = [];
  yunits      = [];
  
  pl = buildplist(); % It is necessary to build always a new PLIST because this PLIST is used by the called method (see outputs).
  
  for nn = 1:numel(objs)
    
    %%%%%%%%%%%%%%%%%%%%%%   Define header information   %%%%%%%%%%%%%%%%%%%%%%
    if isempty(description)
      description = objs(nn).description;
    else
      description = sprintf('%s | %s', description, strrep(objs(nn).description, '|', ''));
    end
    if isempty(uuids)
      uuids = objs(nn).UUID;
    else
      uuids = sprintf('%s, %s', uuids, objs(nn).UUID);
    end
    if isempty(names)
      names = objs(nn).name;
    else
      names = sprintf('%s, %s', names, strrep(objs(nn).name, ',', ''));
    end
    creator = objs(nn).creator('all');
    creators = [creators, creator];
    
    %%%%%%%%%%%%%%%%%%%%%%   Generate data information   %%%%%%%%%%%%%%%%%%%%%%
    
    x     = objs(nn).x;
    y     = objs(nn).y;
    dx    = objs(nn).dx;
    dy    = objs(nn).dy;
    t0    = objs(nn).t0;
    xunit = objs(nn).xunits;
    yunit = objs(nn).yunits;
    
    if isreal(x) && isreal(y)
      %%%%%%%%%%   real Data   %%%%%%%%%%
      
      
      if ~isa(objs(nn).data, 'cdata')
        [columns, pl] = prepareDataDesc(columns, pl, sprintf('X%d',nn), 'x-data');
      end
      [columns, pl] = prepareDataDesc(columns, pl, sprintf('Y%d',nn), 'y-data');
      data = [data x y];
      
      %%% Add error if it exists
      if ~isempty(dx) || ~isempty(dy)
        if ~isa(objs(nn).data, 'cdata')
          [columns, pl] = prepareDataDesc(columns, pl, sprintf('DX%d',nn), 'error of the x-data');
        end
        [columns, pl] = prepareDataDesc(columns, pl, sprintf('DY%d',nn), 'error of the y-data');
        data = [data dx dy];
      end
      
    else
      %%%%%%%%%%   complex Data   %%%%%%%%%%
            
      if ~isa(objs(nn).data, 'cdata')
        [columns, pl] = prepareDataDesc(columns, pl, sprintf('real(X%d)',nn), 'real part of the x-data');
      end
      if ~isa(objs(nn).data, 'cdata')
        [columns, pl] = prepareDataDesc(columns, pl, sprintf('imag(X%d)',nn), 'imaginary part of the x-data');
      end
      [columns, pl] = prepareDataDesc(columns, pl, sprintf('real(Y%d)',nn), 'real part of the y-data');
      [columns, pl] = prepareDataDesc(columns, pl, sprintf('imag(Y%d)',nn), 'imaginary part of the y-data');
      data = [data real(x) imag(x) real(y) imag(y)];
      
      %%% Add error if it exists
      if ~isempty(dx) || ~isempty(dy)
        if ~isa(objs(nn).data, 'cdata')
          [columns, pl] = prepareDataDesc(columns, pl, sprintf('real(DX%d)',nn), 'real part of the error of x');
        end
        if ~isa(objs(nn).data, 'cdata')
          [columns, pl] = prepareDataDesc(columns, pl, sprintf('imag(DX%d)',nn), 'imaginary part of the error of x');
        end
        [columns, pl] = prepareDataDesc(columns, pl, sprintf('real(DY%d)',nn), 'real part of the error of y');
        [columns, pl] = prepareDataDesc(columns, pl, sprintf('imag(DY%d)',nn), 'imaginary part of the error of y');
        data = [data real(dx) imag(dx) real(y) imag(y)];
      end
      
    end
    
    %%% Add t0, xunits, yunits
    t0s    = [t0s, t0];
    xunits = [xunits, xunit];
    yunits = [yunits, yunit];
    
  end
  
  nrows    = max(cellfun(@length, data));
  ncols    = numel(data);
  if ~isempty(columns)
    columns = columns(3:end);
  end
  creators = unique(creators);
  for ii = 1:numel(creators)
    if isempty(creatorStr)
      creatorStr = creators{ii};
    else
      creatorStr = sprintf('%s, %s', creatorStr, creators{ii});
    end
  end
  
  pl.pset('DESCRIPTION', description);
  pl.pset('COLUMNS', columns);
  pl.pset('NROWS', nrows);
  pl.pset('NCOLS', ncols);
  pl.pset('XUNITS', xunits);
  pl.pset('YUNITS', yunits);
  pl.pset('OBJECT IDS', uuids);
  pl.pset('OBJECT NAMES', names);
  pl.pset('CREATOR', creatorStr);
  pl.pset('T0', t0s);
  
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function plo = buildplist()
  plo = plist(...
    'DESCRIPTION', '', ...
    'COLUMNS', '', ...
    'NROWS', -1, ...
    'NCOLS', -1, ...
    'XUNITS', unit(), ...
    'YUNITS', unit(), ...
    'T0', '', ...
    'OBJECT IDS', '', ...
    'OBJECT NAMES', '', ...
    'CREATOR', '');
end

function [columns, pl] = prepareDataDesc(columns, pl, colName, colDesc)
  columns = sprintf('%s, %s', columns, colName);
  pl.append(colName, colDesc);
end

