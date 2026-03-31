%CELL2STR Convert a 2-D cell array to a string in MATLAB syntax.
%   STR = CELL2STR(CELLSTR) converts the 2-D CELLSTR to a
%   MATLAB string so that EVAL(STR) produces the original cell-array.
%   Works as corresponding MAT2STR but for cell array instead of
%   scalar matrices.
%
%   Example
%       cellstr = {'U-234','Th-230'};
%       cell2str(cellstr) produces the string '{''U-234'',''Th-230'';}'.
%
%   See also MAT2STR, STRREP, CELLFUN, EVAL.
%   Developed by Per-Anders Ekstr?m, 2003-2007 Facilia AB.
%
%   Modified by Nicola Tateo for the LTPDA toolbox, to work also with cell
%   arrays of numbers and to remove the last ';'
%
function string = cell2str(cellstr)
  
  if nargin~=1
    error('CELL2STR:Nargin','Takes 1 input argument.');
  end
  if ischar(cellstr)
    string = ['''' strrep(cellstr,'''','''''') ''''];
    return
  end
  if ndims(cellstr)>2
    error('CELL2STR:TwoDInput','Input cell array must be 2-D.');
  end
  
  if isempty(cellstr)
    string = '{}';
  else
    if iscellstr(cellstr)
      ncols = size(cellstr,2);
      for i=1:ncols-1
        output(:,i) = cellfun(@(x)['''' strrep(x,'''','''''') ''', '],...
          cellstr(:,i),'UniformOutput',false);
      end
      if ncols>0
        output(:,ncols) = cellfun(@(x)['''' strrep(x,'''','''''') ''';'],...
          cellstr(:,ncols),'UniformOutput',false);
      end
      output = output';
      output{numel(output)}(numel(output{numel(output)})) = [];
      string = ['{' output{:} '}'];
    else
      output = mat2str(cell2mat(cellstr));
      if numel(output)>1, string = ['{',output(2:numel(output)-1),'}'];
      else string = ['{',output,'}'];
      end
    end
  end
end
