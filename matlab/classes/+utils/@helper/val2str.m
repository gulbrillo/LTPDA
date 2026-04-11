% VAL2STR converts each value into a string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: VAL2STR converts each value into a string.
%
% CALL:        string = val2str(val)
%              string = val2str(val, MAX_DISP);
%
% PARAMETERS:  val:      value which should be converted into a string.
%              MAX_DISP: maximum string size. [default: 6000]
%
% REMARK:      In a cell have each element the MAX_DISP size.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = val2str(varargin)
  
  if nargin == 1
    val      = varargin{1};
    MAX_DISP = 6000;
  elseif nargin == 2
    val      = varargin{1};
    MAX_DISP = varargin{2};
  else
    error('### Unknown number of inputs');
  end
  
    
  if ischar(val)
    %%%%%%%%%%   character   %%%%%%%%%%
    
    valStr = fitStr(sprintf('''%s''', val), MAX_DISP);
    
  elseif isnumeric(val) || islogical(val)
    %%%%%%%%%%   numbers   %%%%%%%%%%
    if isvector(val)
      if length(val) == 1 && isreal(val)
        valStr = sprintf('%.17g', val);
      else
        %%% Number is a vector or a complex number
        valStr = fitStr(utils.helper.mat2str(val), MAX_DISP);
        if numel(valStr) > 3 && strcmp(valStr(end-2:end), '...')
          valStr = sprintf('%s]', valStr);
        end
      end
    elseif isempty(val)
      valStr = '[]';
    else
      %%% Number is a matrix
      valStr = fitStr(mat2str(val), MAX_DISP);
      valStr = sprintf('[%dx%d], (%s)', size(val), valStr);
      if numel(valStr) > 3 && strcmp(valStr(end-2:end), '...')
        valStr = sprintf('%s]', valStr);
      end
    end
    
  elseif iscell(val)
    %%%%%%%%%%   cell   %%%%%%%%%%
    if ~isempty(val)
      valStr = '{';
      for ii = 1:length(val)
        valStr = sprintf('%s%s, ', valStr, utils.helper.val2str(val{ii}, MAX_DISP));
      end
      
      valStr = sprintf('%s}', valStr(1:end-2));
    else
      valStr = sprintf('{} [%dx%d]', size(val));
    end
    %%%%%%%%%%%%% symbols %%%%%%%%%%%%
  elseif isa(val, 'sym')
    valStr = fitStr(char(val), MAX_DISP);
    
  elseif isa(val, 'history')
    %%%%%%%%%%   history objects   %%%%%%%%%%
    valStr = char(val); % sprintf('%dx[%s.hist]', numel(val), valStr{1});
    
  elseif isa(val, 'provenance')
    %%%%%%%%%%   provenance objects   %%%%%%%%%%
    valStr = sprintf('%s %s', val.creator, val.ltpda_version);
    
  elseif isa(val, 'database')
    valStr = sprintf('database-object: %s', val.Instance);
    
  elseif isa(val, 'matlab.ui.Figure')
    valStr = sprintf('Figure Handle %g', double(val));
  elseif isobject(val)
    %%%%%%%%%%   all other objects objects   %%%%%%%%%%
    try
      valStr = char(val);
    catch
      valStr = sprintf('%g', double(val));
    end
  elseif isjava(val)
    %%%%%%%%%%   java objects   %%%%%%%%%%
    valStr = class(val);
    
  elseif isa(val, 'function_handle')
    %%%%%%%%%%   function handle   %%%%%%%%%%
    valStr = sprintf('function handle: %s', func2str(val));
    
  else
    valStr = sprintf('%dx%d [%s]', size(val,1), size(val,2), class(val));
  end
  
  if iscell(valStr)
    valStr = utils.prog.cell2str(valStr);
  end
  
  varargout{1} = valStr;
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fitStr
%
% DESCRIPTION: Fits the string to the maximum displayed characters.
%
% HISTORY:     15-06-2009 Diepholz
%                 Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = fitStr(str, MAX_DISP)
  if length(str) > MAX_DISP
    str = sprintf('%s ...', str(1:MAX_DISP));
  end
end
