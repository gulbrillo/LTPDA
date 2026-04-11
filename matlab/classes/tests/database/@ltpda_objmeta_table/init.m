% INIT initialize the unit test class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: INIT initialize the unit test class.
%              This method is called before the test methods.
%
% CALL:        init();
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = init(varargin)
  
  utp = varargin{1};
  
  % Call super class
  init@ltpda_database(varargin{:});
  
  % Submit test data
  if ~utp.testRunner.skipRepoTests()
    submitTestDataWithStruct(varargin{:});
  end
end

