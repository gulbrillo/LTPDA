% HTMLADDLINKTABLE add a table with links to the file descriptor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HTMLADDLINKTABLE add a table with links to the file
%              descriptor.
%
% CALL:        docHelper.htmlAddLinkTable(fid, table)
%              docHelper.htmlAddLinkTable(fid, table, table_category)
%              docHelper.htmlAddLinkTable(fid, table, table_category, indent)
%              docHelper.htmlAddLinkTable(fid, table, table_category, indent, tableSize)
%
% INPUTS       fid       - File descriptor
%              table     - A cell of strings with three columns
%                            - first column:  The displayed name of the link
%                            - second column: The htnl-link
%                            - third column:  The link description
%              indent    - A integer which defines the indent of the table
%                          (DEFAULT: 4)
%              tableSize - Size of the table in percent
%                          (DEFAULT: 80)
%              table_category - One of the following strings
%                                'categorylist', 'subcategorylist'
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function htmlAddLinkTable(fid, table, table_category, indent, tableSize)
  
  nin = nargin;
  
  % Define default values
  if nin < 5
    tableSize = 80;
  end
  if nin < 4
    indent = 4;
  end
  if nin < 3
    table_category = 'subcategorylist';
  end
  if nin < 2
    error('### This function needs at least two inputs.');
  end
  
  % Check the table category
  if ~utils.helper.ismember(table_category, {'categorylist', 'subcategorylist'})
    error('### Please use only ''categorylist'', or ''subcategorylist'' for the table category');
  end
  
  %%% box_category = 'categorylist' or 'subcategorylist'
  
  indentStr = blanks(indent);
  
  %%% Table predefinitions %%%
  fprintf(fid, '\n');
  fprintf(fid, '%s<!-- =====           Link Table: Begin           ===== -->\n', indentStr);
  fprintf(fid, '%s<!-- ===== Created by docHelper.htmlAddLinkTable ===== -->\n', indentStr);
  fprintf(fid, '%s<p>\n', indentStr);
  fprintf(fid, '%s  <table border="1"  width="%d%%">\n', indentStr, tableSize);
  fprintf(fid, '%s    <tr>\n', indentStr);
  fprintf(fid, '%s      <td>\n', indentStr);
  fprintf(fid, '%s        <table border="0" cellpadding="5" class="%s" width="100%%">\n', indentStr, table_category);
  fprintf(fid, '%s          <colgroup>\n', indentStr);
  fprintf(fid, '%s            <col width="25%%"/>\n', indentStr);
  fprintf(fid, '%s            <col width="75%%"/>\n', indentStr);
  fprintf(fid, '%s          </colgroup>\n', indentStr);
  fprintf(fid, '%s          <tbody>\n', indentStr);
  
  for ii = 1:size(table,1)
    
    link_name = table{ii,1};
    link      = table{ii,2};
    link_desc = table{ii,3};
    
    %%% Table body %%%
    fprintf(fid, '%s            <tr valign="top">\n', indentStr);
    fprintf(fid, '%s              <td><a href="%s">%s</a></td>\n', indentStr, link, link_name);
    fprintf(fid, '%s              <td>%s</td>\n', indentStr, link_desc);
    fprintf(fid, '%s            </tr>\n', indentStr);
    
  end
  
  %%% Table end %%%
  fprintf(fid, '%s          </tbody>\n', indentStr);
  fprintf(fid, '%s        </table>\n', indentStr);
  fprintf(fid, '%s      </td>\n', indentStr);
  fprintf(fid, '%s    </tr>\n', indentStr);
  fprintf(fid, '%s  </table>\n', indentStr);
  fprintf(fid, '%s</p>\n', indentStr);
  fprintf(fid, '%s<!-- ===== Link Table: End ====== -->\n\n', indentStr);
  
end
