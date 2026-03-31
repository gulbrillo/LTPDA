% autoReporter class, for reporting automatization.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: autoReporter is a wrapper class that encapsulates text formating 
% functionality achieved by using a text helper class.
% In current version, utils.html is that helper class, so HTML format documents 
% are generated. 
% In case a for example LaTeX helper class is created, only updating the helper 
% formatter instance to use a LaTeX one, the resulting document would be a LaTeX
% document.
%
% To see the available static methods, call
%
% >> methods utils.autoReporter
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef autoReporter < handle
  properties (SetAccess = private, GetAccess = private)
    m_formater ;
    m_text='';
    m_ERROR = '<H2>autoFormater badly initialized</H2>';
    m_init = false;
    m_figindex = 0;
    m_reportFile = '';
    m_reportFolder = '';
    m_end_mark = '__END_MARK__';
    m_begin_body_mark = '__BEGIN_BODY__';
    m_end_body_mark = '__END_BODY__';
    
    m_begin_step_mark = '__BEGIN_MULTISTEP_MARK__';
    m_end_step_mark   = '__END_MULTISTEP_MARK__';
    m_begin_toc_mark  = '__BEGIN_TOC_MARK__'; %%Temporal mark
    m_end_toc_mark    = '__END_TOC_MARK__';
    m_begin_multi_toc = '__BEGIN_MULTI_TOC__'; 
    m_end_multi_toc   = '__END_MULTI_TOC__';
    
    m_begin_last_ol_TOC = '__BEGIN_LAST_CLOSED_OL_TOC_';
    m_end_last_ol_TOC   = '__END_LAST_CLOSED_OL_TOC_';
    
    m_toc_counter = 0;
    m_last_TOC_level = 0;
    m_TOC_info = {};
    m_TOC_title_needed = true;
    m_bgImages = false; %Indicates if images must be closed after being codified for the report
  end

  methods (Access = public)

    function obj = autoReporter(format)
      switch nargin
        case 0
         obj.m_formater = utils.html();
         obj.m_init = true;
        case 1
          if strcmp(format,'HTML')
             obj.m_formater = utils.html();
             obj.m_init = true;
          else
             showError();
             obj.m_init = false;
             return;
          end
        otherwise
          fprintf('ERROR: autoFormater constructor, TOO MANY parameters\n');
          return;
      end
    end %autoReporter ctor.
    
    function obj = beginDocument(obj,filename,titletext,multireport,report_label,bgImages)
      if obj.m_init
        obj.m_reportFile = filename;
        [obj.m_reportFolder,~,~] = fileparts(obj.m_reportFile);

        if multireport && exist(obj.m_reportFile,'file')
           %we hava an existing report, so header is already included.
           obj.m_text = obj.readReportTillEndMark();
           obj.addComment(obj.m_begin_step_mark); %marc a new step execution
           obj.addLineSeparator();
           %in case of multireport, when a previous execution exists, it must add the mark
           %at the end of the existing TOC, to keep only a section with the TOC of all the reports.
           obj.appendTOCmark();
           %We DO NOT have to add the "Table of contents" title to the new file
           obj.m_TOC_title_needed = false;

        else
          %we are creating the file, so header must be included.
          obj.m_text = [obj.m_text obj.m_formater.pageHeader(titletext)];
          
          begin_body_comment = obj.comment(obj.m_begin_body_mark);
          obj.m_text = [obj.m_text obj.m_formater.beginBody(begin_body_comment)];
          obj.addLabel('TOP');
        
          genericTitle = obj.title(titletext,2);
          obj.addFormatedString(genericTitle);
          
          %marc a new step execution
          obj.addComment(obj.m_begin_step_mark); 
        
          %add marks to locate where TOC must be
          obj.addComment(obj.m_begin_toc_mark);
          obj.addComment(obj.m_end_toc_mark);
          %We have to add the "Table of contents" title to the new file
          obj.m_TOC_title_needed = true;
        end

        titletoput = titletext;
        
        if exist('report_label','var')
           if ~strcmp(report_label,'') 
             titletoput = [titletoput '-' report_label];
           end
        end

        if exist('bgImages','var')
           obj.m_bgImages = bgImages;
        end
        
                
        obj.addTitle(titletoput,1);

      else
        obj.showError('beginDocument');
      end
    end %beginDocument
    
    function obj = openDocument(obj,filename)
       if obj.m_init
          obj.m_reportFile = filename;
          [obj.m_reportFolder,~,~] = fileparts(obj.m_reportFile);
          obj.m_text = fileread(obj.m_reportFile);
       else
           obj.showError('openDocument');
       end
    end

    function obj = endDocument(obj)
      if obj.m_init
        obj.addLineBreak();
        obj.addLineBreak();
        obj.addComment(obj.m_end_step_mark);
        obj.addComment(obj.m_end_mark);
        obj.addCenter(obj.reference('TOP','TOP'));
        end_body_comment = obj.comment(obj.m_end_body_mark);
        obj.m_text = [obj.m_text obj.m_formater.endBody(end_body_comment)];
        obj.m_text = [obj.m_text obj.m_formater.pageFooter()];
        %And now we can generate the TOC and put in in the expected place
        %at the beginning of the report
        obj.insertTOC();
      else
        obj.showError('endDocument');
      end
    end %endDocument

    function fmt = table(obj,ttitle,theaders,tvalues)
      if obj.m_init
        fmt = obj.m_formater.table(ttitle,theaders,tvalues);
      else
        obj.showError('table');
      end
    end

    function obj = addTable(obj,ttitle,theaders,tvalues)
      if obj.m_init
        obj.m_text = [obj.m_text obj.table(ttitle,theaders,tvalues)];
      else
        obj.showError('addTable');
      end
    end %addTable

    function fmt = beginItemize(obj)
      if obj.m_init
        fmt = obj.m_formater.beginItemize();
      else
        obj.showError('beginItemize');
      end
    end

    function obj = addBeginItemize(obj)
      if obj.m_init
        obj.m_text = [obj.m_text obj.beginItemize()];
      else
        obj.showError('addBeginItemize');
      end
    end %addBeginItemize

    function fmt = endItemize(obj)
      if obj.m_init
        fmt = obj.m_formater.endItemize();
      else
        obj.showError('endItemize');
      end
    end

    function obj = addEndItemize(obj)
      if obj.m_init
        obj.m_text = [obj.m_text obj.endItemize()];
      else
        obj.showError('addEndItemize');
      end
    end %addEndItemize

    function fmt = item(obj,itext)
      if obj.m_init
        fmt = obj.m_formater.item(itext);
      else
        obj.showError('item');
      end
    end

    function obj = addItem(obj,itext)
      if obj.m_init
        obj.m_text = [obj.m_text obj.item(itext)];
      else
        obj.showError('addItem');
      end
    end %addItem

    function fmt = title(obj,ttext,level)
      if obj.m_init
        fmt = obj.m_formater.title(ttext,level);
      else
        obj.showError('title');
      end
    end

    function obj = addTitle(obj,ttext,level)
      if obj.m_init
        lab = obj.generateTOClabel(ttext,level);
        obj.m_text = [obj.m_text obj.label(lab)];
        obj.m_text = [obj.m_text obj.title(ttext,level)];
        obj.updateTOCinfo(ttext,level,lab);  
      else
        obj.showError('addTitle');
      end
    end %addTitle

    function fmt = paragraph(obj,ptext)
      if obj.m_init
        if nargin ~= 2 %only one parameter accepted
           obj.showError('paragraph');
        else
           switch(class(ptext))
            case 'cell'
              formatstr = strcat('%-', arrayfun(@mat2str, max(cellfun(@length, ptext)), ...
                      'UniformOutput', false), 's\t');
              formatstr = [sprintf('%s',formatstr{:}) '\n'];
              %cell{:} output is in column mode, so we need to transpose
              ptext = ptext';
              text = sprintf(formatstr,ptext{:});

            case 'char'
              text = ptext;

            otherwise
              text = mat2str(ptext);        

           end%switch
           fmt = obj.m_formater.paragraph(text);
        end%numel
      else
        obj.showError('paragraph');
      end%m_init
    end



    function obj = addParagraph(obj,ptext)
      if obj.m_init
         t2p = ptext;
         if iscell(ptext)
            t2p = ptext;
         end     
         obj.m_text = [obj.m_text obj.paragraph(t2p)];
      else
        obj.showError('addParagraph');
      end
    end %addParagraph

    function fmt = figure(obj,img,varargin)
      if obj.m_init
        %It may be a file or a handler
        if isa(img,'char') %its a filename
           if exist(img,'file') 
              %imgfile = fullfile(pwd,img);
              imgfile = fullfile(img);
           else
               error ('Figure not found');
           end
        else
           %we must save the handle into a file
           if isa(img,'ao')
               handle = img.plotinfo.figure;
           else
               handle = img;
           end
           imgfile = obj.saveImage(handle);
           
           %if has been set to close after being codified, close it
           if obj.m_bgImages 
              close (handle);
           end
        end
        %now we know we have an image file:
        str64 = obj.encodeImage64(imgfile);
        fmt = obj.m_formater.figure(str64,varargin{:});
      else
        obj.showError('imgfile');
      end
    end

    function obj = addFigure(obj,imgfile,varargin)
      if obj.m_init
        obj.m_text = [obj.m_text obj.figure(imgfile,varargin{:})];
      else
        obj.showError('addFigure');
      end
    end %addFigure



    function fmt = label(obj,ltext)
      if obj.m_init
        fmt = obj.m_formater.label(ltext);
      else
        obj.showError('label');
      end
    end

    function obj = addLabel(obj,ltext)
      if obj.m_init
        obj.m_text = [obj.m_text obj.label(ltext)];
      else
        obj.showError('addLabel');
      end
    end %addLabel


    function fmt = center(obj,ctext)
      if obj.m_init
        fmt = obj.m_formater.center(ctext);
      else
        obj.showError('center');
      end
    end

    function obj = addCenter(obj,ctext)
      if obj.m_init
        obj.m_text = [obj.m_text obj.center(ctext)];
      else
        obj.showError('addCenter');
      end
    end %addCenter



    function fmt = reference(obj,rlabel,caption)
      if obj.m_init
        fmt = obj.m_formater.reference(rlabel,caption);
      else
        obj.showError('reference');
      end
    end

    function obj = addReference(obj,rlabel,caption)
      if obj.m_init
        obj.m_text = [obj.m_text obj.reference(rlabel,caption)];
      else
        obj.showError('addReference');
      end
    end %addReference

    function fmt = link(obj,URL,caption)
      if obj.m_init
        fmt = obj.m_formater.link(URL,caption);
      else
        obj.showError('link');
      end
    end

    function obj = addLink(obj,URL,caption)
      if obj.m_init
        obj.m_text = [obj.m_text obj.link(URL,caption)];
      else
        obj.showError('addLink');
      end
    end %addLink

    function fmt = lineBreak(obj)
      if obj.m_init
        fmt = obj.m_formater.lineBreak();
      else
        obj.showError('lineBreak');
      end
    end

    function obj = addLineBreak(obj,URL,caption)
      if obj.m_init
        obj.m_text = [obj.m_text obj.lineBreak()];
      else
        obj.showError('addLink');
      end
    end %addLineBreak

    function fmt = bold(obj,text)
      if obj.m_init
        fmt = obj.m_formater.bold(text);
      else
        obj.showError('bold');
      end
    end

    function obj = addBold(obj,text)
      if obj.m_init
        obj.m_text = [obj.m_text obj.bold(text)];
      else
        obj.showError('addBold');
      end
    end %addBold

    function fmt = color(obj,text, color)
      if obj.m_init
        fmt = obj.m_formater.color(text,color);
      else
        obj.showError('color');
      end
    end

    function obj = addColor(obj,text,color)
      if obj.m_init
        obj.m_text = [obj.m_text obj.color(text,color)];
      else
        obj.showError('addColor');
      end
    end %addColor



    function fmt = comment(obj,text)
      if obj.m_init
        fmt = obj.m_formater.comment(text);
      else
        obj.showError('comment');
      end
    end

    function obj = addComment(obj,text)
      if obj.m_init
        obj.m_text = [obj.m_text obj.comment(text)];
      else
        obj.showError('addComment');
      end
    end %addComment



    function obj = addFormatedString(obj,fstring)
      if obj.m_init
        obj.m_text = [obj.m_text fstring];
      else
        obj.showError('addFormatedString');
      end
    end %addFormatedString

    function obj = addLineSeparator(obj)
      if obj.m_init
        obj.m_text = [obj.m_text obj.m_formater.lineSeparator()];
      else
        obj.showError('addLineSeparator');
      end
    end %addLineSeparator


     function obj = saveDocument(obj)
      if obj.m_init
        imgpath = fileparts(obj.m_reportFile);
        if ~exist(imgpath,'dir')
            mkdir(imgpath);
        end
        fid = fopen(obj.m_reportFile,'w');
        if fid ~= -1
           fprintf(fid,'%s',obj.m_text);
           return;
        end
      end
      obj.showError('saveDocument');
    end %saveDocument
    
    function obj = removeMultiStepReportAtIndex(obj,filename,index)
       if exist(filename,'file')
          obj.m_reportFile = filename;
          text = fileread(obj.m_reportFile);
          beginmark = obj.comment(obj.m_begin_step_mark);
          endmark = obj.comment(obj.m_end_step_mark);
          rb = strfind(text,beginmark);
          re = strfind(text,endmark);
          if numel(rb) >= index && numel(re) >= index
             txt = [text(1:rb(index)-1) text(re(index)+length(endmark):end)];

             %And now the TOC of the multistep:
             bmultitoc = obj.comment(obj.m_begin_multi_toc);
             emultitoc = obj.comment(obj.m_end_multi_toc);
             rb = strfind(txt,bmultitoc);
             re = strfind(txt,emultitoc);
             if numel(rb) >= index && numel(re) >= index
                txdef = [txt(1:rb(index)-1) txt(re(index)+length(emultitoc):end)];
                obj.m_text = txdef;             
             else
                error('TOC for execution #%d not found ',index);     
             end
          else
             error('Report for execution #%d not found ',index); 
          end
       else
          error('File : %s not found',obj.m_reportFile);
       end
    end %removeMultiStepReportAtIndex
    
    %Function to join step reports to the main investigation report
    function obj = joinReport(obj,filename_dst,step_names,step_report_files)
       if exist(obj.m_reportFile,'file')
          text_global = obj.readReportTillEndMark();
          
          %Now we have to append the step reports.
          %So we need the step names.
          for sn = 1:numel(step_report_files)
              rp = utils.autoReporter();
              rp.openDocument(step_report_files{sn});
              txstep = rp.readReportBody();
              beginanchor = rp.label(sprintf('_BEGIN_STEP_%s_',step_names{sn}));
              text_global = [text_global  beginanchor txstep];
          end
          
          obj.m_text = text_global;
          obj.update_step_links_join(step_names);
          obj.m_reportFile = filename_dst;
          %obj.endDocument(); %%No need to end document. We are just
          %appending already finished documents, so the document ending is
          %already done
          obj.saveDocument();
       else
          error('File : %s not found',filename);
       end
    end
    

        

  end %public methods

  methods (Access = public)

    function showError(obj, code)
      fprintf(2,'ERROR: autoReporter::%s : instance not correctly initialized',code);
    end

    function imgfile = saveImage(obj, hImage)
      set(hImage, 'PaperOrientation', 'portrait');
      set(hImage, 'PaperPositionMode', 'manual');
      set(hImage, 'PaperUnits', 'centimeters');
      set(hImage, 'PaperSize', [29.7 21.0])
      set(hImage, 'PaperPosition', [0.0 0.0 29.7 21.0]);
      %try to create a unique name using m_figindex, and current timestamp
      strnow = sprintf('%f',now);
      strnow = strrep(strnow,'.','_');
      imgfile = sprintf('figure_%s_%d.png',strnow,obj.m_figindex);
      imgfile = [obj.m_reportFolder filesep imgfile];
      %imgfile = fullfile(pwd,imgfile);
      imgpath = fileparts(imgfile);
      if ~exist(imgpath,'dir')
        mkdir(imgpath);
      end
      obj.m_figindex = obj.m_figindex + 1;
      saveas(hImage,imgfile);

    end

    function txt = readReportTillEndMark(obj)
       %we know the file exists :
       text = fileread(obj.m_reportFile);
       endmark = obj.comment(obj.m_end_mark);
       rend = strfind(text,endmark);
       txt = text(1:rend-1);
    end
    
    %read the contents of the BODY of the report
    function txt = readReportBody(obj)
       %we know the file exists :
       text = fileread(obj.m_reportFile);
      
       begin_body = obj.comment(obj.m_begin_body_mark);
       end_body = obj.comment(obj.m_end_body_mark);
              
       rb = strfind(text,begin_body);
       re = strfind(text,end_body);
       txt = text(rb:re-1);
    end
    
    function obj = update_step_links_join(obj,step_names)
        text = obj.m_text;
        
        for ns = 1 : length (step_names)
            bl =  sprintf('BEGIN_LINK_%s',step_names{ns});
            el =  sprintf('END_LINK_%s',step_names{ns});
            tbl = obj.comment(bl);
            tel = obj.comment(el);
            
            bpos = strfind(text,tbl);
            epos = strfind(text,tel);
            
            tref = sprintf('_BEGIN_STEP_%s_',step_names{ns});
            newlink = obj.reference(tref,'view');
            
            text = [ text(1:bpos-1) newlink text(epos+length(tel):end)];
            
        end
        obj.m_text = text;
        
    end
    
    function str64 = encodeImage64(obj,imgfile)
    % This file uses the base64 encoder from the Apache Commons Codec, 
    % http://commons.apache.org/codec/ and distrubed with MATLAB under the
    % Apache License http://commons.apache.org/license.html
    % Copyright 2009 The MathWorks, Inc.

        fid = fopen(imgfile,'rb');
        bytes = fread(fid);
        fclose(fid);
        encoder = org.apache.commons.codec.binary.Base64;
        str1line = char(encoder.encode(bytes))';
        strNlines = [];
        l = length(str1line);
        cpr = 80 ; %chars per line
        nl = floor(l/cpr);
        %Split it in several lines to a better "read" of generated report
        for i = 1:nl
            low = ((i-1) * cpr ) + 1;
            high = i * cpr;
            strNlines = [strNlines char(10) str1line(low:high)];
        end
        if mod(l,80) ~= 0
            strNlines = [strNlines char(10) str1line((nl)*80+1:end)];
        end
        str64 = strNlines;
    end
    
    function obj = updateTOCinfo(obj,text,level,label)
        info = {level,text,label};
        obj.m_TOC_info {numel(obj.m_TOC_info)+1} = info;
    end
    
    function strTOC = generateTOC(obj)
        str = '';

        cur_level = 0;
        nopen = 0;

        if obj.m_TOC_title_needed 
           %is a newe file
           str = obj.title('Table Of Contents',1);
           cur_level = 0;
           nopen = 0;
        else
           %there is an prexisting TOC. SO we must append OL, and
           %avoid closing the last one.
           %So we delete the last one, and fake as if we were in the
           %first level, with a level open:
           obj.deleteLastOpenOrderedListTOC();
           cur_level = 1 ;
           nopen = 1;
        end
        
        iBegin = obj.beginItemize();
        iEnd   = obj.endItemize();
        
        for i = 1:numel(obj.m_TOC_info)
            info = obj.m_TOC_info{i};
            l = info{1}; %level
            t = info{2}; %text
            lab = info{3}; %generated label
            item = obj.reference(lab,t);
            item = obj.bold(item);
            item = obj.item(item);
            
            if l > cur_level
              %bigger level, inner <ol>
              toopen = l - cur_level;
              for to = 1:toopen
                str = [str '<ol>' char(10) ];    
                nopen = nopen + 1 ;
              end
            elseif l < cur_level
              %lower level, must close all inner levels
              toclose = cur_level - l;
              for tc = 1 : toclose
                str = [str  '</ol>' char(10) ];    
                nopen = nopen - 1 ;
              end;
            end
            %if we are in the same current level, just add the item
            str = [str item char(10)];
            cur_level = l;
        end
        %and now, close all the open lists.
        for nc = 1 : nopen -1 %the last one later
            str = [str '</ol>' char(10)];
        end
        
        %For the last one, another special marks to be used by
        %  obj.deleteLastOpenOrderedListTOC();
        % for locate and delete the last closed OL
                
        begin_last_ordered_list_TOC  = obj.comment(obj.m_begin_last_ol_TOC);
        end_last_ordered_list_TOC  = obj.comment(obj.m_end_last_ol_TOC);
        str = [str begin_last_ordered_list_TOC '</ol>' end_last_ordered_list_TOC char(10)];
        
        strTOC = str;
    end%generateTOC
    
    function obj = insertTOC(obj)
        strTOC = obj.generateTOC();
        beginmark = obj.comment(obj.m_begin_toc_mark);
        endmark = obj.comment(obj.m_end_toc_mark);
        rb = strfind(obj.m_text,beginmark);
        re = strfind(obj.m_text,endmark);
        if numel(rb) == 0 || numel(re) == 0
             warning('Table of contents not found on autoReporter instance of %s.Maybe joining.',obj.m_reportFile);
             return;
        end
        
        if numel(rb) >1  || numel(re) >1
             warning('Table of contents is not well produced on %s',obj.m_reportFile);
        else
            %replace the tags with the TOC location with the TOC content.
            %We keep de endmark just in case multireport wants to add new TOC
            %for next multireport step
            txt = obj.m_text;
            %txt = [txt(1:rb-1) strTOC txt(re +length(endmark) : end) ];
            bmulti = obj.comment(obj.m_begin_multi_toc);
            emulti = obj.comment(obj.m_end_multi_toc);
            
            
            txt = [txt(1:rb-1) bmulti strTOC emulti txt(re : end) ];
            obj.m_text = txt;
        end
    end

    function obj = appendTOCmark(obj)
        %in case of multireport on a previous existing report, search for the preexisting
        %TOC end mark, and add the begin mark for the new execution to be appended to the
        %existing TOC
        beginmark = obj.comment(obj.m_begin_toc_mark);
        endmark = obj.comment(obj.m_end_toc_mark);
        re = strfind(obj.m_text,endmark);
        if numel(re) == 0
             error('NOT existing TOC to append on this multireport instance: %s.',obj.m_reportFile);
             return;
        end
        
        if numel(re) >1
             warning('Table of contents is not well produced on %s',obj.m_reportFile);
        else
            %where we have the prexistign end mark, prepend the start mark.
            txt = obj.m_text;
            txt = [txt(1:re-1) beginmark txt(re : end) ];
            obj.m_text = txt;
        end
    end
    
    function lab = generateTOClabel(obj,ttext,level)
        %just to generate a different lavel each time, just in case
        %two titles are identical
        lab = sprintf('_label_toc_%s_%d_%d_%f',ttext,level,obj.m_toc_counter,now);
        obj.m_toc_counter = obj.m_toc_counter + 1;
    end
    
    function deleteLastOpenOrderedListTOC(obj)
        % for locate and delete the last closed OL
        begin_last_ordered_list_TOC  = obj.comment(obj.m_begin_last_ol_TOC);
        end_last_ordered_list_TOC  = obj.comment(obj.m_end_last_ol_TOC);
        bm = strfind(obj.m_text,begin_last_ordered_list_TOC);
        em = strfind(obj.m_text,end_last_ordered_list_TOC);
        
        if numel(bm) ~= 1  || numel (em) ~= 1
             warning('NOT existing last </OL> from TOC to append the next TOC: %s.',obj.m_reportFile);
             return;
        end
        
        %where we have the prexistign end mark, prepend the start mark.
        txt = obj.m_text;
        txt = [txt(1:bm-1) txt(em + length(end_last_ordered_list_TOC)+1 : end) ];
        obj.m_text = txt;
    end

  end %end private methods

end %classdef
