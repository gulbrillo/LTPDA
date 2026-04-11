% FROMDATAFILE Construct an ao from filename AND parameter list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromDatafile
%
% DESCRIPTION: Construct an ao from filename AND parameter list
%
% CALL:        a = fromFilenameAndPlist(a, pli)
%
% PARAMETER:   a:   empty ao-object
%              pli: plist-object (must contain the filename)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function a = fromDatafile(ain, pli)
  
  utils.helper.msg(utils.const.msg.PROC1, 'constructing from filename and/or plist');
  
  % get AO info
  mi = ao.getInfo('ao', 'From ASCII File');
  
  % Get filename
  file_name = find_core(pli, 'filename');
  file_path = find_core(pli, 'filepath');
  
  [filePath, fileName, ext] = fileparts(file_name);
  
  % Add the file extenstion to the fileName
  fileName = strcat(fileName, ext);
  
  % Define the path of the
  if ~isempty(file_path) && ~isempty(filePath)
    % Do nothing because we will use filePath
  elseif ~isempty(file_path)
    filePath = file_path;
  elseif ~isempty(filePath)
    % Do nothing because we will use filePath
  else
    filePath = pwd();
  end
  
  absolutePathname = fullfile(filePath, fileName);
  
  % Check if the abolute Pathname exist
  if ~exist(absolutePathname, 'file')
    absolutePathname = fileName;
  end
  
  %%%%%%%%%%   Get default parameter list   %%%%%%%%%%
  dpl = ao.getDefaultPlist('From ASCII File');
  pl  = applyDefaults(dpl, pli);
  
  pl = pset(pl, 'filename', fileName);
  pl = pset(pl, 'filepath', filePath);
  
  data_type    = find_core(pl, 'type');
  columns      = find_core(pl, 'columns');
  maxLines     = find_core(pl, 'maxlines');
  comment_char = find_core(pl, 'comment_char');
  delimiter    = find_core(pl, 'delimiter');
  use_fs       = find_core(pl, 'fs');
  a            = [];
  orig_col     = columns; % necessary for the history
  t0           = find_core(pl, 't0');
  ignoreLines  = find_core(pl, 'IgnoreLines');
  headerLines  = find_core(pl, 'HeaderLines');
  
  %%%   Give a warning if the user haven't specified the data type   %%%
  if ~pli.isparam_core('type')
    if pli.isparam_core('fs')
      data_type = 'tsdata';
      warning('ao:fromDatafile', '!!! You haven''t defined a data type but a frequency.\nThe output will be an AO with time-series data.');
    else
      warning('ao:fromDatafile', '!!! You haven''t defined a data type.\nThe output will be an AO with constant data.');
    end
  end
  
  %%%%
  if strcmpi(data_type, 'cdata')
    use_fs = 1;
  end
  
  %%%%%%%%%%   read file   %%%%%%%%%%
  [fid,msg] = fopen (absolutePathname, 'r');
  if (fid < 0)
    error ('### can not open file: %s \n### error msg: %s', absolutePathname, msg);
  end
  
  %%%%%%%%%%   ignore first lines   %%%%%%%%%%
  firstLines = max(ignoreLines, headerLines);
  firstStrs  =  '';
  for gg=1:firstLines
    firstStrs = [firstStrs fgets(fid)];
  end
  
  try
    
    %%%%%%%%%%   create scan format: '%f %f %f %f %f %*[^\n]'   %%%%%%%%%%
    scan_format = '';
    read_col    = 0;
    
    %%%%%%%%%%   Read first comment and empty lines   %%%%%%%%%%
    while ~feof(fid)
      fidPos = ftell(fid);
      fline = fgetl(fid);
      % check if there was an error reading the file
      [errmsg, errnum] = ferror(fid);
      if errnum ~= 0
        error('### an error happened reading the first part of the file: %s', errmsg)
      end
      if fline == -1
        % we hit the end of file
        error('### the file is empty!')
      end
      fline = strtrim(fline);
      if ~isempty(fline) && ~(~isempty(comment_char) && strncmp(fline, comment_char, numel(comment_char)))
        fseek(fid, fidPos, 'bof');
        break;
      end
    end
    
    %%%%%%%%%%   Get/Count max number of lines   %%%%%%%%%%
    if isempty(maxLines)
      maxLines = numLines(fid);
      utils.helper.msg(utils.const.msg.PROC2, 'Counting lines: %d', maxLines);
    end
    
    %%%%%%%%%%   Check max number of columns   %%%%%%%%%%
    maxColumns = numCols(fid, delimiter);
    if isempty(columns) && strcmpi(data_type, 'cdata')
      columns  = 1:maxColumns;
      orig_col = columns;
    end
    if maxColumns < max(columns)
      error('### The file doesn''t have more than [%d] columns. But you want to read the column [%d].', maxColumns, max(columns));
    end
    
    %%%%%%%%%%   Check number of columns   %%%%%%%%%%
    if isempty(columns) && ~strcmpi(data_type, 'cdata')
      error('### Please specify at least one column number to read the data file.');
    end
    
    %%% preallocate data array
    f_data = zeros(maxLines, numel(unique(columns)));
    
    %%% check if using robust read: 'yes'/'no' or true/false or 'true'/'false'
    robust = utils.prog.yes2true(find_core(pl, 'Robust'));
    
    if robust
      f_data = robustRead(fid, f_data, columns, orig_col);
    else
      
      %%% Based on skipping the not used columns we have to transform the columns.
      %%% We must transform the columns [2 5 2 6 5 7] to [ 1 2 1 3 2 4]
      %%% In each loop we have to replace the corresponding value. In the first loop
      %%% the first minimum, in the second loop the second minimum, ... with the
      %%% current loop number.
      sort_col = sort(columns);
      for jj = 1:max(columns)
        if ismember(jj, columns)
          scan_format = [scan_format '%n'];
          read_col = read_col + 1;
          replace = min(sort_col);
          
          columns (columns == replace)  = read_col;
          sort_col(sort_col == replace) = [];
        else
          scan_format = [scan_format '%*n'];
        end
      end
      scan_format = [deblank(scan_format) '%*[^\n]'];
      
      %%%%%%%%%%   Read data   %%%%%%%%%%
      readlines = min(50000, maxLines);
      nlines    = 0;
      
      %%% read file to end
      while ~feof(fid) && nlines < maxLines
        
        if isempty(comment_char) && isempty(delimiter)
          C = textscan(fid, scan_format, readlines);
        elseif isempty(comment_char) && ~isempty(delimiter)
          C = textscan(fid, scan_format, readlines, 'Delimiter', delimiter);
        elseif ~isempty(comment_char) && isempty(delimiter)
          C = textscan(fid, scan_format, readlines, 'CommentStyle', comment_char);
        else
          C = textscan(fid, scan_format, readlines, 'CommentStyle', comment_char, 'Delimiter', delimiter);
        end
        
        if isempty(C{1}) 
          if nlines == 0
            error('\n### There are no data.\n### Did you use the right comment character?\n### The current comment character is: [%s]\n### Use a parameter list with the parameter:\n### plist(''comment_char'', ''%%'')', comment_char);
          else
            warning('### There were %d lines to read, but after %d the reading via textscan gave no other output. Quitting!', maxLines, nlines);
            break;
          end
        end
        
        f_data(nlines+1:nlines+size(C{1},1),:) = [C{:}];
        nlines = nlines + length(C{1});
        
        utils.helper.msg(utils.const.msg.PROC2, 'read %09d lines of %09d', nlines, maxLines);
      end
      
      %%% get only the data we want
      if size(f_data,1) > nlines
        f_data = f_data(1:nlines, :);
      end
    end
    
  catch ME
    % An error occurred during the scan
    fclose(fid);
    rethrow(ME);
  end
  
  % The scan was successful
  fclose(fid);
  
  
  %%%%%%%%%%   Create for each column pair the data object   %%%%%%%%%%
  
  % This is a list of keys which support multiple values. We need to
  % process the history plist to account for this so that the hisotry of a
  % single object only contains the value that the user intended that
  % object to get.
  % TODO: find a nicer way to specify this?
  keys = {'name', 'description', 'xunits', 'yunits', 't0'};
  
  if isempty(use_fs)
    
    %%%%%%%%%%   The numbers in columns must be even   %%%%%%%%%%
    if length(columns) == 1
      if ~strcmp(data_type, 'cdata')
        error('A single column file with no sample rate set can only be used to build a cdata AO');
      end
    else
      if mod(length(columns),2) ~= 0
        error('### The numbers in columns must be even or you forgot to specify the ''fs'' parameter');
      end
    end
    
    N = length(columns)/2;
    for lauf = 1:N
      
      data_x_axes = f_data(:, columns(lauf*2-1));
      data_y_axes = f_data(:, columns(lauf*2));
      
      % create data object corresponding to the parameter list
      ao_data = [];
      switch lower(data_type)
        case 'tsdata'
          ao_data = tsdata(data_x_axes, data_y_axes);
        case 'fsdata'
          ao_data = fsdata(data_x_axes, data_y_axes);
        case 'cdata'
          error('### This should not happen!');
        case 'xydata'
          ao_data = xydata(data_x_axes, data_y_axes);
        otherwise
          error('### unknown data type ''%s''', data_type);
      end
      aa = ao(ao_data);
      
      % set up the history plist for this object
      plhist = pl.processForHistory(N, lauf, keys);
      plhist.pset('columns', [orig_col(lauf*2-1) orig_col(lauf*2)]);
      
      % Add history
      aa.addHistory(mi, plhist, [], []);
      
      a = [a aa];
      
    end
    
    %%%%%%%%%%   Create for each column AND fs a data object   %%%%%%%%%%
  else % isempty(use_fs)
    
    N = length(columns);
    for lauf = 1:N
      
      data_y_axes = f_data(:, columns(lauf));
      
      % create data object corresponding to the parameter list
      ao_data = [];
      switch lower(data_type)
        case 'tsdata'
          ao_data = tsdata(data_y_axes, use_fs);
        case 'fsdata'
          ao_data = fsdata(data_y_axes, use_fs);
        case 'cdata'
          % Special case for cdata-objects.
          % Is the user specify some columns then he will get for each
          % column an AO. If don't specify a columns then he will all data
          % in a single AO.
          if isempty(pl.find_core('columns'))
            % Create only one AO with all data
            a = ao(f_data);
            a.name = fileName;
            a.addHistory(mi, pl, [], []);
            break
          else
            % Create for each column a single AO
            ao_data = cdata(data_y_axes);
          end
        case 'xydata'
          ao_data = xydata(data_y_axes);
        otherwise
          error('### unknown data type ''%s''', data_type);
      end
      aa = ao(ao_data);
      
      % set up the history plist for this object
      plhist = pl.processForHistory(N, lauf, keys);
      plhist.pset('columns', orig_col(lauf));
      
      % Add history
      aa.addHistory(mi, plhist, [], []);
      
      a = [a aa];
      
    end
    
  end
  
  % for tsdata and fsdata we support setting the t0
  if any(strcmpi(data_type, {'tsdata', 'fsdata'}))
    a.setT0(t0);
  end
  
  % set xunits if we don't have a cdata
  if ~strcmpi(data_type, 'cdata')
    xunits = pl.find_core('xunits');
    if isempty(xunits)
      if strcmpi(data_type, 'tsdata')
        xunits = 's';
      elseif strcmpi(data_type, 'fsdata')
        xunits = 'Hz';
      else
        % do nothing
      end
    end
    a.setXunits(xunits);
  end
  
  % Add the header Lines to the description
  if headerLines
    a.setDescription(firstStrs);
  end
  
  % set yunits
  a.setYunits(pl.find_core('yunits'));
  
  % Set object properties
  a.setObjectProperties(pl);
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    numLines
%
% SYNTAX:      count = numLines(fid);
%
% DESCRIPTION: Returns the number of lines in an ASCII file. This method
%              doesn't change the position of the file identifier (fid)
%
% HISTORY:     02-08-2002 Peter Acklam, CSSM post
%                 Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lines = numLines(fid)
  
  fidPos = ftell(fid);
  block = [];
  lines = 0;                           % number of lines in file
  nlchr = uint8(sprintf('\n'));        % newline chr as uint8
  bsize = 4 * 256 * 8192;              % block size to read
  
  while ~feof(fid)
    block = fread(fid, bsize, '*uint8');
    lines = lines + sum(block == nlchr);
  end
  if ~isempty(block)                   % in case file is empty
    lines = lines + double(block(end) ~= nlchr);
  end
  fseek(fid, fidPos, 'bof');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    numCols
