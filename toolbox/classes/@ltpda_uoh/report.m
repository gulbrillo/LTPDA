% REPORT generates an HTML report about the input objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: REPORT generates an HTML report about the input objects.
%
% CALL:        report(objs);
%              report(objs, options);
%
% INPUTS:      objs    - LTPDA objects
%              options - a plist of options
%
% PARAMETERS:
%              'dir'     - report dir [default: <temp dir>/ltpda_report/<date><time>]
%              'extras'  - true [default] or false: plot data and diagrams
%                          for objects, output mfile, and type() output.
%              'desc'    - give a description to appear on the main report
%                          page.
%              'save'    - include saved versions of the objects in the
%                          report directory. Objects are saved as XML.
%                          Specify with true or false [default]
%              'zip'     - compress the report directory to a ZIP file
%              'plots'   - specify a cell-array of objects to build
%                          plots on the main page. Each cell gets its
%                          own plot. Example: {[a1, a3], {a5}}.
%              'overwrite' - overwrite the report directory if it exists.
%                            Specify true or false [default].
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'report')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = report(varargin)

  % starting initial checks
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all objs and plists
  objs = {};
  objnames = {};
  classes = utils.helper.ltpda_userclasses;
  for jj=1:numel(classes)
    try
      % can I create this type of class?
      feval(classes{jj});
      [oos, obj_invars] = utils.helper.collect_objects(varargin(:), classes{jj}, in_names);
      if ~isempty(oos) && ~isa(oos, 'plist')
        objs = [objs {oos}];
        objnames = [objnames obj_invars];
      end
    end
  end
  % get plist
  pl = utils.helper.collect_objects(varargin(:), 'plist');
  pl = applyDefaults(getDefaultPlist('Default'), pl);

  % Get options
  outdir = find_core(pl, 'dir');
  plotOn = find_core(pl, 'extras');
  saveXML = find_core(pl, 'save');
  compress = find_core(pl, 'zip');
  groupPlot = find_core(pl, 'plots');

  % Create output dir
  if isempty(outdir)
    outdir = fullfile(tempdir, 'ltpda_report', datestr(now, 30));
  elseif (outdir == '.')
    outdir = fullfile('ltpda_report', datestr(now, 30));
  end
  
  % Does the directory exist?
  if find_core(pl, 'overwrite')
    if exist(outdir, 'dir') ~= 0
      [success, msg, msgid] = rmdir(outdir, 's');
      if ~success, disp(msg), return, end
    end
  else % check with the user
    if exist(outdir, 'dir') == 7
      disp('The requested report directory already exists.')
      r = input('Do you want to overwrite it? [y/n]  ', 's');
      if strcmpi(r, 'y')
        [success, msg, msgid] = rmdir(outdir, 's');
        if ~success, disp(msg), return, end
      else
        return
      end
    end
  end
  mkdir(outdir);
  mkdir(fullfile(outdir, 'images'));

  % Write .html file
  indexFile = fullfile(outdir, 'index.html');
  fd = fopen(indexFile, 'w+');

  header = getHeader();
  footer = getFooter();

  % write header
  fprintf(fd, header);

  % write description
  desc = find_core(pl, 'desc');
  if ~iscell(desc), desc = {desc}; end
  for kk=1:numel(desc)
    fprintf(fd, '<p>%s</p>\n', desc{kk});
  end

  % write index entry
  fprintf(fd, '<br><h2><a name="toc">Table of Contents</a></h2>\n');
  [s, htmlfiles] = writeTableOfContents(objs, objnames);
  fprintf(fd, s);

  % Group plot?
  if ~isempty(groupPlot)
    % go through each cell - one plot per cell
    for kk=1:numel(groupPlot)
      % get objects
      group = groupPlot{kk};
      fprintf(fd, '<hr>\n');
      fprintf(fd, '<h2>Plot %d</h2>', kk);
      if isa(group, 'ao')
        imname = 'images/groupplot_001.png';
        n = 1;
        while exist(fullfile(outdir, imname),'file')
          n = n + 1;
          imname = sprintf('images/groupplot_%03d.png', n);
        end
        % make a plot
        hfig = iplot(group);
        % make image
        saveas(hfig, fullfile(outdir, imname));
        % make link
        fprintf(fd, '<img src="%s" alt="Plot" width="800px" border="3">\n', imname);
        close(hfig);
      else

      end
    end
  end

  % write individual html files
  writeObjFiles(fd, objs, htmlfiles, header, footer, outdir, plotOn, saveXML);

  % reportee info
  fprintf(fd, '<hr>\n');
  fprintf(fd, '<br><h2>report created by:</h2>\n');
  s = obj2table(provenance, outdir);
  fprintf(fd, s);

  fprintf(fd, '\n');
  fprintf(fd, '\n');
  % write footer
  fprintf(fd, footer);
  % Close
  fclose(fd);

  % copy stylesheet
  helpPath = utils.helper.getHelpPath();
  dp = fullfile(helpPath, 'ug', 'docstyle.css');
  copyfile(dp, outdir);
  copyfile(dp, fullfile(outdir, 'html'));

  % zip ?
  if compress
    zip([outdir '.zip'], outdir);
  end

  % open report
  if isempty(pl.find_core('dir'))
    web(fullfile('file:///', outdir, 'index.html'))
  else
    web(fullfile('file:///', pwd, outdir, 'index.html'))
  end

  utils.helper.msg(utils.const.msg.PROC1, 'report written to %s', outdir);
  if nargout == 1
    varargout{1} = outdir;
  end

