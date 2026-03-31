% RSTRUCT recursively converts an object into a structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RSTRUCT recursively converts an object into a structure. This is the same
% behaviour as MATLAB's struct(obj) except that it recursively converts all
% sub-objects into structures as well.
%
%   >> s = utils.prog.rstruct(obj)
%
% M Hewitson 02-06-07
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = rstruct(varargin)
  
  % Check inputs
  if nargin~=1
    error('### This function supports only one input.');
  end
  
  objs = varargin{1};
  
  % Create structure from fieldnames
  nObjs  = numel(objs);
  fnames = getFieldnames(objs);
  if nObjs >= 1
    % Add the fields: 'class' and 'tbxver'
    try
      if ~utils.helper.ismember('class', fnames)
        fnames = [{'class', 'tbxver'}, fnames];
      end
    catch Me
      Me
    end
  end
  nNames = numel(fnames);
  
  s = cell2struct(cell(nObjs, nNames), fnames, 2);
  
  for oo=1:numel(objs)
    
    s(oo).class  = class(objs);
    s(oo).tbxver = strtok(getappdata(0, 'ltpda_version'));
    
    for nn=3:numel(fnames)
      fname = fnames{nn};
      obj   = objs(oo).(fname);
      if isa(obj, 'ltpda_obj')
        s(oo).(fname) = utils.prog.rstruct(obj);
      elseif isobject(obj)
        s(oo).(fname) = struct(obj);
      elseif iscell(obj)
        % Check if a cell-array contains a MATLAB handle object
        if ~isempty(obj)
          idx = find(cellfun(@(x)(isa(x, 'ltpda_obj')), obj));
          if ~isempty(idx)
            for ii = 1:numel(idx)
              obj{idx(ii)} = utils.prog.rstruct(obj{idx(ii)});
            end
          end
        end
        s(oo).(fname) = obj;
        
      else
        s(oo).(fname) = objs(oo).(fname);
      end
      
    end
  end
  
  % Reshape the struct to the shape of the input objects
  s = reshape(s, size(objs));
  
  % Set output
  varargout{1} = s;
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getFieldnames
%
% DESCRIPTION: Returns the field names which should be stored in a XML file.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fields = getFieldnames(obj)
  
  if isstruct(obj)
    fields = fieldnames(obj);
  elseif isa(obj, 'ltpda_obj')
    
    meta = metaclass(obj);
    metaProp = meta.PropertyList;
    props = {metaProp(:).Name};
    propGetAccess = strcmpi({metaProp(:).GetAccess}, 'public');
    propDependent = [metaProp(:).Dependent];
    fields = props(propGetAccess & ~propDependent);
    
  else
    error('Failed to process object of class %s', class(obj));
  end
end


