function [childrenHandles] = findchildren(parentHandle,varargin)
% This function retrieves the handles of all blocks children of a given
% parent block, whose handle is received as input.
%


         
lineHandles   = get(parentHandle,'LineHandles');

if isempty(lineHandles) % the parent block given has no output: it's an ending.
   childrenHandles = [];
   return;
end
lineOut1      = lineHandles.Outport; % this is the handle of the line coming out from the parent block.


childrenHandles = get(lineOut1,'DstBlockHandle'); % these are the handles of all children blocks.

if(iscell(childrenHandles)), childrenHandles = cell2mat(childrenHandles); end

% Check if the parent given can be effectively a child (used when the
% findchildren function is called recursively, checking the output of a
% subsystem):
if nargin>1 && strcmp(varargin{1},'all'), childrenHandles = [parentHandle; childrenHandles]; end

for i=numel(childrenHandles):-1:1
   
   if strcmp(get(childrenHandles(i),'BlockType'),'SubSystem') && numel(get(childrenHandles(i),'Blocks'))==3 && numel(utils.prog.find_in_models(childrenHandles(i),'LookUnderMasks','all','BlockType','M-S-Function','FunctionName','ltpdasim'))==1
      % then this block is a susbsystem containing a ltpdasim function block. It's a real child. The handle must be substituted with the one of the inner function block.
      childrenHandles(i) = utils.prog.find_in_models(childrenHandles(i),'LookUnderMasks','all','BlockType','M-S-Function','FunctionName','ltpdasim');

   elseif strcmp(get(childrenHandles(i),'BlockType'),'M-S-Function') && strcmp(get(childrenHandles(i),'FunctionName'),'ltpdasim')
      % then this block is a ltpdasim function block. It's a real child. The research do not go deeper into this branch, since this child will create a new ltpda obj.
     
   elseif strcmp(get(childrenHandles(i),'BlockType'),'SubSystem') && numel(get(childrenHandles(i),'Blocks'))==3 && numel(utils.prog.find_in_models(childrenHandles(i),'LookUnderMasks','all','BlockType','M-S-Function'))==1
      % this is a block containing a LTPDA function, but not using ltpdasim. The ltpda obj pass through, the research must look further.
      followingChildren = utils.prog.findchildren(childrenHandles(i));
      childrenHandles   = [childrenHandles;followingChildren];
      childrenHandles(i)= [];
      
   elseif strcmp(get(childrenHandles(i),'BlockType'),'M-S-Function') && ~strcmp(get(childrenHandles(i),'FunctionName'),'ltpdasim')
      % then this block is a function block (NOT ltpdasim). It can be ignored.
      childrenHandles(i)= [];
     
   elseif strcmp(get(childrenHandles(i),'BlockType'),'Terminator')
      % this is a false child: the terminator do not need the output of the
      % parent block.
      childrenHandles(i)= [];
      
   elseif strcmp(get(childrenHandles(i),'BlockType'),'Mux')
      % this transfer the parent block output to other following blocks: the research must go deeper.
      followingChildren = utils.prog.findchildren(childrenHandles(i));
      childrenHandles   = [childrenHandles;followingChildren];
      childrenHandles(i)= [];
      
   elseif strcmp(get(childrenHandles(i),'BlockType'),'Goto')
      % this transfer the parent block output to other following blocks; the research must go deeper.
      allFromBlocks = utils.prog.find_in_models(bdroot,'LookUnderMasks','all','BlockType','From','GotoTag',get(childrenHandles(i),'GotoTag'));
      for j=1:numel(allFromBlocks)
         fromHandle = get_param(allFromBlocks{j},'Handle');
         followingChildren = utils.prog.findchildren(fromHandle);
         childrenHandles   = [childrenHandles;followingChildren];
      end
      childrenHandles(i)= [];
      
   elseif strcmp(get(childrenHandles(i),'BlockType'),'SubSystem')
      % this is a common subsystem: the research must look for all children blocks contained:
      subsystemHandle  = childrenHandles(i);
      portConnectivity = get(subsystemHandle,'PortConnectivity');
      portHandles      = get(subsystemHandle,'PortHandles');
      for portIndex=1:numel(portHandles.Inport)
         if portConnectivity(portIndex).SrcBlock == parentHandle, break; end
      end % the port n� <portIndex> is the one connected to the parent block
      portHandles = find_system(subsystemHandle,'LookUnderMasks','all','BlockType','Inport','Port',num2str(portIndex));
      for j=1:numel(portHandles)
         followingChildren = utils.prog.findchildren(portHandles(j));
         childrenHandles   = [childrenHandles;followingChildren];
      end
      childrenHandles(i)= [];
      
   elseif strcmp(get(childrenHandles(i),'BlockType'),'Outport')
      % the line exits a subsystem: the research must continue in the upper level:
      portIndex        = get(childrenHandles(i),'Port');
      subsystemHandle  = get_param(get(childrenHandles(i),'Parent'),'Handle');
      portConnectivity = get(subsystemHandle,'PortConnectivity');
      for j=1:size(portConnectivity,1)
         if strcmp(portConnectivity(j).Type,portIndex) && isempty(portConnectivity(j).SrcBlock)
            destinationBlock = portConnectivity(j).DstBlock;
            break
         end
      end
      followingChildren = utils.prog.findchildren(destinationBlock,'all');
      childrenHandles   = [childrenHandles;followingChildren];
      childrenHandles(i)= [];
      
   else
      disp('--- Unknown case, please update function ''utils.prog.findchildren''')
      disp(['The unknown block is: ',getfullname(childrenHandles(i))])
      disp(['The block has type:   ',get(childrenHandles(i),'BlockType')])
      
   end
         
end

end
   
   
   
   
