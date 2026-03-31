% SUBMITDIALOG Creates a connection and the sinfo structure depending of the input variables.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SUBMITDIALOG Creates a connection and the sinfo structure
%              depending of the input variables.
%
% CALL:        sinfo = submitDialog(sinfo_in, pl)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sinfo = submitDialog(pl)
  
  % Copy input plist
  pl = copy(pl, 1);
  
  %%% Show dialog or not
  noDialog = pl.find_core('no dialog');
  
  %%% Create/fill sinfo from the plist.
  sinfo = getDefaultStruct();
  
  %%% Check If we should the sinfo from a file
  if ~isempty(pl.find_core('sinfo filename'))
    pl.combine(utils.xml.read_sinfo_xml(pl.find_core('sinfo filename')));
  end
  
  %%% Set the fields from the plist to the struct
  sinfo = setField(sinfo, pl, 'experiment title');
  sinfo = setField(sinfo, pl, 'experiment description');
  sinfo = setField(sinfo, pl, 'analysis description');
  sinfo = setField(sinfo, pl, 'quantity');
  sinfo = setField(sinfo, pl, 'keywords');
  sinfo = setField(sinfo, pl, 'reference ids');
  sinfo = setField(sinfo, pl, 'additional comments');
  sinfo = setField(sinfo, pl, 'additional authors');
  
  %%% Create connection if the
  if  (allFieldsFilled(sinfo)) || ...
      (allMandatoryFieldsFilled(sinfo) && noDialog)
    
    %%% Return because we have all sinfo information
    return
  end
  
  jsinfo = awtcreate('mpipeline.repository.SubmissionInfo', 'Lmpipeline.main.MainWindow;', []);
  
  if ~isempty(sinfo.experiment_title), jsinfo.setExperimentTitle(sinfo.experiment_title);end
  if ~isempty(sinfo.experiment_description), jsinfo.setExperimentDescription(sinfo.experiment_description); end
  if ~isempty(sinfo.analysis_description), jsinfo.setAnalysisDescription(sinfo.analysis_description); end
  if ~isempty(sinfo.quantity), jsinfo.setQuantity(sinfo.quantity); end
  if ~isempty(sinfo.keywords), jsinfo.setKeywords(sinfo.keywords); end
  if ~isempty(sinfo.reference_ids), jsinfo.setReferenceIDs(sinfo.reference_ids); end
  if ~isempty(sinfo.additional_comments), jsinfo.setAdditionalComments(sinfo.additional_comments); end
  if ~isempty(sinfo.additional_authors), jsinfo.setAdditionalAuthors(sinfo.additional_authors); end
  
  sid = javaObjectEDT('mpipeline.repository.SubmitInfoDialog', [], jsinfo);
  
  h1 = handle(sid.getLoadBtn,'callbackproperties');
  h1.ActionPerformedCallback = @cb_loadSinfoFromFile;
  
  h2 = handle(sid.getSaveBtn,'callbackproperties');
  h2.ActionPerformedCallback = @cb_saveSinfoToFile;
  
  h3 = handle(sid, 'callbackproperties');
  h3.WindowClosedCallback = @cb_guiClosed;
  
  sid.setVisible(true)
  
  if sid.isCancelled
    sinfo = [];
  else
    %%% Store the 'sinfo' of the GUI to the output sinfo
    jsinfo = sid.getSubmissionInfo;
    sinfo.experiment_title       = char(jsinfo.getExperimentTitle);
    sinfo.experiment_description = char(jsinfo.getExperimentDescription);
    sinfo.analysis_description   = char(jsinfo.getAnalysisDescription);
    sinfo.quantity               = char(jsinfo.getQuantity);
    sinfo.keywords               = char(jsinfo.getKeywords);
    sinfo.reference_ids          = char(jsinfo.getReferenceIDs);
    sinfo.additional_comments    = char(jsinfo.getAdditionalComments);
    sinfo.additional_authors     = char(jsinfo.getAdditionalAuthors);
  end
  
  jsinfo = [];
  sid = [];
  pl = [];
  prefs = [];
  java.lang.System.gc();  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % nested callback Function: cb_loadSinfoFromFile()
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function cb_loadSinfoFromFile(varargin)
    [FileName, PathName, FilterIndex] = uigetfile('*.xml', 'XML File');
    
    if (FileName)
      try
        sinfoPl = utils.xml.read_sinfo_xml(fullfile(PathName, FileName));
        
        % Set the values from the PLIST to the dialog.
        if ~isempty(sinfoPl.find_core('experiment title'))
          sid.setExperimentTitleTxtField(sinfoPl.find_core('experiment title')); end
        if ~isempty(sinfoPl.find_core('experiment_title'))
          sid.setExperimentTitleTxtField(sinfoPl.find_core('experiment_title')); end
        
        if ~isempty(sinfoPl.find_core('experiment description'))
          sid.setExperimentDescriptionTxtField(sinfoPl.find_core('experiment description')); end
        if ~isempty(sinfoPl.find_core('experiment_description'))
          sid.setExperimentDescriptionTxtField(sinfoPl.find_core('experiment_description')); end
        
        if ~isempty(sinfoPl.find_core('analysis description'))
          sid.setAnalysisDescriptionTxtField(sinfoPl.find_core('analysis description')); end
        if ~isempty(sinfoPl.find_core('analysis_description'))
          sid.setAnalysisDescriptionTxtField(sinfoPl.find_core('analysis_description')); end
        
        if ~isempty(sinfoPl.find_core('quantity'))
          sid.setquantityTxtField(sinfoPl.find_core('quantity')); end
        
        if ~isempty(sinfoPl.find_core('keywords'))
          sid.setKeywordsTxtField(sinfoPl.find_core('keywords')); end
        
        if ~isempty(sinfoPl.find_core('reference ids'))
          sid.setReferenceIDsTxtField(sinfoPl.find_core('reference ids')); end
        if ~isempty(sinfoPl.find_core('reference_ids'))
          sid.setReferenceIDsTxtField(sinfoPl.find_core('reference_ids')); end
        
        if ~isempty(sinfoPl.find_core('additional comments'))
          sid.setAdditionalCommentsTxtField(sinfoPl.find_core('additional comments')); end
        if ~isempty(sinfoPl.find_core('additional_comments'))
          sid.setAdditionalCommentsTxtField(sinfoPl.find_core('additional_comments')); end
        
        if ~isempty(sinfoPl.find_core('additional authors'))
          sid.setAdditionalAuthorsTxtField(sinfoPl.find_core('additional authors')); end
        if ~isempty(sinfoPl.find_core('additional_authors'))
          sid.setAdditionalAuthorsTxtField(sinfoPl.find_core('additional_authors')); end
        
      catch err
        utils.helper.err(['### This file doesn''t contain any submission information.' err.message])
      end
      
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % nested callback Function: cb_saveSinfoToFile()
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function cb_saveSinfoToFile(varargin)
    
    saveBtn = varargin{1};
    jsinfo = saveBtn.rootPane.getParent().getSubmissionInfo();
    
    sinfo.experiment_title       = char(jsinfo.getExperimentTitle());
    sinfo.experiment_description = char(jsinfo.getExperimentDescription());
    sinfo.analysis_description   = char(jsinfo.getAnalysisDescription());
    sinfo.quantity               = char(jsinfo.getQuantity());
    sinfo.keywords               = char(jsinfo.getKeywords());
    sinfo.reference_ids          = char(jsinfo.getReferenceIDs());
    sinfo.additional_comments    = char(jsinfo.getAdditionalComments());
    sinfo.additional_authors     = char(jsinfo.getAdditionalAuthors());
    
    [FileName, PathName, FilterIndex] = uiputfile('*.xml', 'XML File');
    
    if (FileName)
      try
        utils.xml.save_sinfo_xml(fullfile(PathName, FileName), sinfo);
      catch
      end
      
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % nested callback Function: cb_guiClosed()
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function cb_guiClosed(varargin)
    if ishandle(h1)
      delete(h1);
    end
    if ishandle(h2)
      delete(h2);
    end
    if ishandle(h3) 
      delete(h3);
    end
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultStruct
%
% DESCRIPTION: Creates default structure for 'sinfo'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sinfo = getDefaultStruct()
  sinfo = struct(...
    'experiment_title',       '', ...
    'experiment_description', '', ...
    'analysis_description',   '', ...
    'quantity',               '', ...
    'keywords',               '', ...
    'reference_ids',          '', ...
    'additional_comments',    '', ...
    'additional_authors',     '');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    allMandatoryFieldsFilled
