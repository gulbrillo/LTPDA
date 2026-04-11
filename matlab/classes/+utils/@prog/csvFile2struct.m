% CSVFILE2STRUCT Reads a CSV file into a structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CSVFILE2STRUCT Reads a CSV file into a structure.
%
% CALL:       s = utils.prog.csvFile2struct(filename)
%             s = utils.prog.csvFile2struct(filename, fieldnames)
%             s = utils.prog.csvFile2struct(filename, comment-char)
%             s = utils.prog.csvFile2struct(filename, fieldnames, comment-char)
%
% INPUTS:     filename     - CSV file name.
%             fieldnames   - Cell array of field names for building the
%                            structure. In this case reads the function the
%                            struct from the first row.
%             comment-char - Comment character
%
% ATTENTION:  If you provide filenames then reads this method the structure
%             from the first row. If you don't provide the field names then
%             must be the field names in the first row.
%
% OUTPUTS:    s - MATLAB Structure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allStructs = csvFile2struct(varargin)
  
  % Check input arguments
  nIn = nargin;
  fNames = {};
  commentChar = '#';
  if nargin == 1 && ischar(varargin{1})
    filename = varargin{1};
    
  elseif nIn == 2 && ischar(varargin{1}) && iscellstr(varargin{2})
    filename = varargin{1};
    fNames   = varargin{2};
  
  elseif nIn == 2 && ischar(varargin{1}) && length(varargin{2})==1 && ischar(varargin{2}) 
    filename    = varargin{1};
    commentChar = varargin{2};
    
  elseif nIn == 3 && ischar(varargin{1}) && iscellstr(varargin{2}) && length(varargin{3})==1 && ischar(varargin{3}) 
    filename    = varargin{1};
    fNames      = varargin{2};
    commentChar = varargin{3};
  
  else
    strArgs = cellfun(@(s) sprintf('''%s'' [%dx%d]', class(s), size(s)), varargin, 'uniformOutput', false);
    strArgs = utils.prog.strjoin(strArgs);
    help(mfilename('fullpath'));
    error('Wrong input arguments. %s', strArgs);
  end
  
  % Open file
  [fid, msg] = fopen (filename, 'r');
  if (fid < 0)
    error ('Can not open file: %s \nError msg: %s', filename, msg);
  end
  c = onCleanup(@()fclose(fid));
  
  % Check if we get the field names from the file
  if isempty(fNames)
    fNames = parseRow(fgetl(fid));
  end
  
  % Check if all field names are valid
  if ~all(cellfun(@isvarname, fNames))
    idx = cellfun(@isvarname, fNames);
    notValid = strtrim(sprintf('[%s], ', fNames{~idx}));
    error('There are not valid field names %s.\nEither in the first row of the file or in the input arguments.', notValid(1:end-1));
  end
  
  % Read rwos inot a structure
  allStructs = [];
  while ~feof(fid)
    rowStr = strtrim(fgetl(fid));
    if ~isempty(rowStr) && rowStr(1) ~= commentChar
      cellOut = parseRow(rowStr);
      allStructs = [allStructs cell2struct(cellOut, fNames, 2)];
    end
  end
  
end

function cellOut = parseRow(inStr)
  
  % Define regular expression
  reg = '(("([^"]*)"|{.*})|[^,]*)(,|$)';
  % I try to explain the regular expression:
  %  First nested bracket (("([^"]*)"|{.*})|[^,]*) -> OR conditions
  %   - Collect everything inside quotes " ... "
  %   - Collect everything inside curly brackets { ... }
  %   - Collect everything what is not a comma ,
  %  Second nested bracket (,|$) -> OR condition
  %   - Look for a comma ,
  %   - Look for the end of line \n
  cellOut = regexp(inStr, reg, 'match');
  
  % Remove trailing comma
  cellOut = regexprep(cellOut, ',$', '');
  
  % Convert the string back to a value
  cellOut = cellfun(@str2val, cellOut, 'UniformOutput', false);
  
end

function val = str2val(inStr)
  % Here do we define which data type we support
  if inStr(1)=='"' && inStr(end)=='"'
    % String value
    val = inStr(2:end-1);
  elseif inStr(1)=='{' && inStr(end)=='}'
    % Cell string
    val = eval(inStr);
  elseif inStr(1) =='[' && inStr(end)==']'
    % Numeric array
    val = str2num(inStr);
  elseif regexp(inStr, '^[+-]?\d*\.?\d+$')
    % Single double
    val = str2double(inStr);
  else
    val = inStr;
  end
end



