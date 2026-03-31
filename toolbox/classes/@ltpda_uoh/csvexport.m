% CSVEXPORT Exports the data of an object to a csv file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    csvexport
%
% DESCRIPTION: Exports the data of an object to a csv file.
%
% CALL:        csvexport(in-objects);
%
% INPUTS:      in-objects: Input objects which data should be stored to
%                          disc.
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'csvexport')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = csvexport(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  [objs, ~, rest] = utils.helper.collect_objects(varargin(:), '');
  [pli, ~,  rest] = utils.helper.collect_objects(rest(:), 'plist');

  [data, plData] = csvGenerateData(objs);
  
  pl = applyDefaults(getDefaultPlist, pli);
  
  filename = pl.find_core('filename');
  commentChar = pl.find_core('commentChar');
  description = pl.find_core('description');
  
  % Some plausibility checks
  if isempty(filename)
    if ~isempty(rest) && ischar(rest{1})
      filename = rest{1};
      pl.pset('filename', filename);
    else
      error('### No filename is specified');
    end
  end
  if isempty(description)
    description = plData.find_core('DESCRIPTION');
  end
  columns  = plData.find_core('COLUMNS');
  nrows    = plData.find_core('NROWS');
  ncols    = plData.find_core('NCOLS');
  xunits   = plData.find_core('XUNITS');
  yunits   = plData.find_core('YUNITS');
  objIDs   = plData.find_core('OBJECT IDS');
  objNames = plData.find_core('OBJECT NAMES');
  creator  = plData.find_core('CREATOR');
  t0       = plData.find_core('T0');
  created  = format(time(), 'yyyy-mm-dd HH:MM');
  
  % Some checks to support different data types
  if isempty(t0)
    ref_time = '';
  else
    ref_time = format(t0, 'yyyy-mm-dd HH:MM.FFF z', 'UTC');
  end
  
  fid = fopen(filename, 'w');
  
  % Check fid
  if fid == -1
    error('### Can not open the file: %s', filename);
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%                              write header                             %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  fprintf(fid, '%s\n', commentChar);
  fprintf(fid, '%s  DESCRIPTION: %s\n', commentChar, description);
  fprintf(fid, '%s\n', commentChar);
  fprintf(fid, '%s  COLUMNS:     %s\n', commentChar, columns);
  
  columnNames = strtrim(regexp(columns, ',', 'split'));
  maxColNames = max(cellfun(@length, columnNames));
  
  for ii = 1:numel(columnNames)
    columnDesc = plData.find_core(columnNames{ii});
    if ~isempty(columnDesc)
      off = '';
      off(1:maxColNames-length(columnNames{ii})) = ' ';
      fprintf(fid, '%s    %s%s: %s\n', commentChar, columnNames{ii}, off, columnDesc);
    end
  end
  
  fprintf(fid, '%s\n', commentChar);
  fprintf(fid, '%s  NROWS:         %d\n', commentChar, nrows);
  fprintf(fid, '%s  NCOLS:         %d\n', commentChar, ncols);
  fprintf(fid, '%s\n', commentChar);
  fprintf(fid, '%s  OBJECT IDS:    %s\n', commentChar, objIDs);
  fprintf(fid, '%s  OBJECT NAMES:  %s\n', commentChar, objNames);
  fprintf(fid, '%s\n', commentChar);
  fprintf(fid, '%s  OBJECT UNITS:  ', commentChar);
  for jj = 1:numel(objs)
    fprintf(fid, '%s\t', char(xunits(jj)));
    fprintf(fid, '%s\t', char(yunits(jj)));
  end
  fprintf(fid, '\n');
  fprintf(fid, '%s\n', commentChar);
  if ~isempty(t0)
    fprintf(fid, '%s  T0:    %s\n', commentChar, ref_time);
    fprintf(fid, '%s\n', commentChar);
    fprintf(fid, '%s\n', commentChar);
  end
  fprintf(fid, '%s  CREATION DATE: %s\n', commentChar, created);
  fprintf(fid, '%s  CREATED BY:    %s\n', commentChar, creator);
  fprintf(fid, '%s\n', commentChar);
  fprintf(fid, '%s\n', commentChar);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%                              write data                               %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  for nn=1:nrows
    for dd = 1:ncols
      if numel(data{dd}) >= nn
        fprintf(fid, '%.17f', data{dd}(nn));
      end
      if dd < numel(data)
        fprintf(fid, ',');
      end
    end
    fprintf(fid, '\n');
  end
  
  fclose(fid);
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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
  plo = plist();
  p = param({'filename' 'cvs filename.'}, '');
  plo.append(p);
  p = param({'commentChar','The comment character in the file.'}, {1, {'#'}, paramValue.OPTIONAL});
  plo.append(p);
  p = param({'description', 'Description for the file.'}, '');
  plo.append(p);
end