end

%--------------------------------------------------------------------------
% Write provenance info
%
function s = obj2table(obj, reportDir)

  % prepare table
  s =    sprintf('<p>\n\t');
  s = [s sprintf('  <table border="1" cellspacing="0" cellpadding="0" width="1%%%%">\n')];
  s = [s sprintf('    <tr valign="top">\n')];
  s = [s sprintf('      <td align="center" valign="top">\n')];
  s = [s sprintf('        <table border="0" cellspacing="0" cellpadding="3" width="100%%%%">\n')];
  s = [s sprintf('          <colgroup>\n')];
  s = [s sprintf('            <col width="1%%%%">\n')];
  s = [s sprintf('            <col width="1%%%%">\n')];
  s = [s sprintf('          </colgroup>\n')];
  s = [s sprintf('          <thead>\n')];
  s = [s sprintf('            <tr valign="top" bgcolor="#000000">\n')];
  s = [s sprintf('              <td align="center" colspan="2"><font color="#FFFFFF">%s</font></td></tr>\n', upper(class(obj)))];
  s = [s sprintf('            <tr bgcolor="#B2B2B2"valign="top">\n')];
  s = [s sprintf('              <th>Property</th>\n')];
  s = [s sprintf('              <th>Value</th>\n')];
  s = [s sprintf('            </tr>\n')];
  s = [s sprintf('          </thead>\n')];
  s = [s sprintf('          <tbody>\n')];
  props = properties(obj);
  cols = {'#E9E9E9', '#FFFFFF'};
  for jj=1:numel(props)
    prop = props{jj};
    val  = obj.(prop);
    s = [s sprintf('            <tr valign="top" bgcolor="%s">\n', cols{mod(jj,2)+1})];
    s = [s sprintf('              <td><h4><font color="#890022"><i>%s</i></font></h4></td>\n', props{jj})];
    %---- EXCEPTIONS -------%
    if isempty(val)
      valstr = '<font color="#0003B6"><i>empty</i></font>';
    else
      if strcmp(prop, 'mfile')
        valstr = '<i>see above</i>';
      else
        valstr = val2html(val, reportDir);
      end
    end
    s = [s sprintf('              <td>%s</td>\n', valstr)];
    s = [s sprintf('            </tr>\n')];
  end
  s = [s sprintf('          </tbody>\n')];
  s = [s sprintf('        </table>\n')];
  s = [s sprintf('      </td>\n')];
  s = [s sprintf('    </tr>\n')];
  s = [s sprintf('  </table>\n')];
  s = [s sprintf('</p>\n')];
