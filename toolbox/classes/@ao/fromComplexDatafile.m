% FROMCOMPLEXDATAFILE Construct an AO from filename AND parameter list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromDatafile
%
% DESCRIPTION: Construct an AO from filename AND parameter list
%
% CALL:        a = fromComplexDatafile(a, pli)
%
% PARAMETER:   a:   empty ao-object
%              pli: plist-object (must contain the filename)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function objs = fromComplexDatafile(ain, pli)
  
  utils.helper.msg(utils.const.msg.PROC1, 'loading complex data from filename and/or plist');
  
  
  % get AO info
  mi = ao.getInfo('ao', 'From Complex ASCII File');
  
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
  pl = applyDefaults(mi.plists, pli);
  
  pl = pset(pl, 'filename', fileName);
  pl = pset(pl, 'filepath', filePath);
  
  data_type    = find_core (pl, 'type');
  columns      = find_core (pl, 'columns');
  comment_char = find_core (pl, 'comment_char');
  orig_col     = columns; % necessary for the histroy
  objs         = [];
  
  %%%%%%%%%%   read file   %%%%%%%%%%
  [fid,msg] = fopen (absolutePathname, 'r');
  if (fid < 0)
    error ('### can not open file: %s \n### error msg: %s', fileName, msg);
  end
  
  %%%%%%%%%%   create scan format: '%f %f %f %f %f %*[^\n]'   %%%%%%%%%%
  scan_format = '';
  read_col    = 0;
  sort_col    = sort(columns);
  
  %%%%%%%%%%   Get/Count max number of lines   %%%%%%%%%%
  maxLines = numlines(fid);
  utils.helper.msg(utils.const.msg.PROC2, 'Counting lines: %d', maxLines);
  fseek(fid, 0, 'bof');
  
  %%%%%%%%%%   Read data   %%%%%%%%%%
  readlines = min(50000, maxLines);
  nlines    = 0;
  
  %%% Based on skipping the not used columns we have to transform the columns.
  %%% We must transform the columns [ 2 5 2 6 5 7] to [ 1 2 1 3 2 4]
  %%% In each loop we have to replace the corresponding value. In the first loop
  %%% the first minimum, in the second loop the second minimum, ... with the
  %%% current loop number.
  for j=1:max(columns)
    if ismember(j, columns)
      scan_format = [scan_format '%n '];
      read_col = read_col + 1;
      replace = min(sort_col);
      
      columns (columns==replace)  = read_col;
      sort_col(sort_col==replace) = [];
    else
      scan_format = [scan_format '%*n '];
    end
  end
  scan_format = [deblank(scan_format) '%*[^\n]'];
  
  %%% preallocate data array
  f_data = zeros(maxLines, read_col);
  
  %%% check if using robust read: 'yes'/'no' or true/false or 'true'/'false'
  robust = find_core(pl, 'Robust');
  if isempty(robust)
    robust = false;
  elseif ischar(robust)
    if strcmpi(robust, 'yes') || strcmpi(robust, 'true')
      robust = true;
    else
      robust = false;
    end
  end
  
  if robust
    
    f_data = robustRead(fid, f_data, columns, orig_col);
    
  else
    
    %%% Look for the first line of data
    if ~isempty(comment_char)
      while ~feof(fid)
        f = deblank(fgetl(fid));
        if ~isempty(f)
          if f(1) ~= comment_char
            break;
          end
        end
      end
    else
      f = deblank(fgetl(fid));
    end
    
    %%% Scan it to find how many columns we have in the file
    C = textscan(f, scan_format, 1, 'CollectOutput', 1);
    if any(isnan(C{:}))
      error('### Error in file format. Perhaps you specified more columns than the file contains?');
    end
    
    fseek(fid, 0, 'bof');
    %%% read file to end
    while ~feof(fid) && nlines < maxLines
      
      if isempty(comment_char)
        C = textscan(fid, scan_format, readlines, ...
          'CollectOutput', 1);
      else
        C = textscan(fid, scan_format, readlines, ...
          'CommentStyle', comment_char, ...
          'CollectOutput', 1);
      end
      f_data(nlines+1:nlines+size(C{1},1),:) = C{1};
      nlines = nlines + length(C{1});
      
      if isempty(C{1})
        error('\n### There are no data.\n### Did you use the right comment character?\n### The current comment character is: [%s]\n### Use a parameter list with the parameter:\n### plist(''comment_char'', ''%%'')', comment_char);
      end
      utils.helper.msg(utils.const.msg.PROC2, 'read %09d lines of %09d', nlines, maxLines);
      
    end
    fclose(fid);
    
    %%% get only the data we want
    if size(f_data,1) > nlines
      f_data = f_data(1:nlines, :);
    end
  end
  
  
  %%%%%%%%%%   Create for each three columns the data object   %%%%%%%%%%
  
  %%%%%%%%%%   The numbers in columns must be straight   %%%%%%%%%%
  if mod(length(columns),3) ~= 0
    error('### The numbers in columns must be multiple of three.');
  end
  
  complex_type = pl.find_core('complex_type');
  
  for lauf = 1:length(columns)/3
    
    data_x   = f_data(:, columns(lauf*3-2));
    data_y_1 = f_data(:, columns(lauf*3-1));
    data_y_2 = f_data(:, columns(lauf*3));
    
    if strcmpi(complex_type, 'abs/deg')
      data_y = data_y_1 .* exp(1i*data_y_2*pi/180);
      
    elseif strcmpi(complex_type, 'dB/deg')
      data_y = 10.^(data_y_1./20) .* exp(1i*data_y_2*pi/180);
      
    elseif strcmpi(complex_type, 'abs/rad')
      data_y = data_y_1 .* exp(1i*data_y_2);
      
    elseif strcmpi(complex_type, 'dB/rad')
      data_y = 10.^(data_y_1./20) .* exp(1i*data_y_2);
      
    elseif strcmpi(complex_type, 'real/imag')
      data_y = complex(data_y_1, data_y_2);
      
    else
      error('### I can not handle real [%s] and imaginary [%s].', real_type, imag_type);
    end
    
    % create data object corresponding to the parameter list
    ao_data = [];
    switch lower(data_type)
      case 'tsdata'
        ao_data = tsdata(data_x, data_y);
      case 'fsdata'
        ao_data = fsdata(data_x, data_y);
      case 'cdata'
        error('### Please code me up');
      case 'xydata'
        ao_data = xydata(data_x, data_y);
      otherwise
        error('### unknown data type ''%s''', data_type);
    end
    aa = ao(ao_data);
    % overide the default name
    if isempty(pl.find_core('name'))
      pl.pset('name', sprintf('%s_%02d_%02d_%02d', fileName, orig_col(lauf*3-2), orig_col(lauf*3-1), orig_col(lauf*3)));
    end
    
    % set units
    aa.setXunits(pl.find_core('xunits'));
    aa.setYunits(pl.find_core('yunits'));
    
    % Add history
    pl = pl.pset('columns', [orig_col(lauf*3-2) orig_col(lauf*3-1) orig_col(lauf*3)]);
    aa.addHistory(mi, pl, [], []);
    
    objs = [objs aa];
    
  end
  
  % set any object properties now
  objs.setObjectProperties(pl);
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    numlines
%
% SYNTAX:      count = numlines(fid);
%
% DESCRIPTION: Number of lines in an ASCII file
%
% HISTORY:     02-08-2002 Peter Acklam, CSSM post
%                 Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lines = numlines(fid)
  
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
end

% A robust and slow data reader
function f_data = robustRead(fid, f_data, columns, orig_cols)
  
  cols  = unique(columns);
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
