% MSG writes a message to the MATLAB terminal.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Writes a message to the MATLAB terminal if its priority is
%              equal or higher than the verbosity level in the LTPDA user
%              preferences. The message can be a printf format string that
%              describes how subsequent argument sare converted for output.
%
% CALL:     utils.helper.msg(priority, message, ...)
%
% INPUTS:
%           message  - message string to print
%           priority - priority of the message as defined in utils.const.msg
%
% EXAMPLE:
%
%     >> import utils.const.*
%     >> utils.helper.msg(utils.const.msg.IMPORTANT, 'The Answer is %d.', 42)
%
% NOTE: The verbosity level can be set within the 'LTPDAprefs' dialog, or via
%
%     >> LTPDAprefs('Display', 'verboseLevel', utils.const.msg.PROC1)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function msg(varargin)
  
  stack = dbstack;
  
  [txt, level] = utils.helper.msg_nnl(varargin{:});
  if ~isempty(txt)
    
    if numel(stack) > 1
      try
        names = unique({stack(2:end).name}, 'stable');
        source = cell(2, length(names));
        source(1,:)  = fliplr(names);
        source(2,:)  = {'.'};
        source = [source{1:end-1}];
        
        fprintf('%s%s\t[%s]\n', blanks(2*level), txt, source);
        
      catch Me
        fprintf('%s\n', txt);
      end
    else
      fprintf('[%s]\n', txt);
    end
    
  end
  
end

