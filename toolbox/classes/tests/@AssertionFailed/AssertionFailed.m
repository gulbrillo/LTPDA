% AssertionFailed sub-class of MException
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: AssertionFailed sub-class of MException
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef AssertionFailed < MException
  
  methods
    function self = AssertionFailed(varargin)
      self@MException(varargin{:});
    end
  end
  
end

