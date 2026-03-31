% CATEGORIES class that defines LTPDA method categories.
%
% CALL:  utils.const.categories.KEY
%
% This class have the following constants:
%
%   KEY           |  VALUE
%   --------------------------------
%   constructor   | 'Constructor'
%   internal      | 'Internal'
%   statespace    | 'Statespace'
%   sigproc       | 'Signal Processing'
%   aop           | 'Arithmetic Operator'
%   helper        | 'Helper'
%   op            | 'Operator'
%   output        | 'Output'
%   relop         | 'Relational Operator'
%   trig          | 'Trigonometry'
%   mdc01         | 'MDC01'
%   gui           | 'GUI function'
%   converter     | 'Converter'
%   user          | 'User defined'
% 

classdef categories
  properties (Constant = true)
    constructor    = 'Constructor';
    internal       = 'Internal';
    statespace     = 'Statespace';
    sigproc        = 'Signal Processing';
    aop            = 'Arithmetic Operator';
    helper         = 'Helper';
    op             = 'Operator';
    output         = 'Output';
    relop          = 'Relational Operator';
    trig           = 'Trigonometry';
    mdc01          = 'MDC01';    
    gui            = 'GUI function';
    converter      = 'Converter';
    user           = 'User defined';
  end
  
  methods (Static=true)
    
    % List the categories
    function cl = list      
      props = [properties(utils.const.categories)];
      cl = cell(numel(props),1);
      for k=1:numel(props)
        cl(k) = {utils.const.categories.(props{k})};
      end      
    end    
    
  end  
end