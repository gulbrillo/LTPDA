% replaceString changes the input string accordingly to a predefined list of rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CONVERTCOMSTRING hanges the input string accordingly to a
%              predefined list of rules, to convert between MATLAB, MUPAD
%              and MATHEMATICA command string syntax.
%              This supports conversions: MATLAB <-> MUPAD
%                                         MATLAB <-> MATHEMATICA
%
% CALL:        output = convertComString('string', conversion);
%
% PARAMETERS:
%              conversion     A string defining the conversion:
%                           - 'ToSymbolic'       MATLAB --> Symbolic (MUPAD)
%                           - 'ToMathematica'    MATLAB --> MATHEMATICA
%                           - 'FromSymbolic'    MUPAD (Symbolic) --> MATLAB
%                           - 'FromMathematica'  MATHEMATICA --> MATLAB
%
% EXAMPLES:
%              output = convertComString('(a.*b).*sin(pi)','ToMathematica')
%              output = convertComString('Sin[3*Pi]/Cos[Pi]','FromMathematica')
%              output = convertComString('(a.*b).*sin(pi)','ToSymbolic')
%              output = convertComString('sin(3*PI)/cos(PI)','FromSymbolic')
%              output = convertComString('PI*sin(3*PI)/cos(PI)','FromSymbolic')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = convertComString(varargin)
  
  output = varargin{1};
  direct = varargin{2};
  
  % Generic substitutions (tipically the bidirectional ones, such as unique
  % combinations of chars) are defined in the following list.
  % Perticular substitutions (such as the imaginary 'i', but not the 'i'
  % inside a string) are performed preliminarly in the preliminaryCheck
  % function.
  
  % Rules to/from MATHEMATICA:
  % These rules are bidirectional;
  mathematicaRule = {...
    './' , '/'  ; ...
    '.*' , '*' ; ...
    '.^' , '^' ; ...
    };
  
  % Rules to/from MUPAD:
  % These rules are bidirectional;
  mupadRule = {...
    './' , '/' ; ...
    '.*' , '*' ; ...
    '.^' , '^' ; ...
    '1I' , 'I' ; ...
    };
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  switch lower(direct)
    case 'tosymbolic'
      rule = mupadRule;
      output = preliminaryCheckSymb(output,1);
      direction = 1;
    case 'tomathematica'
      rule = mathematicaRule;
      output = preliminaryCheckMath(output,1);
      direction = 1;
    case 'fromsymbolic'
      rule = mupadRule;
      output = preliminaryCheckSymb(output,2);
      direction = 0;
    case 'frommathematica'
      rule = mathematicaRule;
      output = preliminaryCheckMath(output,2);
      direction = 0;
    otherwise
      error('*** ''conversion'' parameter not recognized.')
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Now performs the standard substitution, according to the rule matrix:
  if direction % from Matlab
    for ii=1:size(rule,1)
      output = strrep(output,rule{ii,1},rule{ii,2});
      output = regexprep(output, '([0-9]+)I', '$1*I');
    end
  else         % to Matlab
    for ii=1:size(rule,1)
      output = strrep(output,rule{ii,2},rule{ii,1});
    end
  end
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  function myout = preliminaryCheckMath(mystr,mynumb)
    % Performs a list of complex substitutions:
    % - search for function names and substitute the corresponding
    %   parentheses; for example, sin(...) --> Sin[...]
    % - search for e (as in 4E5) and converts in 10^ .
    % - search for i (as in 2+4i) and converts in I.
    % - search for pi (not inside strings) and converts in Pi.
    %
    % Parameter: mynumb = 1 MATLAB --> MATHEMATICA,
    %                   = 2 MATHEMATICA --> MATLAB
    %
    
    if mynumb ==1 % MATLAB --> MATHEMATICA
      % 'e' substitution:
      idx = regexp(mystr, '\de\d') + 1;
      for m = numel(idx):-1:1, mystr = [mystr(1:idx(m)-1) '10^' mystr(idx(m)+1:end)]; end
      % 'i' substitution:
      idx = cell2mat(regexp(mystr, {'\di','\*i'}))  + 1;
      for m = numel(idx):-1:1, mystr = [mystr(1:idx(m)-1) '*I' mystr(idx(m)+1:end)]; end
      % 'pi' substitution:
      idx = regexp(mystr,'\Wpi') + 1;
      for m = numel(idx):-1:1, mystr(idx(m)) = 'P'; end
      
    else          % MATHEMATICA --> MATLAB
      % 'i' substitution:
      idx = cell2mat(regexp(mystr, {'\dI','\*I'}))  + 1;
      for m = numel(idx):-1:1, mystr = [mystr(1:idx(m)-1) '*i' mystr(idx(m)+1:end)]; end
      % 'pi' substitution:
      idx = regexp(mystr,'\WPi') + 1;
      for m = numel(idx):-1:1, mystr(idx(m)) = 'p'; end
      
    end
    
    funcList = {'sin','cos','exp','sqrt','abs'; ...
      'Sin','Cos','Exp','Sqrt','Abs'};
    if mynumb==1
      par = {'(',')' ; '[',']'};
    else par = {'[',']' ; '(',')'};
    end
    
    for j=1:size(funcList,2)
      idx = strfind(mystr,funcList{mynumb,j});
      if ~isempty(idx)
        for jj=numel(idx):-1:1
          startIdx = idx(jj)+numel(funcList{mynumb,j}); % this is the index of the opening parenthesys
          k = startIdx+1; openPar = 0;
          while k~=0
            if k>numel(mystr), endIdx = k-1; break; end
            if mystr(k)==par{1,2} && openPar == 0
              endIdx = k;
              break
            elseif  mystr(k)==par{1,2} && openPar == 1
              openPar = openPar-1;
            elseif mystr(k)==par{1,1}
              openPar = openPar+1;
            end
            k = k+1;
          end
          % now startIdx e endIdx are the indexes of the parentheses
          mystr(startIdx)= par{2,1};
          mystr(endIdx)  = par{2,2};
          temp = funcList;
          temp(mynumb,:) = [];
          mystr(idx(jj):idx(jj)+numel(temp{j})-1) = temp{j};
        end
      end
    end
    myout = mystr;
    
  end
  
  function myout = preliminaryCheckSymb(mystr,mynumb)
    % Performs a list of complex substitutions:
    % - search for i (as in 2+4i) and converts in I.
    % - search for pi (not inside strings) and converts in Pi.
    %
    % Parameter: mynumb = 1 MATLAB --> Symbolic (MUPAD),
    %                   = 2 Symbolic (MUPAD) --> MATLAB
    %
    
    if mynumb ==1 % MATLAB --> Symbolic (MUPAD)
      % 'i' substitution:
      idx = cell2mat(regexp(mystr, {'\di','\*i'}))  + 1;
      for m = numel(idx):-1:1, mystr(idx(m)) = 'I'; end
      % 'pi' substitution:
      idx = regexp(mystr,'\Wpi') + 1;
      for m = numel(idx):-1:1, mystr(idx(m)) = 'P'; mystr(idx(m)+1) = 'I';end
      
    else          % Symbolic (MUPAD) --> MATLAB
      % 'i' substitution:
      idx = cell2mat(regexp(mystr, {'\dI','\*I'}))  + 1;
      % for m = numel(idx):-1:1, mystr = [mystr(1:idx-1) '*i' mystr(idx+1:end)]; end
      mystr(idx)='i';
      % 'pi' substitution:
      idx = regexp(mystr,'PI\W*');
      for m = numel(idx):-1:1, mystr(idx(m)) = 'p'; mystr(idx(m)+1) = 'i';end
      
    end
    
    myout = mystr;
    
  end
    
end
