% DOSUBSPARAMETERS enables to substitute symbollic patameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DOSUBSPARAMETERS enables the substitution of symbolic
%              parameters. This private method does the work of
%              subsParameters and keepParameters.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sys = doSubsParameters(sys, subsnames, callerIsMethod)
  % checking whether any work need be done at all
  if sys.params.nparams==0 || numel(subsnames)==0
    return
  end
  sysNames = sys.params.getKeys;
  wasFound = false(size(subsnames));
  removeParams = false(size(sysNames)); 
  
  % If we have any matrices containing symbolic parameters, then we go
  % ahead and declare all parameters symbolic
  if hasSymbols(sys)
    % declaring and evaluating parameters to substitute
    for j=1:numel(sysNames)
      pname = sysNames{j};
      indices = strcmpi(subsnames, pname);
      cmd1 = [pname '=sym(''', pname, ''');'];
      
      if sum(indices)>0
        % remebering parameter match was found for this entry
        wasFound(indices) = indices(indices);
        % remembering parameter to move
        removeParams(j) = true;
        
        val = sys.params.params(j).getVal;
        if isa(val, 'plist')
          val = find(val, 'value');
        end
        cmd2 = [pname '=' utils.helper.num2str(val) ';'];
        eval(cmd1);
        eval(cmd2);
      else
        eval(cmd1);
      end
    end
  else
    % This means we have no symbolic matrix elements, so we can just
    % declare local double variables. This works after you call
    % ssm/optimiseForFitting on the model.
    for j=1:numel(sysNames)
      pname = sysNames{j};
      indices = strcmpi(subsnames, pname);
      
      if sum(indices)>0
        % remebering parameter match was found for this entry
        wasFound(indices) = indices(indices);
        % remembering parameter to move
        removeParams(j) = true;
        
        val = sys.params.params(j).getVal;
        if isa(val, 'plist')
          val = find(val, 'value');
        end
        cmd2 = [pname '=' utils.helper.num2str(val) ';'];
        eval(cmd2);
      end
    end    
    
  end
  
  

  % moving substituted parameters
  if callerIsMethod
    % do nothing, since this implies the object will be thrown away
  else
    sys.numparams.append(sys.params.params(removeParams));
    sys.params.remove(removeParams);
  end
  
  % warning if a parameter was not found in the symbolic parameter
  if sum(~wasFound)>0
    str = ['warning!! parameters : ' subsnames(~wasFound) ' were not found in ' sys.name];
    str = char(str);
    display(str);
  end
  
  % evaluation of A, B, C, D matrices
  for i_ss=1:sys.Nss
    % A Matrix
    for j_ss =1:sys.Nss
      if ~isempty(sys.amats{i_ss, j_ss}) && ~isnumeric(sys.amats{i_ss, j_ss})
        sys.amats{i_ss, j_ss} = evalsym(sys.amats{i_ss, j_ss});
      end
    end
    % B Matrix
    for j_in =1:sys.Ninputs
      if ~isempty(sys.bmats{i_ss, j_in}) && ~isnumeric(sys.bmats{i_ss, j_in})
        sys.bmats{i_ss, j_in} = evalsym(sys.bmats{i_ss, j_in});
      end
    end
  end
  for i_out=1:sys.Noutputs
    % C Matrix
    for j_ss =1:sys.Nss
      if ~isempty(sys.cmats{i_out, j_ss}) && ~isnumeric(sys.cmats{i_out, j_ss})
        sys.cmats{i_out, j_ss} = evalsym(sys.cmats{i_out, j_ss});
      end
    end
    % D Matrix
    for j_in =1:sys.Ninputs
      if ~isempty(sys.dmats{i_out, j_in}) && ~isnumeric(sys.dmats{i_out, j_in})
        sys.dmats{i_out, j_in} = evalsym(sys.dmats{i_out, j_in});
      end
    end
  end
  
end

function out = hasSymbols(sys)
  
  out = false;
  if recursiveAny(cellfun('isclass', sys.amats, 'sym'))
    out = true;
    return;
  end
  
  if recursiveAny(cellfun('isclass', sys.bmats, 'sym'))
    out = true;
    return;
  end
  
  if recursiveAny(cellfun('isclass', sys.cmats, 'sym'))
    out = true;
    return;
  end
  
  if recursiveAny(cellfun('isclass', sys.dmats, 'sym'))
    out = true;
    return;
  end
  
end

function out = recursiveAny(in)
  
  while numel(in)>1
    in = any(in);
  end
  
  out = in;
  
end

function e = evalsym(s)
  
  if ischar(s)
    cmat = map2mat(s);
  else
    cmat = map2mat(char(s));
  end

  % '^', '*' or '/'
  vmat = strrep(cmat, '^', '.^');
  vmat = strrep(vmat, '*', '.*');
  vmat = strrep(vmat, '/', './');
  vmat(strfind(vmat,'..')) = [];
  
  e = evalin('caller', vmat); 
  
end

function r = map2mat(r)
  % MAP2MAT Maple to MATLAB string conversion.
  %   MAP2MAT(r) converts the Maple string r containing
  %   matrix, vector, or array to a valid MATLAB string.
  %
  %   Examples: map2mat(matrix([[a,b], [c,d]])  returns
  %             [a,b;c,d]
  %             map2mat(array([[a,b], [c,d]])  returns
  %             [a,b;c,d]
  %             map2mat(vector([[a,b,c,d]])  returns
  %             [a,b,c,d]
  
  % Deblank.
  r(strfind(r,' ')) = [];
  % Remove matrix, vector, or array from the string.
  r = strrep(r,'matrix([[','['); r = strrep(r,'array([[','[');
  r = strrep(r,'vector([','['); r = strrep(r,'],[',';');
  r = strrep(r,']])',']'); r = strrep(r,'])',']');
  % Special case of the empty matrix or vector
  if strcmp(r,'vector([])') || strcmp(r,'matrix([])') || ...
      strcmp(r,'array([])')
    r = [];
  end
end
