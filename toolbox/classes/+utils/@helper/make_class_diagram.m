% A script to plot nicely the class structure of the LTPDA Toolbox,
% showing all the dependencies
% Passing the flag 'show_methods' to true or false, it is possible to
% display also the public methods of the user classes
%
% CALL
%         utils.helper.make_class_diagram(show_methods)
%

function make_class_diagram(varargin)
  
  if nargin > 0
    show_methods = varargin{1};
  else
    % display methods or not
    show_methods = false;
  end
  
  % get global variables
  prefs = getappdata(0, 'LTPDApreferences');
  DOT    = char(prefs.getExternalPrefs.getDotBinaryPath);
  FEXT   = char(prefs.getExternalPrefs.getDotOutputFormat);
  
  classes = utils.helper.ltpda_classes;
  
  out = sprintf('digraph G \n');
  out = [out sprintf('{\n')];
  out = [out sprintf('rankdir = BT\n')];
  
  out = [out sprintf('handle [fontsize=8 label="handle" shape="ellipse" ];\n')];
  
  % first class nodes
  for kk = 1:numel(classes)
    class = classes{kk};
    m = eval(['?' class]);
    
    if ~isempty(m)
      if show_methods
        label = sprintf('<<table border="1" cellborder="1" cellpadding="3" cellspacing="0" bgcolor="white"><tr><td bgcolor="black" align="center"><font color="white">%s</font></td></tr>\n', m.Name);
        
        mthds = m.Methods;
        for jj = 1:numel(mthds)
          mthd = mthds{jj};
          if strcmp(mthd.DefiningClass.Name, m.Name) && strcmp(mthd.Access, 'public')
            label = [label sprintf('<tr><td align="left" port="r%d">%s</td></tr>\n', jj, mthd.Name)];
          end
        end
        label = [label sprintf('</table>>')];
        out = [out sprintf('%s [  shape = "plaintext" fontsize=12 label=%s ];\n', m.Name, label)];
      else
        out = [out sprintf('%s [fontsize=12 shape=rectangle label="%s"];\n', m.Name, m.Name)];
      end
    end
    
  end
  
  % now links
  for kk = 1:numel(classes)
    class = classes{kk};
    m = eval(['?' class]);
    % parents
    parents = m.SuperClasses;
    
    % m -> parent
    for jj = 1:numel(parents)
      p = parents{jj};
      
      out = [out sprintf('%s -> %s\n', m.Name, p.Name)];
      
    end
    
  end
  
  out = [out sprintf('}\n')];
  
  dotfile = 'ltpda_classdiagram.dot';
  fd = fopen(dotfile, 'w+');
  fprintf(fd, out);
  fclose(fd);
  
  [path, name, ext] = fileparts(dotfile);
  outfile = fullfile(path, [name '.' FEXT]);
  
  % Write to graphics file
  cmd = sprintf('%s -T%s -o %s %s', DOT, FEXT, outfile, dotfile);
  system(cmd);
  
  % View graphics file
  if any(strcmpi(FEXT, {'gif', 'ico', 'jpg', 'jpeg', 'jpe', 'png', 'tiff'}))
    image(imread(outfile));
  else
    open(outfile);
  end
  
end
