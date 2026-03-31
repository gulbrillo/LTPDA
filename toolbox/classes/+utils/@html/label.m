%LABEL  returns an html string  to add a location label in a HTML document
%
% CALL
%        html = labe(filename)
%
%
function html = label(label)

  html = sprintf('<a name="%s">\n',label); 

end
