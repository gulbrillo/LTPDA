% STRUCT2CSVFILE Saves a structure as a CSV file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRUCT2CSVFILE Saves a structure as a CSV file.
%
% CALL:       utils.prog.struct2csvFile(s, filename)
%
% INPUTS:     s        - A structure
%             filename - A file name for the CSV file
%
% OUTPUTS:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function struct2csvFile(varargin)
  
  % Check input arguments
  if nargin~=2 || ~isstruct(varargin{1}) || ~ischar(varargin{2})
    strArgs = cellfun(@(s) sprintf('''%s'' [%dx%d]', class(s), size(s)), varargin, 'uniformOutput', false);
    strArgs = utils.prog.strjoin(strArgs);
    help(mfilename('fullpath'));
    error('Wrong input arguments. %s', strArgs);
  end
  
  % Get Inputs
  s        = varargin{1};
  filename = varargin{2};
  
  % Check file extension and change if necessary to .csv
  [fpath, fname, fext] = fileparts(filename);
  if ~strcmpi(fext, '.csv')
    warning('Change file extension from [%s] to [.csv]', fext);
    filename = fullfile(fpath, strcat(fname, '.csv'));
  end
  
  % Check if file already exist
  if exist(filename, 'file')
    reply = input(sprintf('File [%s] already exists.\nDo you want to overwrite it? Y/N [Y]:', filename), 's');
    if strcmpi(reply, 'N')
      disp('*****   User canceled action.   *****');
      return
    end
  end
  
  % Open file
  [fid, msg] = fopen (filename, 'w');
  if (fid < 0)
    error ('Can not open file: %s \nError msg: %s', filename, msg);
  end
  c = onCleanup(@()fclose(fid));
  
  % Get field names from the structure
  fNames = fieldnames(s);
  
  % Write field names of the structure to the first column
  firstRow = sprintf('"%s",',fNames{:});
  firstRow = firstRow(1:end-1);
  fprintf(fid, '%s\n', firstRow);
  
  for nn=1:numel(s)
    
    rowStr = '';
    for ff = 1:numel(fNames)-1
      fName = fNames{ff};
      rowStr = strcat(rowStr, val2str(s(nn).(fName)), ',');
    end
    % Add last value
    rowStr = strcat(rowStr, val2str(s(nn).(fNames{end})));
    fprintf(fid, '%s\n', rowStr);
  end
  
end

function str = val2str(in)
  % Here do we define which data type we support
  if ischar(in)
    str = sprintf('"%s"', in);
  elseif iscellstr(in)
    str = utils.prog.cell2str(in);
  elseif isnumeric(in)
    str = utils.helper.mat2str(in);
  elseif islogical(in)
    str = utils.helper.mat2str(double(in));
  else
    error('This method doesn''t support the data type [%s]. Please code me up and don''t forget utils.prog.csvFile2struct.', class(in));
  end
end



