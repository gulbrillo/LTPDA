% VALIDATE Completes and checks the content a ssm object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Completes and checks the content a ssm object
%              checks consitency of sizes, class appartenance of fields.
%              completes some missing fields.
%
% CALL:        ssmin.validate
%              This function is private. To check and copy an object use
%              obj = ssm(old) instead
%
% INPUT VALUES : ssmin = ssm_matrix, ssm list
% OUTPUT VALUES : one ssm matrix, copy or handle to the inputs
%
% NOTE: This private method does not add history.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = validate(varargin)
  %% starting initial checks
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  % Collect all SSMs
  sys = utils.helper.collect_objects(varargin(:), 'ssm');
  
  % use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;

  % Decide on a deep copy or a modify, depending on the output
  sys = copy(sys, nargout);
  
  %% begin function body
  
  for i_sys = 1:numel(sys) % going through the input
    
    % load some data
    inputsizes = sys(i_sys).inputsizes;
    statesizes = sys(i_sys).statesizes;
    outputsizes = sys(i_sys).outputsizes;
    
    %% =========== generating missing user defined fields ===========
    
    % data with linear system matrices
    
    if (numel(sys(i_sys).inputs) ~= numel(inputsizes))
      % generating inputs if it does not already exist
      sys(i_sys).inputs = ssmblock.makeBlocksWithSize(inputsizes, 'input');
    else % check subfields are completely filled
      for i=1:min(numel(sys(i_sys).inputs), numel(inputsizes))
        if ~ (numel(sys(i_sys).inputs(i).ports) == inputsizes(i))
          % generating level 2 plist for each input variable
          sys(i_sys).inputs(i).setPortsWithSize(inputsizes(i));
          sys(i_sys).inputs(i).ports.setName('', sys(i_sys).inputs(i).name);
        end
      end
    end
    
    % generating states if it does not already exist
    if (numel(sys(i_sys).states) ~= numel(statesizes))
      % generating states if it does not already exist
      sys(i_sys).states = ssmblock.makeBlocksWithSize(statesizes, 'state');
    else % check subfields are completely filled
      for i=1:min(numel(sys(i_sys).states), numel(statesizes))
        if ~ (numel(sys(i_sys).states(i).ports) == statesizes(i))
          % generating level 2 plist for each state variable
          sys(i_sys).states(i).setPortsWithSize(statesizes(i));
          sys(i_sys).states(i).ports.setName('', sys(i_sys).states(i).name);
        end
      end
    end
    
    if (numel(sys(i_sys).outputs) ~=  numel(outputsizes))
      % generating outputs if it does not already exist
      sys(i_sys).outputs = ssmblock.makeBlocksWithSize(outputsizes, 'output');
    else % check subfields are completely filled
      for i=1:min(numel(sys(i_sys).outputs), numel(outputsizes))
        if ~ (numel(sys(i_sys).outputs(i).ports) == outputsizes(i))
          % generating level 2 plist for each output variable
          sys(i_sys).outputs(i).setPortsWithSize(outputsizes(i));
          sys(i_sys).outputs(i).ports.setName('', sys(i_sys).outputs(i).name);
        end
      end
    end
    
    % checking diagonal content of matrices
    sys(i_sys).bmats = ssm.blockMatFillDiag(sys(i_sys).bmats, statesizes, inputsizes);
    sys(i_sys).cmats = ssm.blockMatFillDiag(sys(i_sys).cmats, outputsizes, statesizes);
    sys(i_sys).dmats = ssm.blockMatFillDiag(sys(i_sys).dmats,  outputsizes, inputsizes);
    
    %% =========== checking field sizes ===========
    % checking compatibility with Ninputs
    if ~(    numel(sys(i_sys).inputs)==size(sys(i_sys).bmats,2)  ...
        && numel(sys(i_sys).inputs)==size(sys(i_sys).dmats,2) ...
        && numel(sys(i_sys).inputs)==numel(inputsizes) )
      error(['error in ssm ',sys(i_sys).name,' because there are ',...
        num2str(size(sys(i_sys).bmats,2)),' columns in B , ',...
        num2str(size(sys(i_sys).dmats,2)),' columns in D , ',...
        num2str(numel(sys(i_sys).inputs)),' inputs, ',...
        num2str(numel(inputsizes)),' inputsizes'] );
    end
    
    % checking compatibility with Nss
    if ~(    numel(sys(i_sys).states)==size(sys(i_sys).amats,2)  ...
        && numel(sys(i_sys).states)==size(sys(i_sys).amats,1)  ...
        && numel(sys(i_sys).states)==size(sys(i_sys).bmats,1)  ...
        && numel(sys(i_sys).states)==size(sys(i_sys).cmats,2)  ...
        && numel(sys(i_sys).states)==numel(statesizes) )
      error(['error in ssm ',sys(i_sys).name,' because there are ',...
        num2str(size(sys(i_sys).amats,2)),' columns in A, ',...
        num2str(size(sys(i_sys).amats,1)),' lines in A, ',...
        num2str(size(sys(i_sys).bmats,1)),' lines in B, ',...
        num2str(size(sys(i_sys).cmats,2)),' columns in C, ',...
        num2str(numel(sys(i_sys).states)),' states, ',...
        num2str(numel(statesizes)),' sssizes'] );
    end
    
    % checking compatibility with Noutputs
    if ~(      numel(sys(i_sys).outputs)==size(sys(i_sys).cmats,1) ...
        && numel(sys(i_sys).outputs)==size(sys(i_sys).dmats,1) ...
        && numel(sys(i_sys).outputs)==numel(outputsizes) )
      error(['error in ssm ',sys(i_sys).name,' because there are ',...
        num2str(size(sys(i_sys).cmats,1)),' lines in C, ',...
        num2str(size(sys(i_sys).dmats,1)),' lines in D, ',...
        num2str(numel(sys(i_sys).outputs)),' outputs, ',...
        num2str(numel(outputsizes)),' outputsizes'] );
    end
    
    % Checking compatibility with Inputsizes
    for i=1:numel(sys(i_sys).inputs) % check between *inputsizes* and *inputs* plist
      if ~(  inputsizes(i) == numel(sys(i_sys).inputs(i).ports) )
        error(['error in ssm ', sys(i_sys).name, ...
          ' because the input number ', num2str(i),...
          ' named ', sys(i_sys).inputs(i).name,  ...
          ' and of size ', num2str(inputsizes(i)), ...
          ' has a port of length ', num2str(numel(sys(i_sys).inputs(i).ports)) ]);
      end
      if inputsizes(i) == 0 % send a warning in case an input is empty
        if ~callerIsMethod
          str=['warning, input named ',sys(i_sys).inputs(i).name,...
            ' has all matrices empty, should be deleted'] ;
          utils.helper.msg(utils.const.msg.MNAME,str);
        end
      end
      for j=1:numel(sys(i_sys).outputs) % check between *inputsizes* and D matrix content
        if ~isequal(sys(i_sys).dmats{j,i}, [])
          if ~( inputsizes(i) == size(sys(i_sys).dmats{j,i},2) )
            error(['error in ssm ', sys(i_sys).name, ...
              ' because the input number ', num2str(i),...
              ' named ', sys(i_sys).inputs(i).name,  ...
              ' and of size ', num2str(inputsizes(i)), ...
              ' has a D matrix of width ', num2str(size(sys(i_sys).dmats{j,i},2)) ]);
          end
        end
      end
      for j=1:numel(sys(i_sys).states) % check between *inputsizes* and B matrix content
        if ~isequal(sys(i_sys).bmats{j,i}, [])
          if ~( inputsizes(i) == size(sys(i_sys).bmats{j,i},2) )
            error(['error in ssm ', sys(i_sys).name, ...
              ' because the input number ', num2str(i),...
              ' named ', sys(i_sys).inputs(i).name,  ...
              ' and of size ', num2str(inputsizes(i)), ...
              ' has a B matrix of width ', num2str(size(sys(i_sys).bmats{j,i},2)) ]);
          end
        end
      end
    end
    
    % Checking compatibility with Outputsizes
    for i=1:numel(sys(i_sys).outputs) % check between *outputsizes* and *outputs* plist
      if ~(  outputsizes(i) == numel(sys(i_sys).outputs(i).ports) )
        error(['error in ssm ', sys(i_sys).name, ...
          ' because the output number ', num2str(i),...
          ' named ', sys(i_sys).outputs(i).name,  ...
          ' and of size ', num2str(outputsizes(i)), ...
          ' has a port of length ', num2str(numel(sys(i_sys).outputs(i).ports)) ]);
      end
      if outputsizes(i) == 0 % send a warning in case an output is empty
        if ~callerIsMethod
          str=['warning, output named ',sys(i_sys).outputs(i).name,...
            ' has all matrices empty, should be deleted'] ;
          utils.helper.msg(utils.const.msg.MNAME,str);
        end
      end
      for j=1:numel(sys(i_sys).inputs) % check between *outputsizes* and D matrix content
        if ~isequal(sys(i_sys).dmats{i,j}, [])
          if ~( outputsizes(i) == size(sys(i_sys).dmats{i,j},1) )
            error(['error in ssm ', sys(i_sys).name, ...
              ' because the output number ', num2str(i),...
              ' named ', sys(i_sys).outputs(i).name,  ...
              ' and of size ', num2str(outputsizes(i)), ...
              ' has a D matrix of height ', num2str(size(sys(i_sys).dmats{i,j},1)) ]);
          end
        end
      end
      for j=1:numel(sys(i_sys).states) % check between *outputsizes* and C matrix content
        if ~isequal(sys(i_sys).cmats{i,j}, [])
          if ~( outputsizes(i) == size(sys(i_sys).cmats{i,j},1) )
            error(['error in ssm ', sys(i_sys).name, ...
              ' because the output number ', num2str(i),...
              ' named ', sys(i_sys).outputs(i).name,  ...
              ' and of size ', num2str(outputsizes(i)), ...
              ' has a C matrix of height ', num2str(size(sys(i_sys).cmats{i,j},1)) ]);
          end
        end
      end
    end
    
    % Checking compatibility with sssizes
    for i=1:numel(sys(i_sys).states) % check between *statesizes* and *states* plist
      if ~(  statesizes(i) == numel(sys(i_sys).states(i).ports) )
        error(['error in ssm ', sys(i_sys).name, ...
          ' because the state number ', num2str(i),...
          ' named ', sys(i_sys).states(i).name,  ...
          ' and of size ', num2str(statesizes(i)), ...
          ' has a port of length ', num2str(numel(sys(i_sys).states(i).ports)) ]);
      end
      if statesizes(i) == 0 % send a warning in case an state is empty
        if ~callerIsMethod
          str=['warning, state named ',sys(i_sys).states(i).name,...
            ' has all matrices empty, should be deleted'] ;
          utils.helper.msg(utils.const.msg.MNAME,str);
        end
      end
      for j=1:numel(sys(i_sys).inputs) % check between *sssizes* and B matrix content
        if ~isequal(sys(i_sys).bmats{i,j}, [])
          if ~( statesizes(i) == size(sys(i_sys).bmats{i,j},1) )
            error(['error in ssm ', sys(i_sys).name, ...
              ' because the state space number ', num2str(i),...
              ' named ', sys(i_sys).states(i).name,  ...
              ' and of size ', num2str(statesizes(i)), ...
              ' has a B matrix of height ', num2str(size(sys(i_sys).bmats{i,j},1)) ]);
          end
        end
      end
      for j=1:numel(sys(i_sys).states) % check between *sssizes* and A matrix content
        if ~isequal(sys(i_sys).amats{i,j}, [])
          if ~(  statesizes(i) == size(sys(i_sys).amats{i,j},1) ...
              && statesizes(j) == size(sys(i_sys).amats{i,j},2) )
            error(['error in ssm ', sys(i_sys).name, ...
              ' because the state space position (', num2str(i), ',' , num2str(j),...
              ') named ', sys(i_sys).states(i).name, ' and ', sys(i_sys).states(i).name,  ...
              ' and of size ', num2str([statesizes(i),statesizes(j)] ), ...
              ' has a A matrix of size ', num2str(size(sys(i_sys).amats{i,j})) ]);
          end
        end
      end
      for j=1:numel(sys(i_sys).outputs) % check between *sssizes* and C matrix content
        if ~isequal(sys(i_sys).cmats{j,i}, [])
          if ~( statesizes(i) == size(sys(i_sys).cmats{j,i},2) )
            error(['error in ssm ', sys(i_sys).name, ...
              ' because the state space number ', num2str(i),...
              ' named ', sys(i_sys).states(i).name,  ...
              ' and of size ', num2str(statesizes(i)), ...
              ' has a C matrix of width ', num2str(size(sys(i_sys).cmats{j,i},2)) ]);
          end
        end
      end
      

      
      %% =========== checking redundancies ===========
      % ADD CHECK FOR VARIABLE NAME REDUNDANCIES
      
      % Not necessary anymore for model parameters !!!
      
      %% =========== checking field types ===========
      
      Fields = {...
        'amats' 'bmats' 'cmats' 'dmats' 'isnumerical' 'timestep'...
        'inputs'   ...
        'states' ...
        'outputs' ...
        'params' 'numparams' };
      Classes = {...
        'cellDoubleSym' 'cellDoubleSym' 'cellDoubleSym' 'cellDoubleSym' 'logical' 'double'...
        'ssmblock'  ...
        'ssmblock'  ...
        'ssmblock'  ...
        'plist' 'plist'...
        };
      
      for f = [Fields ; Classes]
        fieldcontent = sys(i_sys).(f{1});
        if strcmpi(f{2},'double')
          if ~( isa(fieldcontent,'double') )
            error(['error because in ssm ',sys(i_sys).name,...
              ' because  field ', f{1},...
              ' is of type ',class(fieldcontent), ' instead of ''double'' ']);
          end
        elseif strcmpi(f{2},'cellDoubleSym') % case where both double and symbolic classes are allowed inside a cell array
          for i_input = 1:numel(fieldcontent)
            if ~( isa(fieldcontent{i_input},'double') || isa(fieldcontent{i_input},'sym') )
              error(['error because in ssm ',sys(i_sys).name,' because element ',num2str(i_input),...
                ' of field ', f{1},' is of type ',class(fieldcontent),...
                ' instead of ''double'' or ''sym'' ']);
            end
          end
        elseif strcmpi(f{2},'ssmblock')
          if ~( isa(fieldcontent,'ssmblock') )
            % if the field is not a plist
            error(['error because in ssm ',sys(i_sys).name,...
              ' because  field ', f{1},...
              ' is of type ',class(fieldcontent), ' instead of ''ssmblock'' ']);
          end
        elseif strcmpi(f{2},'plist')
          if ~( isa(fieldcontent,'plist') )
            % if the field is not a plist
            error(['error because in ssm ',sys(i_sys).name,...
              ' because  field ', f{1},...
              ' is of type ',class(fieldcontent), ' instead of ''plist'' ']);
          end
        elseif strcmpi(f{2},'logical')
          if ~( isa(fieldcontent,'logical') )
            error(['error because in ssm ',sys(i_sys).name,...
              ' because  field ', f{1},...
              ' is of type ',class(fieldcontent), ' instead of ''logical'' ']);
          end
        else
          if ~isa(fieldcontent,f{2})
            error(['error because in ssm ',sys(i_sys).name,' because field ',...
              f{1},' is of type ',class(fieldcontent),' instead of ', f{2}]);
          end
        end
      end
    end
    if nargout > 0
      varargout = {sys};
    end
  end
