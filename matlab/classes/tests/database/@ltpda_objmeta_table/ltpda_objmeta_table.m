classdef ltpda_objmeta_table < ltpda_database
  
  properties
    objIdsStruct    = [];
    objCIdsStruct   = [];
    objUUIdsStruct  = [];
    sinfoStruct     = [];
  end
  
  methods
    function utp = ltpda_objmeta_table(varargin)
      utp = utp@ltpda_database();
      
      t = time();
      tStr = t.format('dd-mmm-yyyy HH:MM (z)');
      
      experiment_title       = 'Unit test - My experiment title';
      experiment_description = 'Unit test - My experiment description';
      analysis_description   = 'Unit test - My analysis description';
      quantity               = 'Unit test - My quantity';
      keywords               = 'Unit test - My keywords';
      reference_ids          = 'Unit test - My reference IDs';
      additional_comments    = 'Unit test - My additional comments';
      additional_authors     = 'Unit test - My additional authors';
      
      s.experiment_title       = sprintf('%s with a struct - %s', experiment_title, tStr);
      s.experiment_description = sprintf('%s with a struct - %s', experiment_description, tStr);
      s.analysis_description   = sprintf('%s with a struct - %s', analysis_description, tStr);
      s.quantity               = sprintf('%s with a struct - %s', quantity, tStr);
      s.keywords               = sprintf('%s with a struct - %s', keywords, tStr);
      s.reference_ids          = sprintf('%s with a struct - %s', reference_ids, tStr);
      s.additional_comments    = sprintf('%s with a struct - %s', additional_comments, tStr);
      s.additional_authors     = sprintf('%s with a struct - %s', additional_authors, tStr);
      
      utp.sinfoStruct = s;
      
    end
  end
  
  methods
    function varargout = submitTestDataWithStruct(varargin)
      utp = varargin{1};
      out = utp.testData.submit(utp.testRunner.repositoryPlist, utp.sinfoStruct);
      if ~utp.testRunner.skipRepoTests()
        utp.objIdsStruct    = out.find('IDs');
        utp.objCIdsStruct   = out.find('CIDs');
        utp.objUUIdsStruct  = out.find('UUIDs');
      end
    end
  end
  
end
