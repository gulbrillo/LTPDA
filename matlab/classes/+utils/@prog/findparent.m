function [parentHandles] = findparent(childHandle,varargin)
% This function retrieves the handles of all blocks parents of a given
% child block, i.e. all those blocks which must be executed prior to the
% given one.
% Are considered only 'M-S-Function' blocks, since all others will be
% executed anyway.
%

lineHandles   = get(childHandle,'LineHandles');
lineIn1       = lineHandles.Inport; % this are all the handles of the lines coming in.
parentHandles = get(lineIn1,'SrcBlockHandle'); % these are the handles of all parent blocks.

if isempty(parentHandles), return; end

if(iscell(parentHandles)), parentHandles = cell2mat(parentHandles); end

for i=numel(parentHandles):-1:1
   if strcmp(get(parentHandles(i),'BlockType'),'From')
      gotoBlock = utils.prog.find_in_models(bdroot,'LookUnderMasks','all','BlockType','Goto','GotoTag',get(parentHandles(i),'GotoTag'));
      if numel(gotoBlock)>1
         disp(['*** Warning; found multiple GOTO blocks with the same associated tag; please check model ',gcs]);
         gotoBlock = gotoBlock{1};
      end
    % Substitute the handle of the 'from' block with the corresponding
    % 'goto' block:
      parentHandles(i) = get_param(gotoBlock{1},'Handle');
   end
   
 % Let's find recursively all the parents of this parent block:
   parentHandles = [parentHandles ; utils.prog.findparent(parentHandles(i))];
   
 % If this parent is a subsystem, all inner block must be added to the list
 % (but there's no need to look for the parents of all them):
   if strcmp(get(parentHandles(i),'BlockType'),'SubSystem')
      innerBlocks = utils.prog.find_in_models(parentHandles(i),'LookUnderMasks','all','BlockType','M-S-Function');
      for j=1:numel(innerBlocks)
         parentHandles = [parentHandles; innerBlocks(j)];
      end
    % The handle of the subsystem can be discarded:
      parentHandles(i) = [];
   elseif ~strcmp(get(parentHandles(i),'BlockType'),'M-S-Function')
      parentHandles(i) = [];
   end
   
end

end
   
   
   
   