end


%--------------------------------------------------------------------------
% Convert a MATLAB type to an html string
%
function s = val2html(val, reportDir)
  MAX_STR_LENGTH = 50;
  MAX_NUM_LENGTH = 10;
  if ischar(val) % String
    s = ['<font color="#49B64B">' strtrunc(val, MAX_STR_LENGTH) '</font>'];
  elseif iscell(val) % Symbol
    cs = size(val);
    if numel(val) == 1
      s = val2html(val{1});
    else
      s = '<table border="1" cellpadding="2" cellspacing="0">\n';
      s = [s sprintf('  <thead>\n')];
      s = [s sprintf('    <tr  valign="top">\n')];
      s = [s sprintf('<th bgcolor="#8BCEC3"></th>')];
      for jj=1:cs(2) % loop over columns
        s = [s sprintf('<th bgcolor="#8BCEC3">%d</th>', jj)];
      end
      s = [s sprintf('    </tr>\n')];
      s = [s sprintf('  </thead>\n')];
      for jj=1:cs(1)
        s = [s '<tr>\n'];
        s = [s sprintf('<th bgcolor="#8BCEC3">%d</th>', jj)];
        for kk=1:cs(2)
          s = [s '<td align="center" valign="middle" >\n'];
          s = [s val2html(val{jj,kk})];
          s = [s '</td>\n'];
        end
        s = [s '</tr>\n'];
      end
      s = [s '</table>\n'];
    end
  %%%%%%%% SYMBOLS
  elseif isa(val, 'sym')

    if numel(val) == 1
      s = strtrunc(char(sym), 50);
    else
      cs = size(val);
      s = '<table border="1" width="600px" cellpadding="3" cellspacing="0">\n';
      s = [s sprintf('  <thead>\n')];
      s = [s sprintf('    <tr  valign="top">\n')];
      s = [s sprintf('<th bgcolor="#B2B2B2"></th>')];
      for jj=1:cs(2) % loop over columns
        s = [s sprintf('<th bgcolor="#B2B2B2">%d</th>', jj)];
      end
      s = [s sprintf('    </tr>\n')];
      s = [s sprintf('  </thead>\n')];

      for jj=1:cs(1) % loop over rows
        s = [s '<tr>\n'];
        s = [s sprintf('<th bgcolor="#B2B2B2">%d</th>', jj)];
        for kk=1:cs(2) % loop over columns
          s = [s '<td align="center" valign="middle" >\n'];
          s = [s '<font color="#6969B6">' strtrunc(char(val(jj,kk)),50) '</font>'];
          s = [s '</td>\n'];
        end
        s = [s '</tr>\n'];
      end
      s = [s '</table>\n'];
    end
  elseif isa(val, 'ltpda_obj') % LTPDA object
    if isa(val, 'history')
      % make image
      imname = 'images/hist_img_001.png';
      n = 1;
      while exist(fullfile(reportDir, imname),'file')
        n = n + 1;
        imname = sprintf('images/hist_img_%03d.png', n);
      end
      % make image
      dotview(val, plist('filename', fullfile(reportDir, imname), 'view', false, 'format', 'png'));
      % make link
      s = sprintf('<img src="%s" alt="History Plot" border="3">\n', imname);
    elseif isa(val, 'unit') || isa(val, 'time') || isa(val, 'plist')
      s = mask_special_char(char(val));
    else
      s = obj2table(val, reportDir);
    end
  elseif islogical(val)
    if val
      s = '<i>true</i>';
    else
      s = '<i>false</i>';
    end
  elseif isnumeric(val) % Numbers
    if isempty(val)
      s = '<font color="#0003B6"><i>empty</i></font>';
    else
      if numel(val) > 1
        s = [sprintf('<font color="#0003B6"><tt><font color="#000000">[%dx%d]</font>', size(val,1), size(val,2)) mat2str(val(1:min(numel(val), MAX_NUM_LENGTH)), 4)];
      else
        s = ['<font color="#0003B6"><tt>' mat2str(val(1:min(numel(val), MAX_NUM_LENGTH)), 4)];
      end
      if numel(val) > MAX_NUM_LENGTH
        s = [s '...'];
      end
      s = [s '</tt></font>'];
    end
  else
    s = strtrunc(char(val), MAX_STR_LENGTH);
  end