%
% SYNTAX:      count = numCols(fid);
%
% DESCRIPTION: Returns the number of columns in an ASCII file. This method
%              doesn't change the position of the file identifier (fid)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ncols = numCols(fid, delimiter)
  
  fidPos = ftell(fid);
  line = fgetl(fid);
  if ischar(line)
    if nargin == 1 || isempty(delimiter)
      C = textscan(line, '%s');
    else
      C = textscan(line, '%s', 'Delimiter', delimiter);
    end
    C = C{1};
    ncols = numel(C);
  else
    ncols = 0;
  end
  fseek(fid, fidPos, 'bof');
end


% A robust and slow data reader
function f_data = robustRead(fid, f_data, columns, orig_cols)
  
  cols = unique(columns);
  ocols = unique(orig_cols);
  Nline = 1;
  while ~feof(fid)
    % read and parse line
    tokens = sscanf(fgets(fid), '%f');
    % parse tokens
    if ~isempty(tokens)
      f_data(Nline, cols) = tokens(ocols);
      if mod(Nline, 1000) == 0
        utils.helper.msg(utils.const.msg.PROC2, 'lines read: %d', Nline);
      end
      Nline = Nline + 1;
    end
  end
  
  % drop empty lines
  f_data = f_data(1:Nline-1, :);
  
end
