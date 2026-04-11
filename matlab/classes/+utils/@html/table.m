% TABLE returns an html string containing a table of the given quantities.
%
% CALL
%        html = table(title, headers, values)
%
% INPUT
%             title - table title
%           headers - an [1xN] cell-array of titles
%            values - an [MxN] cell-array of values
%
function html = table(title, headers, values)
  
  html = '';
  html = [html sprintf('    <!-- Table -->\n')];
  html = [html sprintf('    <p>\n')];
  html = [html sprintf('      <table cellspacing="0" class="body" cellpadding="4" summary="" border="2">\n')];
  
  html = [html sprintf('        <thead>\n')];
  html = [html sprintf('        	<tr valign="top">\n')];
  html = [html sprintf('      	  	<th bgcolor="#D7D7D7" colspan="%d">%s</th>\n', size(values,2), title)];
  html = [html sprintf('        	</tr>\n')];
  if numel(headers) > 0
    html = [html sprintf('        	<tr bgcolor="#E8E8E8" valign="top">\n')];
    for kk=1:numel(headers)
      html = [html sprintf('      	  	<th>%s</th>\n', headers{kk})];
    end
    html = [html sprintf('        	</tr>\n')];
  end
  html = [html sprintf('        </thead>\n')];
  html = [html sprintf('        <tbody>\n')];
  
  nrows = size(values,1);
  ncols = size(values,2);
  for kk=1:nrows
    if mod(kk,2) == 0
      col = '#EEEEFF';
    else
      col = '#FFFFFF';
    end
    
    html = [html sprintf('      	  	<tr bgcolor="%s">\n', col)];
    for jj=1:ncols
      valstr = utils.helper.val2str(values{kk,jj});
      valstr = strrep(valstr, '''', '');
      html = [html sprintf('      	  	<td>%s</td>\n', valstr)];
    end          
    html = [html sprintf('      	  	</tr>\n')];
  end
  html = [html sprintf('        </tbody>\n')];
  html = [html sprintf('     <table>\n')];
  
end

% END
