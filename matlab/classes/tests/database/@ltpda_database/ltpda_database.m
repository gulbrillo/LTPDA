classdef ltpda_database < ltpda_utp
  
  properties
    objIds     = [];
    objCIds    = [];
    objUUIds   = [];
    sinfoPlist = [];
    conn       = [];
    oldDB      = false;
    tableId    = 'id';
  end
  
  methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                               Constructor                               %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function utp = ltpda_database(varargin)
      utp = utp@ltpda_utp();
      
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
      
      plSinfo = plist(...
        'experiment_title',       sprintf('%s with a PLIST - %s', experiment_title, tStr), ...
        'experiment_description', sprintf('%s with a PLIST - %s', experiment_description, tStr), ...
        'analysis_description',   sprintf('%s with a PLIST - %s', analysis_description, tStr), ...
        'quantity',               sprintf('%s with a PLIST - %s', quantity, tStr), ...
        'keywords',               sprintf('%s with a PLIST - %s', keywords, tStr), ...
        'reference_ids',          sprintf('%s with a PLIST - %s', reference_ids, tStr), ...
        'additional_comments',    sprintf('%s with a PLIST - %s', additional_comments, tStr), ...
        'additional_authors',     sprintf('%s with a PLIST - %s', additional_authors, tStr));
      
      utp.sinfoPlist = plSinfo;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                               Destructor                                %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function delete(varargin)
      utp = varargin{1};
      if ~utp.testRunner.skipRepoTests()
        % Close connection
        utp.conn.close();
        utp.conn = [];
      end
    end
  end
  
  methods
    function varargout = submitTestData(varargin)
      utp = varargin{1};
      if ~utp.testRunner.skipRepoTests()
        out = utp.testData.submit(utp.testRunner.repositoryPlist, utp.sinfoPlist);
        utp.objIds    = out.find('ids');
        utp.objCIds   = out.find('cid');
        utp.objUUIds  = out.find('UUids');
      end
    end
  end
  
end
