% HTMLADDSTRIPEDTABLE adds a striped table to the file descriptor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HTMLADDSTRIPEDTABLE adds a striped table to the file descriptor.
%
% CALL:        docHelper.htmlAddStripedTable(fid, indent, table)
%              docHelper.htmlAddStripedTable(fid, indent, table, tableSize)
%
% INPUTS       fid       - File descriptor
%              indent    - A integer which defines the indent of the table
%              table     - A cell of strings which defines the entries of
%                          the table. The first row defines the table head
%                          and if all entries are the same then have the
%                          table only one head.
%              tableSize - Size of the table in percent
%              colWidth  - Column width for each column in percent
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function htmlAddStripedTable(fid, indent, table, tableSize, colWidth)
  
  % Check inputs
  if ~isnumeric(fid) || isempty(fopen(fid))
    error('### The first input must be the file descriptor.');
  elseif ~isnumeric(indent)
    error('### The indent must be a number.');
  elseif ~iscellstr(table)
    error('### The table must be a cell of strings.');
  end
  
  if nargin < 5
    switch size(table, 2)
      case 1
        colWidth = 100;
      case 2
        colWidth = [30 70];
      case 3
        colWidth = [33 33 33];
      otherwise
        error('### Please implement the column width for more than 3 columns');
    end
  end
  if nargin < 4
    tableSize = 60;
  end
  
  indentStr = blanks(indent);
%   if numel(unique(table(1,:))) == 1
%     head = table(1,1);
%   else
%     head = table(1,:);
%   end
  % Remove table head from the table
  head  = table(1, :);
  table = table(2:end,:);
  color = {'#ffffff', '#f3f4f5'};
  
  fprintf(fid, '\n');
  fprintf(fid, '%s<!-- =====        Striped %dx%d table: Begin        ==== -->\n', indentStr, size(table));
  fprintf(fid, '%s<!-- ===== Created by docHelper.htmlAddStripedTable ===== -->\n', indentStr);
  fprintf(fid, '%s<div class="sectiontitle"></div>\n', indentStr);
  fprintf(fid, '%s<table cellspacing="0" class="body" cellpadding="2" border="0" width="%d%%">\n', indentStr, tableSize);
  fprintf(fid, '%s  <colgroup>\n', indentStr);
  for cc = 1:numel(colWidth)
    fprintf(fid, '%s    <col width="%d%%"/>\n', indentStr, colWidth(cc));
  end
  fprintf(fid, '%s  </colgroup>\n', indentStr);
  fprintf(fid, '%s  <thead>\n', indentStr);
  fprintf(fid, '%s    <tr valign="top">\n', indentStr);
  for hh = 1:numel(head)
    fprintf(fid, '%s      <th class="categorylist">%s</th>\n', indentStr, head{hh});
  end
  fprintf(fid, '%s    </tr>\n', indentStr);
  fprintf(fid, '%s  </thead>\n', indentStr);
  fprintf(fid, '%s  <tbody>\n', indentStr);
  for rr = 1:size(table,1)
    fprintf(fid, '%s    <tr valign="top">\n', indentStr);
    for cc = 1:size(table,2)
      fprintf(fid, '%s      <td bgcolor="%s">%s</td>\n', indentStr, color{mod(rr,2)+1}, table{rr,cc});
    end
    fprintf(fid, '%s    </tr>\n', indentStr);
  end
  fprintf(fid, '%s  </tbody>\n', indentStr);
  fprintf(fid, '%s</table>\n', indentStr);
  fprintf(fid, '%s<!-- ===== Striped %dx%d table: End ==== -->\n', indentStr, size(table));
  fprintf(fid, '\n');
  
end



