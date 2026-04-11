% CALLERISMETHOD(varargin) checks if a method was called by another LTPDA method.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CALLERISMETHOD(varargin) checks if the method it is inserted in,
% was called by another LTPDA method
%
% CALL:                         callerIsMethod = utils.helper.callerIsMethod()
%
% The name of the caller function is retrieved from a call to dbstack
%
% The name of the higher level caller function, if any is tested against the structure
% /../../classes/@class_name/method_name.m
%
% If the higher level caller is found to be a method of LTPDA classes, out is TRUE
% If the caller is found not to be a method of LTPDA classes, out is FALSE
%
% Optional outputs:
%     className     the name of the class the caller methods is associated
%     methodName    the name of the caller method is associated
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%                  [callerIsMethod, className] = utils.helper.callerIsMethod()
%      [callerIsMethod, className, methodName] = utils.helper.callerIsMethod()


function varargout = callerIsMethod(varargin)
  
  % This is just some thinking about make a scheme that can override the
  % behaviour of callerIsMethod. The idea is to create a variable called
  % 'callerIsMethod' in the calling function and pass it in here. We would
  % have to pass varargin and inputnames down the chain always. It almost
  % works but will be too much work for the moment.
  %   if nargin == 2
  %
  %     inputs = varargin{1};
  %     names = varargin{2};
  %
  %     idx = strcmpi('callerIsMethod', names);
  %     if any(idx)
  %       varargout{1} = inputs{idx};
  %       return
  %     end
  %   end
  
  persistent exceptions;
  
  persistent knownClasses;
  
  if isempty(knownClasses)
    knownClasses = {'ao', 'ltpda_tf', 'collection', 'filterbank', 'mfh', 'mfir', 'miir', 'parfrac', 'pest', 'rational', 'smodel', 'timespan'};
  end
  
  if isempty(exceptions)
    exceptions = {'subsref', 'subsasgn', 'compute', 'ssm2dot', 'rebuild', 'collect_values', 'generic_getInfo', 'executeCommands'};
  end
  
  stack = dbstack('-completenames');
  index = 2;
  
  if size (stack, 1) < index
    error('### This utility can only be used inside other functions!');
  end
  
  if size (stack, 1) == index
    
    % This is the highest level function call.
    % The caller is not a method
    callerIsMethod  = false;
    className       = [];
    methodName      = [];
    
  else
    % This is not the highest level function call.
    
    % we can check if we are in a built-in model
    [~, filename] = fileparts(stack(3).file);
    if regexp(filename, '.*_model_.*')
      if regexp(filename, '^test')
        % Some test cases have the name: test_ao_model_LTPVisualize
        % and we want to add history fro this case. But the next if-case
        % will return true which we don't want.
        % --> Don't do anything
      else
        varargout{1} = true;
        return
      end
    end
    
    
    % Serching for class methods assuming the folder/files structure is:
    % /../../classes/@class_name/method_name.m
    
    % In the case that we are inside a nested function, we need to climb up
    % until we get out of the calling file.
    firstFile = stack(index).file;
    firstName = stack(index).name;
    
    % Removed the third condition because it was overly strong. It stopped
    % some call stacks from being processed properly. For example:
    %
    %  myClass/simulate -> ssm/simulate
    %  myClass/simulate -> myClass/simulate
    %
    % TODO: check it still works for recursive calls.
    %       2013-06-03: turns out it doesn't so we revert this change for
    %       now. We need to be able to distinguish between a recursive call
    %       and a method override.
    
    while index < length(stack) ...
        && strcmp(firstFile, stack(index).file) ...
        && ~strcmp(firstName, stack(index+1).name)
      index = index+1;
    end
    
    % capture method name
    parts = regexp(stack(index).name, '[/>]', 'split');
    methodName = parts{1};
    
    if index == length(stack) && length(stack)>3
      callerIsMethod = false;
      className = '';
    else
      % filesep is quite slow, so we cache the value and use it three times.
      % The \ character is also a command in regexp, so we need to go for a trick
      persistent expr;
      if isempty(expr)
        
        if strncmp(computer, 'PC', 2)
          fs = '\\';
        else
          fs = '/';
        end
        
        expr = ['.*' fs '@(\w+)' fs '\w+.m$'];
      end
      
      % capture class name
      tokenStr  = regexp(stack(index).file, expr, 'tokens');
      
      % *********
      % At the moment this bit of code is a bad thing because models which
      % create objects in their default plists (AOs for example) can't be
      % rebuilt because the objects have no history. An example of this is
      % smodel_model_psd_feeps.
      % *********
      
%       % If we are being called deep inside a built-in model constructor,
%       % then the stack will contain fromModel and we are called from a
%       % method.
%       if utils.helper.ismember('fromModel', {stack(:).name})
%         callerIsMethod = true;
%         className = 'ltpda_uo';
%         methodName = 'fromModel';
%       
%       % If the method is a unit test (test_*) then we add history
%       else


      if strncmp(methodName, 'test_', 5)
        callerIsMethod = false;
        if ~isempty(tokenStr)
          className = tokenStr{1}{1};
        end
        
      % if we get a match and if the caller is not in the exception list
      % then we were called by a method.
      elseif ~isempty(tokenStr) && ~any(strcmp(methodName, exceptions))
        className = tokenStr{1}{1};
        % we only return true for LTPDA classes
        if any(strcmp(className, knownClasses))
          callerIsMethod = true;
        elseif utils.prog.issubclass(className, 'ltpda_uoh')
          callerIsMethod = true;
        elseif utils.prog.issubclass(className, 'ltpda_uo')
          callerIsMethod = true;
        elseif utils.prog.issubclass(className, 'ltpda_obj')
          callerIsMethod = true;
        else
          callerIsMethod = false;
        end
      else
        callerIsMethod = false;
        className = '';
      end
    end
    
  end
  
  % Assigning outputs
  varargout{1} = callerIsMethod;
end
