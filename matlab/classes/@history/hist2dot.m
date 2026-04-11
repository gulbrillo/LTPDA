% HIST2DOT converts a history object to a 'DOT' file suitable for processing with graphviz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HIST2DOT converts a history object to a 'DOT' file suitable for
%              processing with graphviz (www.graphviz.org).
%
% CALL:        hist2dot(h, 'foo.dot');
%
% INPUT:       h       - history object
%              foo.dot - file name to view the graphic with the programm
%                        graphviz
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = hist2dot(varargin)
  
  %%% Set inputs
  h        = varargin{1};
  filename = varargin{2};
  pl = [];
  if nargin > 2
    if isa(varargin{3}, 'plist')
      pl = varargin{3};
    end
  end
  pl = combine(pl, getDefaultPlist);
  stop_option = find_core(pl, 'stop_option');
  title       = find_core(pl, 'title');
  DEBUG       = find_core(pl, 'debug');
  
  %%% Write .dot file
  
  fd = fopen(filename, 'w+');
  
  %%% write header
  fprintf(fd, 'digraph G \n{\n');
  
  fprintf(fd, '\t label="%s"\n', strrep(strrep(title, sprintf('\n'), '\n'), '"', '\"'));
  fprintf(fd, '\t fontsize=24\n');
  fprintf(fd, '\t labelloc="top"\n');
   
  % Get unique history nodes
  [hists, histUUIDs, links] = getHists(h, [], [], {});
  
  % collect contexts
  contexts = {};
  for kk=1:numel(hists)
    hist = hists(kk);
    if ~isempty(hist.context)
      cc = 0;
      while exist(hist.context{end-cc}) == 2 && cc<numel(hist.context)-1        
        cc = cc + 1;
      end
      contexts = [contexts hist.context{end-cc}];
    else
      contexts = [contexts {''}];
    end
  end
  
  % Check if all contexts are empty (maybe we have read an old LTPDA object)
  % Set in that case an empty blank to one field so that the method doesn't
  % create a syntax error in the .dot code.
  if all(cellfun(@isempty, contexts))
    contexts{end} = ' ';
  end
  
  % sort the histories by context
  [contexts, idx] = sort(contexts);
  hists = hists(idx);
  
  % start graph
  
  % Now write history blocks
  fprintf(fd, '\t end [label="END"];\n');
  
  lastContext  = '';
  contextHists = [];
  clusterCount = 0;
  
  for ll=1:numel(hists)
    
    % current history
    hist = hists(ll);
    
    % can we capture a current context?
    currContext = contexts{ll};
    
    % wrap label
    % Do some command substitution
    fcn = hist.methodInfo.mname;
    shape = 'rectangle';
    fsize  = 12;
    extras  = '';
    
    wstr = utils.prog.wrapstring([fcn char(hist.plistUsed)], 25);
    ss = '';
    for s=wstr
      ss = [ss '\n' char(s)];
    end
    
    %---- DEBUG
    if DEBUG
      fprintf('processing node %s\n\t\t%s\n', fcn, hist.UUID);
      ss = [ss '\nUUID=' hist.UUID];
      
      % get indices of any parameters which contain histories
      idx = [];
      if numel(hist.plistUsed.params)>0
        vals= {hist.plistUsed.params.val};
        idx = find(cellfun(@(x)(isa(x, 'history')||iscell(x)), vals));
      end      
      rs = utils.prog.rstruct(hist);
      rs.inhists = [];
      if ~isempty(idx) 
        fprintf(2, '\t\t\tignoring params %s\n', mat2str(idx));
        rs.plistUsed.params(idx) = [];
      end
      % get the size of only this node (no links to ancestors)
      rsize2 = whos('rs');
      sstr = sprintf('size=%0.2f KB', rsize2.bytes/1024);
      ss = [ss '\n' sstr];
      fprintf('\t\t%s\n', sstr);
    end
    %---- DEBUG
    
    ss = ss(3:end);
    
    % Do we need to start a new context?
    if isempty(lastContext) || strcmp(lastContext, currContext) == 0
      
      % check if we can close a context
      if ~isempty(lastContext)
        links = closeContext(fd, contextHists, links);
        contextHists = [];
      end
      
      % cache the current context for next time
      lastContext = currContext;
      
      % if we have a context, start a new sub-graph
      if ~isempty(lastContext)
        fprintf(fd, '\nsubgraph cluster_%d {\n', clusterCount);
        fprintf(fd, '\t color=azure2\n');
        fprintf(fd, '\t style=filled\n');
        fprintf(fd, '\t fillcolor=ghostwhite\n');
        fprintf(fd, '\t fontcolor=blue\n');
        fprintf(fd, '\t fontsize=18\n');
        fprintf(fd, '\t label="%s"\n', lastContext);
        contextHists = [contextHists hist];
        clusterCount = clusterCount+1;
      end
    end
    
    % write the node for this step.
    fprintf(fd, '\t %s [%s fontsize=%d shape=%s label="%s"];\n', ...
      nodeName(hist), ...
      extras, fsize, shape, ss);    
    
  end
  
  fprintf(fd, '}\n\n');  
  fprintf(fd, '\n');
  fprintf(fd, '\n');
  
  % Now write links
  for kk=1:numel(links)
    fprintf(fd, '\t %s', links{kk});
  end
  
  fprintf(fd, '\t %s -> end;\n', nodeName(h));
  
  %%% close
  fprintf(fd, '}\n');
  
  %%% Close
  fclose(fd);
  