end


function txt = Cell2String(c)
  % recursive code to print the content of cell arrays
  if iscell(c) % for a cell
    txt = '';%;
    for i=1:size(c,1)
      if i==1
        txti = '{';
      else
        txti = ' ';
      end
      for j=1:size(c,2)
        txti = [txti ' ' Cell2String(c{i,j})];
      end
      if i==size(c,1)
        txti = [txti, ' }'];
      end
      txt = strvcat(txt, txti);
    end
  elseif isa(c, 'sym')
    txt = char(c);
  elseif islogical(c) % for a logical
    txt = mat2str(c);
  elseif isnumeric(c)||isa(c,'sym') % for a numerical array, only size is displayed
    if size(c,1)+size(c,2)==0 % for 0x0 array
      txt = '  []   ';
    elseif isa(c,'double') && (norm(c)==0) % for zero array (test dos not carsh for sym)
      txt = '  []   ';
    else % for non empty array
      if size(c,1)>9
        txt1 = ['[',num2str(size(c,1))];
      else
        txt1 = [' [',num2str(size(c,1))];
      end
      if size(c,2)>9
        txt2 = [num2str(size(c,2)),']'];
      else
        txt2 = [num2str(size(c,2)),'] '];
      end
      txt = [txt1,'x',txt2 ];
    end
    % txt = mat2str(c); % old display
  elseif ischar(c)
    txt = ['''' c ''''];
  else
    txt = char(c);
  end
end

%--------------------------------------------------------------------------
% Truncate a string
%
function s = strtrunc(s, n)
  sl = length(s);
  s  = s(1:min(sl, n));
  if sl > n
    s = [s '...'];
  end
  s = mask_special_char(s);
end

%--------------------------------------------------------------------------
% Mask the special characters '<', '>' and &
%
% '<' with '&lt;'
% '>' with '&gt;'
% '&' with '&amp;'
%
function s = mask_special_char(s)
  s = strrep(s, '&' ,'&amp;');
  s = strrep(s, '<', '&lt;');
  s = strrep(s, '>' ,'&gt;');
end

%--------------------------------------------------------------------------
% Write a table of contents for the input objects
%
function [s, filenames] = writeTableOfContents(objs, objnames)

  filenames = {};

  % start table
  s =    sprintf('<p>\n\t');
  s = [s sprintf('  <table border="1" cellspacing="0" cellpadding="0" width="20%%%%">\n')];
  s = [s sprintf('    <tr valign="top">\n')];
  s = [s sprintf('      <td valign="top">\n')];
  s = [s sprintf('        <table border="0" cellspacing="0" cellpadding="1" width="100%%%%">\n')];
  s = [s sprintf('          <colgroup>\n')];
  s = [s sprintf('            <col width="1%%%%">\n')];
  s = [s sprintf('            <col width="1%%%%">\n')];
  s = [s sprintf('          </colgroup>\n')];
  s = [s sprintf('          <thead>\n')];
  s = [s sprintf('            <tr valign="top">\n')];
  s = [s sprintf('              <th bgcolor="#B2B2B2">obj #</th>\n')];
  s = [s sprintf('              <th bgcolor="#B2B2B2">link</th>\n')];
  s = [s sprintf('            </tr>\n')];
  s = [s sprintf('          </thead>\n')];
  s = [s sprintf('          <tbody>\n')];

  cols = {'#E9E9E9', '#FFFFFF'};
  nn = 1;
  for jj=1:numel(objs)
    for kk=1:numel(objs{jj})
      obj = objs{jj}(kk);
      % make filename
      filenames{nn} = sprintf('obj_%03d', nn);
      % write table entry
      s = [s sprintf('            <tr valign="top" bgcolor="%s">\n', cols{mod(nn,2)+1})];
      s = [s sprintf('              <td><font color="#890022">%03d</font></td>\n', nn)];
      s = [s sprintf('              <td><a href="index.html#%s">%s [%s]</a></td>\n', filenames{nn}, strtrunc(objnames{nn}, 30), class(obj))];
      s = [s sprintf('            </tr>\n')];
      nn = nn + 1;
    end
  end
  s = [s sprintf('            </tr>\n')];
  s = [s sprintf('          </tbody>\n')];
  s = [s sprintf('        </table>\n')];
  s = [s sprintf('      </td>\n')];
  s = [s sprintf('    </tr>\n')];
  s = [s sprintf('  </table>\n')];
  s = [s sprintf('</p>\n')];
end


function s = getFooter()
  s = '</body>\n</html>\n';
end

function s = getHeader()
  s = '';

  % write HTML header
  s = [s sprintf('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"\n')];
  s = [s sprintf('"http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">\n')];
  s = [s sprintf('<html lang="en">\n')];
  s = [s sprintf('<head>\n')];
  s = [s sprintf('<meta http-equiv="Content-Type" content="text/html; charset=us-ascii">\n')];
  s = [s sprintf('\n')];
  s = [s sprintf('\n')];

  % Page Title
  pageTitle = ['LTPDA Report from ' datestr(now)];
  s = [s sprintf('<title>%s</title>\n', pageTitle)];
  s = [s sprintf('<link rel="stylesheet" href="docstyle.css" type="text/css">\n')];
  s = [s sprintf('<meta name="generator" content="DocBook XSL Stylesheets V1.52.2">\n')];
  s = [s sprintf('<meta name="description" content="Presents details of an LTPDA object.">\n')];
  s = [s sprintf('</head>\n')];
  s = [s sprintf('\n')];
  s = [s sprintf('\n')];
  s = [s sprintf('<body>\n')];
  s = [s sprintf('<a name="top"><table cellpadding="5" cellspacing="0" width="100%%%%" bgcolor="#F9E767"><tr><td>\n')];
  s = [s sprintf('  <h1 class="title">%s</h1></td></tr></table>\n\n', pageTitle)];
  s = [s sprintf('<hr><br></a>\n\n')];

end

%--------------------------------------------------------------------------
% Write html file for each object
%
function writeObjFiles(fd, objs, filenames, header, footer, outdir, plotOn, saveXML)

  % Loop over objects
  nn = 1;
  for jj=1:numel(objs)
    for kk=1:numel(objs{jj})
      % get object
      obj = objs{jj}(kk);

      % Object name
      fprintf(fd, '<table width="100%%%%" bgcolor="#F9F19B" cellpadding="5" cellspacing="0"><tr><td>\n');
      fprintf(fd, '<h1><a name="%s">Name: %s</a></h1>\n', filenames{nn}, mask_special_char(obj.name));
      fprintf(fd, '</td></tr></table>\n');
      fprintf(fd, '<p><h3><a href="index.html#top">Back to Top</a></h3></p>\n');
      fprintf(fd, '<hr>\n');
      fprintf(fd, '<h2>Class: %s</h2>\n', class(obj));

      % Description
      if isprop(obj, 'description')
        fprintf(fd, '<hr>\n');
        fprintf(fd, '<h2>Description</h2>\n');
        if isempty(obj.description)
          fprintf(fd, '<i>none</i>\n');
        else
          fprintf(fd, '<p>%s</p>\n', mask_special_char(obj.description));
        end
      end

      % Additional stuff
      if plotOn
        if isa(obj, 'ao')
          writeAOextras(obj, fd, outdir);
        elseif isa(obj, 'miir')
          writeMIIRextras(obj, fd, outdir);
        elseif isa(obj, 'mfir')
          writeMFIRextras(obj, fd, outdir);
        elseif isa(obj, 'pzmodel')
          writePZMODELextras(obj, fd, outdir);
        elseif isa(obj, 'ssm')
          writeSSMextras(obj, fd, outdir)
        else
          % no extras for this type
        end
      end

      % write object table
      fprintf(fd, '<hr>\n');
      fprintf(fd, '<h2>Object Table View</h2>\n');
      s = obj2table(obj, outdir);
      fprintf(fd, s);

      fprintf(fd, '<p><h3><a href="index.html#top">Back to Top</a></h3></p>\n');

      % save XML ?
      if saveXML
        [path, name, ext] = fileparts(filenames{nn});
        xmldir = fullfile(outdir, 'xml');
        mkdir(xmldir);
        xmlfile = fullfile(xmldir, [name '.xml']);
        save(obj, xmlfile);
      end
      nn = nn + 1;
    end % End loop over objects
  end % Loop over object types
end

%--------------------------------------------------------------------------
% Write extra bits for SSM
%
function writeSSMextras(obj, fd, outdir)

  %-----------------------------------------------
  % make dot view
  % make image
  fprintf(fd, '<hr>\n');
  fprintf(fd, '<h2>Block Diagram</h2>\n');
  imname = 'images/ssm_img_001.png';
  n = 1;
  while exist(fullfile(outdir, imname),'file')
    n = n + 1;
    imname = sprintf('images/ssm_img_%03d.png', n);
  end
  % make image
  dotview(obj, plist('filename', fullfile(outdir, imname), 'view', false, 'format', 'png'));
  % make link
  fprintf(fd, '<p><img src="%s" alt="SSM Diagram" border="3"></p>\n', imname);

end
%--------------------------------------------------------------------------
% Write extra bits for MIIR
%
function writeMIIRextras(obj, fd, outdir)

  %-----------------------------------------------
  % plot response
  % make image
  fprintf(fd, '<hr>\n');
  fprintf(fd, '<h2>Response</h2>\n');
  imname = 'images/resp_img_001.png';
  n = 1;
  while exist(fullfile(outdir, imname),'file')
    n = n + 1;
    imname = sprintf('images/resp_img_%03d.png', n);
  end
  % make a plot
  r = resp(obj);
  hfig = iplot(r);
  % make image
  if ~isempty(hfig)
    saveas(hfig, fullfile(outdir, imname));
    % make link
    fprintf(fd, '<p><img src="%s" alt="MIIR Response" width="800px" border="3"></p>\n', imname);
    close(hfig);
  else
    fprintf(fd, '<p><font color="#0003B6"><i>empty</i></font></p>\n');
  end

end
%--------------------------------------------------------------------------
% Write extra bits for MFIR
%
function writeMFIRextras(obj, fd, outdir)

  %-----------------------------------------------
  % plot response
  % make image
  fprintf(fd, '<hr>\n');
  fprintf(fd, '<h2>Response</h2>\n');
  imname = 'images/resp_img_001.png';
  n = 1;
  while exist(fullfile(outdir, imname),'file')
    n = n + 1;
    imname = sprintf('images/resp_img_%03d.png', n);
  end
  % make a plot
  hfig = iplot(resp(obj));
  % make image
  if ~isempty(hfig)
    saveas(hfig, fullfile(outdir, imname));
    % make link
    fprintf(fd, '<p><img src="%s" alt="MFIR Response" width="800px" border="3"></p>\n', imname);
    close(hfig);
  else
    fprintf(fd, '<p><font color="#0003B6"><i>empty</i></font></p>\n');
  end

end
%--------------------------------------------------------------------------
% Write extra bits for pzmodels
%
function writePZMODELextras(obj, fd, outdir)

  %-----------------------------------------------
  % plot response
  % make image
  fprintf(fd, '<hr>\n');
  fprintf(fd, '<h2>Response</h2>\n');
  imname = 'images/resp_img_001.png';
  n = 1;
  while exist(fullfile(outdir, imname),'file')
    n = n + 1;
    imname = sprintf('images/resp_img_%03d.png', n);
  end
  % make a plot
  hfig = iplot(resp(obj));
  % make image
  if ~isempty(hfig)
    saveas(hfig, fullfile(outdir, imname));
    % make link
    fprintf(fd, '<p><img src="%s" alt="PZMODEL Response" width="800px" border="3"></p>\n', imname);
    close(hfig);
  else
    fprintf(fd, '<p><font color="#0003B6"><i>empty</i></font></p>\n');
  end
end
%--------------------------------------------------------------------------
% Write extra bits for AOs
%
function writeAOextras(obj, fd, outdir)

  %-------------------------------------------
  % PLOT
  fprintf(fd, '<hr>\n');
  fprintf(fd, '<h2>Plot</h2>\n');
  imname = 'images/ao_img_001.png';
  n = 1;
  while exist(fullfile(outdir, imname),'file')
    n = n + 1;
    imname = sprintf('images/ao_img_%03d.png', n);
  end
  % make a plot
  hfig = iplot(obj);
  % make image
  if ~isempty(hfig)
    saveas(hfig, fullfile(outdir, imname));
    % make link
    fprintf(fd, '<p><img src="%s" alt="AO Plot" width="800px" border="3"></p>\n', imname);
    close(hfig);
  else
    fprintf(fd, '<p><font color="#0003B6"><i>empty</i></font></p>\n');
  end

  %-------------------------
  % Output of type
  if ~isempty(obj.hist)
    cmds = hist2m(obj.hist, 'full');
    txt = mfile2html(cmds(end:-1:1));
  else
    txt = '<p><font color="#0003B6"><i>empty</i></font></p>';
  end
  fprintf(fd, '<hr>\n');
  fprintf(fd, '<h2>History dump</h2>\n');
  fprintf(fd, '<br><p>This is the output of <tt>type(<i>object</i>)</tt></p>\n');
  fprintf(fd, '<p><div class="fragment"><pre>\n');
  fprintf(fd, '\n%s', txt);
  fprintf(fd, '</pre></div></p>\n');

end

%--------------------------------------------------------------------------
% Reformat an mfile contained in a cell array to be output as html
function txt = mfile2html(mfile)
    % add format tags
    for kk=1:numel(mfile)
      % make strings

      % Mask '&' in the strings
      mfile{kk} = regexprep(mfile{kk}, '(''[^'']*'')', '${strrep($1, ''&'', ''&amp;'')}');
      % Mask '>' in the strings
      mfile{kk} = regexprep(mfile{kk}, '(''[^'']*'')', '${strrep($1, ''>'', ''&gt;'')}');
      % Mask '<' in the strings
      mfile{kk} = regexprep(mfile{kk}, '(''[^'']*'')', '${strrep($1, ''<'', ''&lt;'')}');
      mfile{kk} = regexprep(mfile{kk}, '''([^''\\]*(\\.[^''\\]*)*)''', '<span class="string">''$1''</span>');
      % make comments
      idx = strfind(mfile{kk}, '%');
      if ~isempty(idx)
        mfile{kk} = [mfile{kk}(1:idx(1)-1) '<span class="comment">' mfile{kk}(idx(1):end) '</span>'];
      end
    end
    % reformat into a big string
    txt = sprintf([repmat('%s\t',1,size(mfile,1)),'\n'],mfile{:});
    txt = strrep(txt, '`', '''');
end

%--------------------------------------------------------------------------
% Get Info
%
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pls = getDefaultPlist(sets{1});
  else
    sets = {'Default'};
    pls = [];
    for kk=1:numel(sets)
      pls = [pls getDefaultPlist(sets{kk})];
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pls);
  ii.setModifier(false);
  ii.setOutmin(0);
end

function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function plo = buildplist(set)
  switch lower(set)
    case 'default'
      plo = plist('dir', '', 'extras', true, 'desc', '', ...
                  'save', false, 'zip', false, 'plots', {}, ...
                  'overwrite', false);
    otherwise
      error('### Unknown parameter set [%s].', set);
  end
end

