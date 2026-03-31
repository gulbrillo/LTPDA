function generateModelTechNote(modelname)
  
  % Header
  txt = docHeader(modelname);
  
  % Description and Documentation
  txt = [txt writeIntroduction(modelname)];
  
  % Versions
  txt = [txt writeVersionTable(modelname)];
  
  % Write each version section
  txt = [txt writeVersionSections(modelname)];
  
  % Footer
  txt = [txt docFooter(modelname)];
  
  % write file
  fd = fopen([modelname '.tex'], 'w+');
  fprintf(fd, strrep(strrep(txt, '\', '\\'), '%', '%%'));
  fclose(fd);
  
  % compile
  %   cmd = sprintf('/usr/texbin/pdflatex %s', modelname);
  %   [status, result] = system(cmd)
  
  edit([modelname '.tex'])
  
end

% Models are documented in html so we need to swap out html tags and
% replace them by appropriate LaTeX tags. One replacement per line, please,
% and remember to include replacements for closing tags. This is assuming
% that all html tags have associated closing tags.
function map = tagmap()
  
  map = {...
    '<p>', '', ...
    '</p>', '', ...
    '<br>', '\newline', ...
    '<tt>', '$', ...
    '</tt>', '$', ...
    };
  
end


function txt = docHeader(modelname)
  
  ename = strrep(modelname, '_', '\_');
  
  
  txt = sprintf('\\documentclass[11pt]{article}\n');
  txt = [txt sprintf('\\usepackage{ifpdf}\n')];
  txt = [txt sprintf('\\ifpdf\n')];
  txt = [txt sprintf('  \\usepackage[pdftex]{graphicx}   %% to include graphics\n')];
  txt = [txt sprintf('  \\pdfcompresslevel=9 \n')];
  txt = [txt sprintf('  \\usepackage[pdftex,     %% sets up hyperref to use pdftex driver\n')];
  txt = [txt sprintf('          plainpages=false,   %% allows page i and 1 to exist in the same document\n')];
  txt = [txt sprintf('          breaklinks=true,    %% link texts can be broken at the end of line\n')];
  txt = [txt sprintf('          colorlinks=true,\n')];
  txt = [txt sprintf('          pdftitle=%s,\n', ename)];
  txt = [txt sprintf('          pdfauthor=LTPDA\n')];
  txt = [txt sprintf('         ]{hyperref} \n')];
  txt = [txt sprintf('  \\usepackage{thumbpdf}\n')];
  txt = [txt sprintf('\\else \n')];
  txt = [txt sprintf('    \\usepackage{graphicx}       %% to include graphics\n')];
  txt = [txt sprintf('    \\usepackage{hyperref}       %% to simplify the use of \\href\n')];
  txt = [txt sprintf('\\fi \n')];
  
  txt = [txt sprintf('\\title{Technical Report of LTPDA built-in model \\texttt{%s}}\n', ename)];
  txt = [txt sprintf('\\author{LTPDA (%s)}\n', getappdata(0, 'ltpda_version'))];
  
  txt = [txt sprintf('\\begin{document}\n')];
  txt = [txt sprintf('\\maketitle\n')];
  
end


function txt = docFooter(modelname)
  txt = sprintf('\\end{document} %% End of %s\n', modelname);
end

function txt = writeVersionSections(modelname)

  versionTable = feval(modelname, 'versionTable');
  vers = versionTable(1:2:end);
  fcns = versionTable(2:2:end);
  Nvers = numel(vers);
  txt = '';
  for kk=1:Nvers
    
    v   = vers{kk};
    vtag = strrep(v, ' ', '');
    fcn = fcns{kk};
    
    txt = [txt sprintf('\\clearpage\n\n')];
    txt = [txt sprintf('\\section{Version `%s''}\n', v)];
    txt = [txt sprintf('\\label{ref:%s}\n', vtag)];
    
    txt = [txt sprintf('\n\n')];
    txt = [txt writeSectionForVersion(modelname, v, fcn)];
    
    txt = [txt writeSubmodelSectionForVersion(modelname, v)];
    txt = [txt sprintf('\n\n')];
    
  end
  
  txt = [txt sprintf('\n\n')];
  
  
end

function txt = writeSubmodelSectionForVersion(modelname, v)
  
  ii = feval(modelname, 'info', v);
  
  ciis = ii.children;
  txt = '';
  if numel(ciis) > 0
    
    label = strrep(sprintf('tab:submodels_%s_%s', modelname, strrep(v, ' ', '')), '_', '');
    txt = [txt sprintf('\\subsection{Sub-models}\n')];
    txt = [txt sprintf('Sub-models used in this version are shown in Table \\ref{%s}.\n', label)];    
    txt = [txt sprintf('\\begin{table}[htdp]\n')];
    txt = [txt sprintf('\\begin{center}\n')];
    txt = [txt sprintf('\\begin{tabular}{|c|c|p{4cm}|l|} \\hline\n')];
    
    txt = [txt sprintf('Sub-model & Description \\\\ \\hline\\hline \n')];
    for kk=1:numel(ciis)
      cii = ciis(kk);
      name = strrep(cii.mname, '_', '\_');
      txt = [txt sprintf('%s & %s \\\\ \\hline\n', name, cii.description)];      
      
    end
    
    % table footer
    txt = [txt sprintf('\\end{tabular}\n')];
    txt = [txt sprintf('\\end{center}\n')];
    txt = [txt sprintf('\\caption{Sub-models}\n')];
    txt = [txt sprintf('\\label{%s}\n', label)];
    txt = [txt sprintf('\\end{table}\n')];
    
    
  end
end

function txt = writeSectionForVersion(modelname, v, fcn)
  
  txt = '';
  
  % Description
  desc = fcn('description');
  desc = replaceTags(desc);
  txt = [txt sprintf('\\subsection{Description}\n')];
  txt = [txt sprintf('%s\n', desc)];
  txt = [txt sprintf('\n\n')];
  
  % Plist for version
  txt = [txt sprintf('\\subsection{Parameter List}\n')];
  label = strrep(sprintf('tab:plist_%s_%s', modelname, strrep(v, ' ', '')), '_', '');
  txt = [txt sprintf('Parameters used in this version are shown in Table \\ref{%s}.\n', label)];
  pl = feval(modelname, 'plist');
  
  txt = [txt plistTable(pl, label)];
  
  txt = [txt sprintf('\n\n')];
  
end

function txt = plistTable(pl, label)
  
  txt = '';
  txt = [txt sprintf('\\begin{table}[htdp]\n')];
  txt = [txt sprintf('\\begin{center}\n')];
  txt = [txt sprintf('\\begin{tabular}{|c|p{4cm}|p{4cm}|p{4cm}|} \\hline\n')];
  
  txt = [txt sprintf('Key & Default Value & Options & Description \\\\ \\hline\\hline \n')];
  for kk=1:pl.nparams
    
    txt = [txt sprintf('%s & ', pl.params(kk).key)];
    ptxt = display(pl.params(kk));
    txt = [txt sprintf('%s & ', strtrim(strrep(ptxt{3}, 'val:', '')))];
    if numel(pl.params(kk).getOptions) > 1
      opts = pl.params(kk).getOptions;
      optlist = sprintf('\\begin{itemize} ');
      for oo=1:numel(opts)
        optlist = [optlist sprintf('\\item %s ', utils.helper.val2str(opts{oo}))];
      end
      optlist = [optlist sprintf('\\end{itemize}')];
      txt = [txt sprintf('%s & ',  optlist)];
    else
      txt = [txt sprintf('\\textit{none} & ')];
    end
    desc = char(strrep(pl.params(kk).desc, '\n', '\\newline\\newline'));
    if isempty(desc)
      desc = '\textit{no description}';
    end
    txt = [txt sprintf('%s ', desc)];
    txt = [txt sprintf(' \\\\ \\hline \n')];
    
      
  end
  
  % table footer
  txt = [txt sprintf('\\end{tabular}\n')];
  txt = [txt sprintf('\\end{center}\n')];
  txt = [txt sprintf('\\caption{Parameter list}\n')];
    txt = [txt sprintf('\\label{%s}\n', label)];
  txt = [txt sprintf('\\end{table}\n')];
  
  
end

function txt = writeVersionTable(modelname)
  
  ename = strrep(modelname, '_', '\_');
  
  % table header
  txt = '';
  txt = [txt sprintf('\\subsection{Versions}\n')];
  txt = [txt sprintf('\\begin{table}[htdp]\n')];
  txt = [txt sprintf('\\begin{center}\n')];
  txt = [txt sprintf('\\begin{tabular}{|c|c|} \\hline\n')];
  
  versionTable = feval(modelname, 'versionTable');
  vers = versionTable(1:2:end);
  fcns = versionTable(2:2:end);
  Nvers = numel(vers);
  txt = [txt sprintf('Version & Description \\\\ \\hline\\hline \n')];
  for kk=1:Nvers
    
    v   = vers{kk};
    vtag = strrep(v, ' ', '');
    fcn = fcns{kk};
    
    txt = [txt sprintf('\\hyperref[ref:%s]{%s} & %s \\\\ \\hline \n', vtag, v, fcn('description'))];
      
  end
  
  % table footer
  txt = [txt sprintf('\\end{tabular}\n')];
  txt = [txt sprintf('\\end{center}\n')];
  txt = [txt sprintf('\\caption{Versions for model %s}\n', ename)];
  txt = [txt sprintf('\\label{versions:\texttt{%s}}\n', modelname)];
  txt = [txt sprintf('\\end{table}\n')];
  
end

function txt = writeIntroduction(modelname)
  
  % section
  txt = sprintf('\\section{Overview}\n');
  
  % description
  desc = feval(modelname, 'description');
  desc = replaceTags(desc);
  txt = [txt sprintf('\\subsection{Description}\n\n')];
  txt = [txt sprintf('%s\n\n\n', desc)];
  
  % Documentation
  doc = feval(modelname, 'doc');
  doc = replaceTags(doc);
  txt = [txt sprintf('\\subsection{Details}\n\n')];
  txt = [txt sprintf('%s\n\n\n', doc)];
  
  
end

function txt = replaceTags(txt)
  
  tm = tagmap();
  tags = tm(1:2:end);
  reps = tm(2:2:end);
  
  for kk=1:numel(tags)
    txt = strrep(txt, tags{kk}, reps{kk});
  end
  
end






