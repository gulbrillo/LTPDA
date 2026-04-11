%FIGURE  returns an html string  to embed an image  to a HTML document
%        A plist with format specifications may also be provided
% CALL
%        html = image(filename)
%
%
function html = figure(file64data,varargin)

  nv = length(varargin);
  if nv > 0
    for i=1:nv
      if ~isa(varargin{i},'plist')
        error('HTML::figure: only filename and plist with format specifiers allowed');
      end
    end %for nargin
    cin = combine(varargin{:})
    height = find(cin,'height',480);
    width = find(cin,'width',640);
  else
    height = 768;
    width = 1024;
  end  

  html = sprintf('<img src="data:image;base64,%s" height="%d" width="%d">\n',file64data,height,width); 

end
