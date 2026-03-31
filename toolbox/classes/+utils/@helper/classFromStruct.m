% CLASSFROMSTRUCT returns a class name that matches the structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CLASSFROMSTRUCT returns a class name that matches the
%              structure.
%
% CALL:        class_name  = classFromStruct(struct)
%
% If structure does not match any of the LTPDA classes, then 'class_name'
% will be empty.
%
% INPUTS:      struct:     Structure which should be checked
%
% OUTPUTS:     class_name: Class name.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = classFromStruct(varargin)

  if nargin < 1
    error('### Unknown number of inputs.%s### Please use: classFromStruct(struct)', char(10))
  end

  obj_struct = varargin{1};
  class_name = '';
  % we must determine the class from the fieldnames
  cls = utils.helper.ltpda_non_abstract_classes;
  snames = fieldnames(obj_struct);
  for jj=1:numel(cls)
    cl = cls{jj};
    cnames = properties(cl);
    if numel(cnames) == numel(snames)&& all(strcmp(snames, cnames))
      class_name = cl;
      break;
    end
  end

  % Set output
  varargout{1} = class_name;

end