end


function links = closeContext(fd, hists, links)
  
  % write links associated with the hists of this context
  for kk=1:numel(hists)
    hist = hists(kk);
    % find the links that begin from this history
    matches = regexp(links, sprintf('%s->.*', nodeName(hist)));
    % get indexes of the empty links
    idx = cellfun('isempty', matches);
    % we will write the links which match
    outLinks = links(~idx);
    % and return the remaining links
    links = links(idx);
    % now write out the matching links so they are contained in the
    % context.
    for ll=1:numel(outLinks)
      fprintf(fd, '\t %s', outLinks{ll});
    end
  end
  
  % finish the sub-graph
  fprintf(fd, '}\n\n');
end

function [hists, histUUIDs, links] = getHists(obj, links, hists, histUUIDs)
  
  if isa(obj, 'history') && ~arrayContainsObjects(histUUIDs, obj)
    pl = obj.plistUsed;
    
    for kk=1:length(pl.params)
      
      val = pl.params(kk).getVal();
      if isa(val, 'history')
        
        for jj=1:numel(val)
          if ~arrayContainsObjects(histUUIDs, val(jj))
            [hists, histUUIDs, links] = getHists(val(jj), links, hists, histUUIDs);
          end
          
          % write link
          l = sprintf('%s -> %s;\n', nodeName(val(jj)), nodeName(obj));
          links = [links {l}];
        end
        
      elseif iscell(val)
        
        for ll=1:numel(val)
          v = val{ll};
          if isa(v, 'history') 
            % do nothing
          elseif isa(v, 'ltpda_uoh')
            v = [v.hist];        
          else 
            v = [];
          end
          
          for jj=1:numel(v)
            if ~arrayContainsObjects(histUUIDs, v(jj))
              [hists, histUUIDs, links] = getHists(v(jj), links, hists, histUUIDs);
            end
            
            % write link
            l = sprintf('%s -> %s;\n', nodeName(v(jj)), nodeName(obj));
            links = [links {l}];
          end
          
        end
      end
      
    end
    
    histUUIDs = [histUUIDs {obj.UUID}];
    hists = [hists obj];
  end
  
  % use try because it's faster than checking for the property.
  try
    if ~arrayContainsObjects(histUUIDs, obj.hist)
      [hists, histUUIDs, links] = getHists(obj.hist, links, hists, histUUIDs);
    end
  end
  
  % use try because it's faster than checking for the property.
  try
    for kk=1:numel(obj.inhists)
      if ~arrayContainsObjects(histUUIDs, obj.inhists(kk))
        [hists, histUUIDs, links] = getHists(obj.inhists(kk), links, hists, histUUIDs);
      end
      
      % write link
      l = sprintf('%s -> %s;\n', nodeName(obj.inhists(kk)), nodeName(obj));
      links = [links {l}];
    end
  end
  
  
end

function res = arrayContainsObjects(array, obj)
  res = any(strcmp(array, obj.UUID));
end

function nn = nodeName(node)
  
  nn = ['node_' strrep(node.UUID, '-', '_')];
  
  
  
end

function res = arrayContainsElement(array, element)
  
  res = any(array == element);
  
%   res = false;
%   for kk=1:numel(array)
%     if strcmp(array(kk).UUID, element.UUID)
%       res = true;
%       break;
%     end
%   end
  
end

function res = containsNodeArray(nodes, node)
  
  x = @(c)(strcmp(c, node.h.UUID));
  res = any(cellfun(x, nodes));
  
%   res = cellfun('strcmp', nodes, node);
  
%   res = false;
%   for kk=1:numel(nodes)
%     if strcmp(nodes{kk}, node.h.UUID)
%       res = true;
%       break;
%     end
%   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pl = getDefaultPlist()

  pl = plist();
  pl.append(plist.HISTORY_TREE_PLIST);
  
  p = param({'debug', 'Set debug mode (slow!)'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
end