%
% DESCRIPTION: Check if all mandatory fields are filled in 'sinfo'.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = allMandatoryFieldsFilled(sinfo)
  res = false;
  if isstruct(sinfo)
    if  isfield(sinfo, 'experiment_title')       && ~isempty(sinfo.experiment_title)       && ...
        isfield(sinfo, 'experiment_description') && ~isempty(sinfo.experiment_description) && ...
        isfield(sinfo, 'analysis_description')   && ~isempty(sinfo.analysis_description)
      res = true;
    end
  end
end


function res = allFieldsFilled(sinfo)
  res = false;
  if isstruct(sinfo)
    if  isfield(sinfo, 'experiment_title')       && ~isempty(sinfo.experiment_title)       && ...
        isfield(sinfo, 'experiment_description') && ~isempty(sinfo.experiment_description) && ...
        isfield(sinfo, 'analysis_description')   && ~isempty(sinfo.analysis_description) && ...
        isfield(sinfo, 'quantity')   && ~isempty(sinfo.quantity) && ...
        isfield(sinfo, 'keywords')   && ~isempty(sinfo.keywords) && ...
        isfield(sinfo, 'reference_ids')   && ~isempty(sinfo.reference_ids) && ...
        isfield(sinfo, 'additional_comments')   && ~isempty(sinfo.additional_comments) && ...
        isfield(sinfo, 'additional_authors')   && ~isempty(sinfo.additional_authors)
      res = true;
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    setField
%
% DESCRIPTION:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sinfo = setField(sinfo, pl, field)
  struct_field = strrep(field, ' ', '_');
  
  % if the fiels doesn't exist in the struct then create this field
  if ~isfield(sinfo, struct_field)
    sinfo.(struct_field) = '';
  end
  
  if ~isempty(pl.find_core(field))
    sinfo.(struct_field) = pl.find_core(field);
  end
  if ~isempty(pl.find_core(strrep(field, ' ', '_')))
    sinfo.(struct_field) = pl.find_core(strrep(field, ' ', '_'));
  end
end




