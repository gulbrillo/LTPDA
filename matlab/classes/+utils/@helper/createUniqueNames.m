% CREATEUNIQUENAMES This function make sure that the input cell contains only unique strings.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CREATEUNIQUENAMES This function make sure that the input
%              cell contains only unique strings.
%
% CALL:        outCellStr = createUniqueNames(inCellStr)
%
% INPUTS:      inCellStr: Cell with strings 
%
% EXAMPLE:     With the following intput
%              {'obj1'    'obj11'    'obj2'    'obj1'    'obj2'}
%              is the output
%              {'obj1'    'obj11'    'obj2'    'obj1_2'    'obj2_1'}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outNames = createUniqueNames(inNames)
  if ~iscell(inNames)
    error('### The input of this function must be a cell array but it is from the class [%s]', class(inNames));
  end
  
  outNames = inNames;
  
  for i = 1:numel(inNames)
    inName = inNames{i};
    
    % Calc number of dups within the candidates
    numPrecedingDups = numel(find(strcmp(inName, inNames(1:i-1))));
    
    % See if unique candidate is indeed unique - if not up the
    % numPrecedingDups
    if numPrecedingDups > 0
      uniqueName = sprintf('%s_%d', inName, numPrecedingDups);
      % Make sure that we don't append
      while any(strcmp(uniqueName, inNames))
        numPrecedingDups = numPrecedingDups + 1;
        uniqueName = sprintf('%s_%d', inName, numPrecedingDups);
      end
      outNames{i} = uniqueName;
    end
  end
end
